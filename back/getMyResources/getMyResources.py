import json
import base64
import os
import uuid
import boto3
import filetype
import mimetypes
from io import BytesIO
import sys
import datetime
import math

from utility.utils import create_response

table_name = os.environ['RESOURCES_TABLE_NAME']
bucket_name = os.environ['RESOURCES_BUCKET_NAME']


def upload(event, context):
    try:
        db = boto3.client('dynamodb')
        body = json.loads(event['body'])
        fileBytesStr = body['image']
        fileName = body['name']
        tags = body["tags"]
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
    fileKey = str(uuid.uuid4())
    if ext is not None:
        fileName += "." + ext
        fileKey += "." + ext

    resource_item = {
        'id': str(uuid.uuid4()),
        'name': plainName,
        'extension': str(ext),
        'mime': type,
        'resource_id': fileKey,
        'size': size,
        'owner': "TODO",
        'timeUploaded': str(datetime.datetime.now()),
        'timeModified': str(datetime.datetime.now()),
        'share': []
    }
    for tag in tags:
        resource_item[tag['key']] = tag['value']
    insert_resource_in_s3(fileKey, fileBytes)
    insert_resource_in_dynamo(resource_item)
    print("AAA")

    body = {
        'data': "File Uploaded"
    }
    return create_response(200, body)
    # return {
    #     'statusCode': 200,
    #     'body': "File Uploaded"
    # }


def insert_resource_in_dynamo(resource_item):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    table.put_item(Item=resource_item)


def insert_resource_in_s3(fileKey, fileBytes):
    s3 = boto3.client('s3')
    s3.put_object(Bucket=bucket_name, Key=f'{fileKey}', Body=fileBytes)
