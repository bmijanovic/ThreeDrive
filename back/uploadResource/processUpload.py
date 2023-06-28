import base64
import json
import os
import boto3
import datetime

from utility.dynamo_directory import find_directory_by_path, insert_directory_in_dynamo
from utility.dynamo_resources import insert_resource_in_dynamo, delete_resource_from_dynamo
from utility.dynamo_users import find_user_by_username
from utility.s3_resources import insert_resource_in_s3, delete_resource_from_s3

resource_sns_topic_arn = os.environ['RESOURCE_SNS_TOPIC_ARN']
sns = boto3.client('sns')

def processUpload(event, context):
    sqs_records = event['Records']
    for record in sqs_records:
        sqs_message = json.loads(record['body'])
        owner_username = sqs_message['owner']
        resource_item = sqs_message['resource_item']
        fileKey = sqs_message['fileKey']
        fileBytes = sqs_message['fileBytes']
        path = sqs_message['path']
        fileBytes = bytes(base64.b64decode(fileBytes))

        user = find_user_by_username(owner_username)
        if user is None:
            return
        user = user[0]

        try:
            insert_resource_in_s3(fileKey, fileBytes)
        except:
            sns.publish(
                TopicArn=resource_sns_topic_arn,
                Message=json.dumps({
                    "receiver":user['email'],
                    "subject":'File upload failed!',
                    "content":'Your file ' + fileKey.split("/")[-1] + ' upload has failed!'
                }),
                Subject='File upload'
            )

        try:
            insert_resource_in_dynamo(resource_item)
        except:
            delete_resource_from_s3(fileKey)
            sns.publish(
                TopicArn=resource_sns_topic_arn,
                Message=json.dumps({
                    "receiver":user['email'],
                    "subject":'File upload failed!',
                    "content":'Your file ' + fileKey.split("/")[-1] + ' upload has failed!'
                }),
                Subject='File upload'
            )

        parent_directory = find_directory_by_path(path)[0]
        if 'items' in parent_directory:
            parent_directory['items'] += [fileKey]
        else:
            parent_directory['items'] = [fileKey]
        parent_directory['time_updated'] = str(datetime.datetime.now().time())

        try:
            insert_directory_in_dynamo(parent_directory)
        except:
            delete_resource_from_s3(fileKey)
            delete_resource_from_dynamo(path)
            sns.publish(
                TopicArn=resource_sns_topic_arn,
                Message=json.dumps({
                    "receiver":user['email'],
                    "subject":'File upload failed!',
                    "content":'Your file ' + fileKey.split("/")[-1] + ' upload has failed!'
                }),
                Subject='File upload'
            )

        sns.publish(
            TopicArn=resource_sns_topic_arn,
            Message=json.dumps({
                "receiver":user['email'],
                "subject":'File uploaded successfully!',
                "content":'Your file ' + fileKey.split("/")[-1] + ' has been uploaded successfully!'
            }),
            Subject='File upload'
        )