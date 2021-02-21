import boto3
import json
import os
import praw

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-' + os.environ['SUFFIX'])
    reddit = praw.Reddit(
        user_agent=os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-' + os.environ['SUFFIX'],
        client_id=os.environ['CLIENTID'],
        client_secret=os.environ['CLIENTSECRET']
    )

    with table.batch_writer() as batch:
        for submission in reddit.subreddit(os.environ['SUBREDDIT']).hot(limit=int(os.environ['HOTLIMIT'])):

            submission.comments.replace_more(limit=0)
            top_comments = set()
            for top_level_comment in submission.comments[0:int(os.environ['TOPLIMIT'])]:
                top_comments.add(top_level_comment.body)

            batch.put_item(
                Item={
                    'submission_id': str(submission.id),
                    'submission_title': str(submission.title),
                    'submission_comments': top_comments
                }
            )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Complete')
    }
