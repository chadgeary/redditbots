resource "aws_cloudwatch_log_group" "removalwatch-cloudwatch-log-group" {
  name              = "/aws/lambda/${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.removalwatch-kmscmk-cloudwatch.arn
  tags = {
    Name = "/aws/lambda/${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  }
}
