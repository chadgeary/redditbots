# Overview
`sentiment` is a service to periodically scrape (sub)reddit posts' top comments, evaluate sentiment (positive, neutral, negative, mixed) if a comment containts target word(s) and store the results. Deployed automatically via Terraform, `sentiment` uses Cloudwatch EventBridge (scheduler), Lambda (execution), Comprehend (sentiment), and DynamoDB (storage). Lambda interfaces with reddit via the `praw` python module.

![DynamoDBConsole](dynamodbconsole.png)

# Requirements
- AWS Account with an Admin IAM user set, e.g.: `file ~/.aws/credentials`
- [Reddit App clientid + secret](https://github.com/reddit-archive/reddit/wiki/OAuth2-Quick-Start-Example#first-steps)
- [Terraform installed](https://www.terraform.io/downloads.html)
- python3 pip
- this directory

# Deploy
```
# Clone and change directory
git clone https://github.com/chadgeary/redditbots && cd redditbots/sentiment

# Create function directory, copy sentiment.py, install praw module
mkdir -p ./function
cp sentiment.py ./function
pip3 install --upgrade --target ./function/ praw

# Customize variables
cat aws.tfvars

# Initialize terraform and apply
terraform init
terraform apply -var-file="aws.tfvars"

# After apply, see terraform output for useful AWS console links, or
terraform output
```
