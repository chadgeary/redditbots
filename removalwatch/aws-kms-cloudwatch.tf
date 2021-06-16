resource "aws_kms_key" "removalwatch-kmscmk-cloudwatch" {
  description              = "Key for cloudwatch"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = "true"
  tags = {
    Name = "${var.aws_prefix}-kms-cloudwatch-${random_string.aws_suffix.result}"
  }
  policy = <<EOF
{
  "Id": "kmskeypolicy-cloudwatch",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable IAM User Permissions",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.aws-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    },
    {
      "Sid": "Allow access through cloudwatch",
      "Effect": "Allow",
      "Principal": {
        "Service": "logs.${var.aws_region}.amazonaws.com"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*",
      "Condition": {
        "ArnEquals": {
          "kms:EncryptionContext:aws:logs:arn": ["arn:${data.aws_partition.aws-partition.partition}:logs:${var.aws_region}:${data.aws_caller_identity.aws-account.account_id}:log-group:/aws/lambda/${var.aws_prefix}-${var.reddit_subreddit}-${random_string.aws_suffix.result}"]
        }
      }
    }
  ]
}
EOF
}

resource "aws_kms_alias" "removalwatch-kmscmk-cloudwatch-alias" {
  name          = "alias/${var.aws_prefix}-kms-cloudwatch-${random_string.aws_suffix.result}"
  target_key_id = aws_kms_key.removalwatch-kmscmk-cloudwatch.key_id
}
