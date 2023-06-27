import base64
import datetime
import json
import os
import sys

import boto3
import filetype

from utility.dynamo_resources import find_resource_by_path
from utility.utils import create_response

table_name = os.environ['RESOURCES_TABLE_NAME']
bucket_name = os.environ['RESOURCES_BUCKET_NAME']
upload_sqs_queue_name = os.environ['UPLOAD_SQS_QUEUE_NAME']

def beginUpload(event, context):
    try:
        db = boto3.client('dynamodb')
        body = json.loads(event['body'])
        fileBytesStr = body['image']
        fileName = body['name']
        tags = body["tags"]
        path = body['path']
        plainName = fileName
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)
    file_b64dec = base64.b64decode(fileBytesStr)
    fileBytes = bytes(file_b64dec)

    size = sys.getsizeof(fileBytes)
    ext = filetype.guess_extension(fileBytes)
    type = filetype.guess_mime(fileBytes)
    fileKey = path+"/"+fileName
    if ext is not None:
        fileName += "." + ext
        fileKey += "." + ext

    if find_resource_by_path(fileKey):
        body = {
            'data': json.dumps('File Already Exist')
        }
        return create_response(400, body)

    resource_item = {
        'path': fileKey,
        'name': plainName,
        'extension': str(ext),
        'mime': type,
        'resource_id': fileKey,
        'size': size,
        'owner': event['requestContext']['authorizer']['username'],
        'timeUploaded': str(datetime.datetime.now()),
        'timeModified': str(datetime.datetime.now()),
        'share': []
    }
    for tag in tags:
        resource_item[tag['key']] = tag['value']

    sqs = boto3.client('sqs')
    queue_url = sqs.get_queue_url(QueueName=upload_sqs_queue_name)['QueueUrl']
    message = {
        'owner': event['requestContext']['authorizer']['username'],
        'resource_item': resource_item,
        'fileKey': fileKey,
        'fileBytes': base64.b64encode(fileBytes).decode('utf-8'),
        'path': path
    }
    sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(message)
    )

    body = {
        'data': "Uploading process started"
    }
    return create_response(200, body)


