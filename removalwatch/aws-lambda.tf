resource "aws_lambda_function" "removalwatch-lambda" {
  filename         = data.archive_file.removalwatch-archive.output_path
  source_code_hash = data.archive_file.removalwatch-archive.output_base64sha256
  function_name    = "${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  role             = aws_iam_role.removalwatch-role-lambda.arn
  kms_key_arn      = aws_kms_key.removalwatch-kms-lambda.arn
  memory_size      = var.function_memory
  handler          = "removalwatch.lambda_handler"
  publish          = true
  runtime          = "python3.8"
  timeout          = var.function_timeoutsec
  environment {
    variables = {
      CLIENTID        = var.praw_clientid
      CLIENTSECRET    = var.praw_clientsecret
      DISCORD_WEBHOOK = var.discord_webhook
      HOTLIMIT        = var.reddit_hotlimit
      TOPLIMIT        = var.comment_toplimit
      SUBREDDIT       = var.reddit_subreddit
      PREFIX          = var.aws_prefix
      SUFFIX          = random_string.aws_suffix.result
    }
  }
  depends_on = [aws_cloudwatch_log_group.removalwatch-cloudwatch-log-group]
}

resource "aws_lambda_alias" "removalwatch-lambda-alias" {
  name             = "${var.aws_prefix}-lambda-alias-${random_string.aws_suffix.result}"
  description      = "Latest function"
  function_name    = aws_lambda_function.removalwatch-lambda.function_name
  function_version = aws_lambda_function.removalwatch-lambda.version
}

resource "aws_lambda_permission" "removalwatch-lambda-permit-cloudwatch" {
  statement_id  = "AllowExecutionFromCloudwatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.removalwatch-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.removalwatch-event-rule.arn
  qualifier     = aws_lambda_alias.removalwatch-lambda-alias.name
}
