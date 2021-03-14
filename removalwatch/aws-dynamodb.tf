resource "aws_dynamodb_table" "removalwatch-dynamodb" {
  name                    = "${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  billing_mode            = "PROVISIONED"
  read_capacity           = var.dynamo_readcapacity
  write_capacity          = var.dynamo_writecapacity
  hash_key                = "bot_position"
  attribute {
    name                    = "bot_position"
    type                    = "S"
  }
  tags                    = {
    Name                    = "${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"
  }
  server_side_encryption {
    enabled                 = true
    kms_key_arn             = aws_kms_key.removalwatch-kms-dynamodb.arn
  }
}

resource "aws_dynamodb_table" "removed-dynamodb" {
  name                    = "${var.aws_prefix}-${var.reddit_subreddit}-removed-${random_string.aws_suffix.result}"
  billing_mode            = "PROVISIONED"
  read_capacity           = var.dynamodeleted_readcapacity
  write_capacity          = var.dynamodeleted_writecapacity
  hash_key                = "id"
  attribute {
    name                    = "id"
    type                    = "S"
  }
  tags                    = {
    Name                    = "${var.aws_prefix}-${var.reddit_subreddit}-removed-${random_string.aws_suffix.result}"
  }
  server_side_encryption {
    enabled                 = true
    kms_key_arn             = aws_kms_key.removalwatch-kms-dynamodb.arn
  }
}
