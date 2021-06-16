output "removalwatch-output" {
  value = <<OUTPUT
### Console Links ###
# Function Logs (AWSCLIv2)
aws logs tail /aws/lambda/${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result} --region ${var.aws_region} --follow

# Function Alias
https://console.aws.amazon.com/lambda/home?region=${var.aws_region}#/functions/${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}/aliases/${var.aws_prefix}-lambda-alias-${random_string.aws_suffix.result}?tab=monitoring

# Table(s)
https://console.aws.amazon.com/dynamodb/home?region=${var.aws_region}#tables:selected=${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result};tab=overview
OUTPUT
}
