resource "aws_kms_key" "sentiment-kms-lambda" {
  description             = "KMS CMK for Lambda"
  key_usage               = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation     = "true"
  tags                    = {
    Name                  = "${var.aws_prefix}-kmscmk-lambda-${random_string.aws_suffix.result}"
  }
  policy                  = <<EOF
{
  "Id": "sentiment-kms-lambda",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Enable Lambda",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.sentiment-role-lambda.arn}"
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
        "StringEquals": {
          "kms:CallerAccount": "${data.aws_caller_identity.aws-account.account_id}"
        }
      }
    },
    {
      "Sid": "Enable KMS Manager Use",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_iam_user.aws-kmsmanager.arn}"
      },
      "Action": "kms:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_kms_alias" "sentiment-kms-lambda-alias" {
  name                    = "alias/${var.aws_prefix}-kmscmk-lambda-${random_string.aws_suffix.result}"
  target_key_id           = aws_kms_key.sentiment-kms-lambda.key_id
}
