resource "aws_dynamodb_table" "mineddit-dynamodb" {
  name                    = "${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  billing_mode            = "PROVISIONED"
  read_capacity           = var.dynamo_readcapacity
  write_capacity          = var.dynamo_writecapacity
  hash_key                = "submission_id"
  attribute {
    name                    = "submission_id"
    type                    = "S"
  }
  tags                    = {
    Name                    = "${var.aws_prefix}-dynamodb-${random_string.aws_suffix.result}"
  }
  server_side_encryption {
    enabled                 = true
    kms_key_arn             = aws_kms_key.mineddit-kms-dynamodb.arn
  }
}
