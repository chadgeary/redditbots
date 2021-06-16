import boto3
from boto3.dynamodb.conditions import Key, Attr
import datetime
import json
import os
from urllib3 import PoolManager
import praw

def lambda_handler(event, context):
    db = boto3.resource('dynamodb')
    table = db.Table(os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-' + os.environ['SUFFIX'])
    removedtable = db.Table(os.environ['PREFIX'] + '-' + os.environ['SUBREDDIT'] + '-removed-' + os.environ['SUFFIX'])

    # Fetch previous submissions from db
    print(str(datetime.datetime.utcnow()) + " Fetching previous submissions.")
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

    print(str(datetime.datetime.utcnow()) + " Fetching " + os.environ['HOTLIMIT'] + " from " + os.environ['SUBREDDIT'])
    current_submissions = reddit.subreddit(os.environ['SUBREDDIT']).hot(limit=int(os.environ['HOTLIMIT']))
    bot_viewed = datetime.datetime.utcnow()

    with table.batch_writer() as batch:
        position = 0
        for current_submission in current_submissions:
            position = position + 1
            print(str(datetime.datetime.utcnow()) + " Storing submission " + current_submission.id + "(" + str(position) + " of " + os.environ['HOTLIMIT'] + ")") 
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
                    'bot_viewed': str(bot_viewed),
                    'bot_position': str(position).rjust(4,'0')
                }
            )

    # Evaluate previous for removals
    for previous_submission in previous_submissions:

        print(str(datetime.datetime.utcnow()) + ' Evaluating: ' + previous_submission['id'])
        evaluate_submission = reddit.submission(previous_submission['id'])

        if evaluate_submission.author is None or evaluate_submission.is_robot_indexable is False or evaluate_submission.removed_by_category is not None or evaluate_submission.selftext == '[removed]' or evaluate_submission.selftext == '[deleted]':

            print(evaluate_submission.id + ' has been removed!')

            # Fetch previous removal
            previous_removal_check = removedtable.get_item(
                Key={'id': evaluate_submission.id }
            )

            # If no previous removal, put to removedtable
            if 'Item' not in previous_removal_check:
                print(str(datetime.datetime.utcnow()) + " " + evaluate_submission.id + " not previously stored, adding to 'removed' table.")
                removedtable.put_item(Item=previous_submission)

                # If discord webhook, post it
                if os.environ['DISCORD_WEBHOOK'] != '':

                    # Append evaluation checks to previous submission
                    eval_checks = {'eval.author': str(evaluate_submission.author), 'eval.is_robot_indexable': str(evaluate_submission.is_robot_indexable), 'eval.removed_by_category': str(evaluate_submission.removed_by_category), 'eval.selftext': str(evaluate_submission.selftext)}
                    previous_submission.update(eval_checks)
                    post_data = json.dumps({'username': 'removalwatch-r/' + os.environ['SUBREDDIT'] + '-hot' + os.environ['HOTLIMIT'], 'content': str(previous_submission)})
                    print(post_data)

                    # POST
                    post_response = PoolManager().request(
                        'POST',
                        os.environ['DISCORD_WEBHOOK'],
                        headers = {'Content-Type': 'application/json'},
                        body = post_data,
                        retries = False)
                    print(post_response.status)
                    print(post_response.data)

    return {
        'statusCode': 200,
        'body': json.dumps('Complete')
    }
