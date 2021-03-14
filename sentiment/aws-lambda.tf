resource "aws_lambda_function" "sentiment-lambda" {
  filename                = data.archive_file.sentiment-archive.output_path
  source_code_hash        = data.archive_file.sentiment-archive.output_base64sha256
  function_name           = "${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  role                    = aws_iam_role.sentiment-role-lambda.arn
  kms_key_arn             = aws_kms_key.sentiment-kms-lambda.arn
  memory_size             = var.function_memory
  handler                 = "sentiment.lambda_handler"
  publish                 = true
  runtime                 = "python3.8"
  timeout                 = 120
  environment {
    variables               = {
      CLIENTID                = var.praw_clientid
      CLIENTSECRET            = var.praw_clientsecret
      COMPREHENDCHARLIMIT     = var.comprehend_charlimit
      HOTLIMIT                = var.reddit_hotlimit
      TOPLIMIT                = var.comment_toplimit
      SUBREDDIT               = var.reddit_subreddit
      TARGETWORDS             = var.target_words
      PREFIX                  = var.aws_prefix
      SUFFIX                  = random_string.aws_suffix.result
    }
  }
}

resource "aws_lambda_alias" "sentiment-lambda-alias" {
  name                    = "${var.aws_prefix}-lambda-alias-${random_string.aws_suffix.result}"
  description             = "Latest function"
  function_name           = aws_lambda_function.sentiment-lambda.function_name
  function_version        = aws_lambda_function.sentiment-lambda.version
}

resource "aws_lambda_permission" "sentiment-lambda-permit-cloudwatch" {
  statement_id            = "AllowExecutionFromCloudwatch"
  action                  = "lambda:InvokeFunction"
  function_name           = aws_lambda_function.sentiment-lambda.function_name
  principal               = "events.amazonaws.com"
  source_arn              = aws_cloudwatch_event_rule.sentiment-event-rule.arn
  qualifier               = aws_lambda_alias.sentiment-lambda-alias.name
}
