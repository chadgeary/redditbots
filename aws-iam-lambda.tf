data "aws_iam_policy" "mineddit-lambda-policy-1" {
  arn                     = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "mineddit-lambda-policy-2" {
  name                    = "${var.aws_prefix}-lambda-policy-${random_string.aws_suffix.result}"
  path                    = "/"
  description             = "Lambda Dynamo and KMS"
  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaKMS",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.mineddit-kms-lambda.arn}"]
    },
    {
      "Sid": "LambdaDynamo",
      "Effect": "Allow",
      "Action": [
        "dynamodb:BatchWriteItem",
        "dynamodb:ConditionCheckItem",
        "dynamodb:PutItem",
        "dynamodb:DescribeTable",
        "dynamodb:Scan"
      ],
      "Resource": ["${aws_dynamodb_table.mineddit-dynamodb.arn}"]
    },
    {
      "Sid": "LambdaComprehend",
      "Effect": "Allow",
      "Action": [
        "comprehend:DetectDominantLanguage",
        "comprehend:DetectSentiment"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

# Lambda Role
resource "aws_iam_role" "mineddit-role-lambda" {
  name                    = "${var.aws_prefix}-role-lambda-${random_string.aws_suffix.result}"
  path                    = "/"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "sts:AssumeRole",
          "Principal": {
             "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
      }
  ]
}
EOF
}

# Lambda Role Attachments
resource "aws_iam_role_policy_attachment" "mineddit-lambda-policy-1-attach" {
  role                    = aws_iam_role.mineddit-role-lambda.name
  policy_arn              = data.aws_iam_policy.mineddit-lambda-policy-1.arn
}

resource "aws_iam_role_policy_attachment" "mineddit-lambda-policy-2-attach" {
  role                    = aws_iam_role.mineddit-role-lambda.name
  policy_arn              = aws_iam_policy.mineddit-lambda-policy-2.arn
}
