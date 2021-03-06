import boto3
import json
import os
import praw

comprehend = boto3.client('comprehend')

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
            comments_and_sentiments = {}
            for top_level_comment in submission.comments[0:int(os.environ['TOPLIMIT'])]:

                # Get AWS Comprehend sentiment on first 1700 characters (AWS Comprehend Limit + AWS Comprehend Billing Unit + UTF8 max character size of 4 byte)
                sentiment = comprehend.detect_sentiment(Text=top_level_comment.body[:int(os.environ['COMPREHENDCHARLIMIT'])],LanguageCode='en')['Sentiment']

                # Comment and Sentiment into dict
                comments_and_sentiments[top_level_comment.body] = str(sentiment)

            batch.put_item(
                Item={
                    'submission_id': str(submission.id),
                    'submission_title': str(submission.title),
                    'submission_comments': comments_and_sentiments
                }
            )
    
    return {
        'statusCode': 200,
        'body': json.dumps('Complete')
    }
