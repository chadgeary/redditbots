provider "aws" {
  region                  = var.aws_region
  profile                 = var.aws_profile
}

variable "aws_prefix" {
  type                    = string
}

resource "random_string" "aws_suffix" {
  length                  = 5
  upper                   = false
  special                 = false
}

variable "aws_profile" {
  type                    = string
}

variable "aws_region" {
  type                    = string
}

variable "kms_manager" {
  type                    = string
  description             = "An IAM user for management of KMS key"
}

data "aws_caller_identity" "aws-account" {
}

data "aws_iam_user" "aws-kmsmanager" {
  user_name               = var.kms_manager
}

variable "reddit_subreddit" {
  type                    = string
}

variable "reddit_hotlimit" {
  type                    = number
}

variable "comment_toplimit" {
  type                    = number
}

variable "praw_clientid" {
  type                    = string
}

variable "praw_clientsecret" {
  type                    = string
}

variable "comprehend_charlimit" {
  type                    = number
}

variable "dynamo_readcapacity" {
  type                    = number
}

variable "dynamo_writecapacity" {
  type                    = number
}

variable "schedule_count" {
  type                    = number
}

variable "schedule_unit" {
  type                    = string
}

variable "function_memory" {
  type                    = number
}
