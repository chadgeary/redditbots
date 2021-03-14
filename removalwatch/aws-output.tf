output "removalwatch-output" {
  value = <<OUTPUT
### Console Links ###
Function Logs: https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/$252Faws$252Flambda$252F${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}
Function Alias: https://console.aws.amazon.com/lambda/home?region=${var.aws_region}#/functions/${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}/aliases/${var.aws_prefix}-lambda-alias-${random_string.aws_suffix.result}?tab=monitoring
DynamoDB Table: https://console.aws.amazon.com/dynamodb/home?region=${var.aws_region}#tables:selected=${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result};tab=overview
OUTPUT
}
