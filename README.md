# Overview
Mineddit is a serverless tool to scrape reddit post top comments, evaluate sentiment (positive, neutral, negative, mixed) and store the results. Mineddit uses Cloudwatch EventBridge, Lambda, Comprehend, and DynamoDB - deployed via Terraform. Reddit is scraped with the `praw` python module.

![DynamoDBConsole](dynamodbconsole.png)

# Requirements
- AWS Account with an Admin IAM user set, e.g.: `file ~/.aws/credentials`
- [Reddit App](https://github.com/reddit-archive/reddit/wiki/OAuth2-Quick-Start-Example#first-steps) clientid + clientsecret
- Terraform installed

# Deploy
```
# Create function directory, copy .py, install praw module
mkdir -p ./mineddit
cp mineddit.py ./mineddit
pip3 install --upgrade --target ./mineddit/ praw

# Customize variables
cat aws.tfvars

# Initialize terraform and apply
terraform init
terraform apply -var-file="aws.tfvars"
```
