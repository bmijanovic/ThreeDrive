import base64
import json
import os
import boto3
import datetime

from utility.dynamo_directory import find_directory_by_path, insert_directory_in_dynamo
from utility.dynamo_resources import insert_resource_in_dynamo
from utility.s3_resources import insert_resource_in_s3

upload_sns_topic_arn = os.environ['UPLOAD_SNS_TOPIC_ARN']


def processUpload(event, context):
    sqs_records = event['Records']
    for record in sqs_records:
        sqs_message = json.loads(record['body'])
        resource_item = sqs_message['resource_item']
        fileKey = sqs_message['fileKey']
        fileBytes = sqs_message['fileBytes']
        path = sqs_message['path']

        fileBytes = bytes(base64.b64decode(fileBytes))

        # insert_resource_in_s3(fileKey, fileBytes)
        # insert_resource_in_dynamo(resource_item)

        parent_directory = find_directory_by_path(path)[0]
        if 'items' in parent_directory:
            parent_directory['items'] += [fileKey]
        else:
            parent_directory['items'] = [fileKey]
        parent_directory['time_updated'] = str(datetime.datetime.now().time())

        # insert_directory_in_dynamo(parent_directory)

        sns = boto3.client('sns')
        sns.publish(
            TopicArn=upload_sns_topic_arn,
            Message='File uploaded successfully!',
            Subject='File upload'
        )
