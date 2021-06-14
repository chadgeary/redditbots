# Short alpha-numeric label for created AWS resources
aws_prefix = "watch"
aws_region = "us-east-1"

# Authentication profile, not root
aws_profile = "default"
kms_manager = "some_username"

# Pick a subreddit (or use "all")
reddit_subreddit = "all"

# number of submissions to read from subreddit
reddit_hotlimit = "100"

# number of top comments to read from each submission
comment_toplimit = "1"

# DynamoDB reads/writes per second, see: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html#HowItWorks.ProvisionedThroughput.Manual
dynamo_readcapacity         = 10
dynamo_writecapacity        = 10
dynamodeleted_readcapacity  = 5
dynamodeleted_writecapacity = 5

# How often to invoke the function
schedule_unit       = "minutes"
schedule_count      = 10
function_memory     = 384
function_timeoutsec = "360"

# Reddit app credentials, see: https://github.com/reddit-archive/reddit/wiki/OAuth2-Quick-Start-Example#first-steps
praw_clientid     = "replaceme1"
praw_clientsecret = "replaceme2"
