resource "aws_lambda_function" "mineddit-lambda" {
  filename                = data.archive_file.mineddit-archive.output_path
  source_code_hash        = data.archive_file.mineddit-archive.output_base64sha256
  function_name           = "${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  role                    = aws_iam_role.mineddit-role-lambda.arn
  kms_key_arn             = aws_kms_key.mineddit-kms-lambda.arn
  memory_size             = var.function_memory
  handler                 = "mineddit.lambda_handler"
  publish                 = true
  runtime                 = "python3.8"
  timeout                 = 120
  environment {
    variables               = {
      CLIENTID                = var.praw_clientid
      CLIENTSECRET            = var.praw_clientsecret
      HOTLIMIT                = var.reddit_hotlimit
      TOPLIMIT                = var.comment_toplimit
      SUBREDDIT               = var.reddit_subreddit
      PREFIX                  = var.aws_prefix
      COMPREHENDCHARLIMIT     = var.comprehend_charlimit
      SUFFIX                  = random_string.aws_suffix.result
    }
  }
}

resource "aws_lambda_alias" "mineddit-lambda-alias" {
  name                    = "${var.aws_prefix}-lambda-alias-${random_string.aws_suffix.result}"
  description             = "Latest function"
  function_name           = aws_lambda_function.mineddit-lambda.function_name
  function_version        = aws_lambda_function.mineddit-lambda.version
}

resource "aws_lambda_permission" "mineddit-lambda-permit-cloudwatch" {
  statement_id            = "AllowExecutionFromCloudwatch"
  action                  = "lambda:InvokeFunction"
  function_name           = aws_lambda_function.mineddit-lambda.function_name
  principal               = "events.amazonaws.com"
  source_arn              = aws_cloudwatch_event_rule.mineddit-event-rule.arn
  qualifier               = aws_lambda_alias.mineddit-lambda-alias.name
}

resource "aws_lambda_provisioned_concurrency_config" "mineddit-lambda-concurrency" {
  function_name           = aws_lambda_alias.mineddit-lambda-alias.function_name
  qualifier               = aws_lambda_alias.mineddit-lambda-alias.name
  provisioned_concurrent_executions = var.function_concurrentexecutions
}
