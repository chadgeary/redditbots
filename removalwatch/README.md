# Overview
`removalwatch` is a service to periodically check for removed posts and store the removals. Deployed automatically via Terraform, `removalwatch` uses Cloudwatch EventBridge (scheduler), Lambda (execution), and DynamoDB (storage). Lambda interfaces with Reddit via the `praw` python module.

# Requirements
- AWS Account with an Admin IAM user set, e.g.: `file ~/.aws/credentials`
- [Reddit App clientid + secret](https://github.com/reddit-archive/reddit/wiki/OAuth2-Quick-Start-Example#first-steps)
- [Terraform installed](https://www.terraform.io/downloads.html)
- python3 pip
- this directory

# Deploy
```
# Clone and change directory
git clone https://github.com/chadgeary/redditbots && cd redditbots/removalwatch

# Create function directory, copy removalwatch.py, install praw module
mkdir -p ./function
cp removalwatch.py ./function
pip3 install --upgrade --target ./function/ praw

# Customize variables
cat aws.tfvars

# Initialize terraform and apply
terraform init
terraform apply -var-file="aws.tfvars"

# After apply, see terraform output for useful AWS console links, or
terraform output
```

# Contact Me
https://discord.gg/paNwty8zXV
