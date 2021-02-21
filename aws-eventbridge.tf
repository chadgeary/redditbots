resource "aws_cloudwatch_event_rule" "mineddit-event-rule" {
  name                    = "${var.aws_prefix}-event-rule-${random_string.aws_suffix.result}"
  schedule_expression     = "rate(${var.schedule_count} ${var.schedule_unit})"
  is_enabled              = true
}

resource "aws_cloudwatch_event_target" "mineddit-event-target" {
  arn                     = aws_lambda_alias.mineddit-lambda-alias.arn
  rule                    = aws_cloudwatch_event_rule.mineddit-event-rule.id
}
