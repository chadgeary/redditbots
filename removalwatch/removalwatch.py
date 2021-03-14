import boto3
from boto3.dynamodb.conditions import Key, Attr
import datetime
import json
import os
import praw

def lambda_handler(event, context):
    db = boto3.resource('dynamodb')
    table = db.Table(os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-' + os.environ['SUFFIX'])

    removeddb = boto3.resource('dynamodb')
    removedtable = removeddb.Table(os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-removed-' + os.environ['SUFFIX'])

    # Fetch previous submissions from db
    response = table.scan()
    previous_submissions = response['Items']
    while response.get('LastEvaluatedKey'):
        response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
        previous_submissions.extend(response['Items'])

    # Fetch new submissions from reddit, put to db
    reddit = praw.Reddit(
        user_agent=os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-' + os.environ['SUFFIX'],
        client_id=os.environ['CLIENTID'],
        client_secret=os.environ['CLIENTSECRET']
    )

    with table.batch_writer() as batch:
        position = 0
        for current_submission in reddit.subreddit(os.environ['SUBREDDIT']).hot(limit=int(os.environ['HOTLIMIT'])):

            position = position + 1
            if position <= 1:
                print(current_submission.author.name)
                print(current_submission.is_robot_indexable)
                print(current_submission.removed_by_category)
                print(current_submission.selftext)

            batch.put_item(
                Item={
                    'id': str(current_submission.id),
                    'title': str(current_submission.title),
                    'topcomment': str(current_submission.comments[0].body),
                    'author': str(current_submission.author.name) if current_submission.author is not None else '[deleted]',
                    'is_self': str(current_submission.is_self),
                    'text': str(current_submission.selftext),
                    'url': str(current_submission.url),
                    'subreddit': str(current_submission.subreddit.display_name),
                    'bot_viewed': str(datetime.datetime.now()),
                    'bot_position': str(position).rjust(4,'0')
                }
            )

    # Evaluate previous for removals
    for previous_submission in previous_submissions:

        print('Evaluating ' + previous_submission['id'])
        evaluate_submission = reddit.submission(previous_submission['id'])

        if evaluate_submission.author is None or evaluate_submission.is_robot_indexable is False or evaluate_submission.removed_by_category is not None or evaluate_submission.selftext == '[removed]' or evaluate_submission.selftext == '[deleted]':
            print(evaluate_submission)
            removedtable.put_item(Item=previous_submission)

    return {
        'statusCode': 200,
        'body': json.dumps('Complete')
    }
