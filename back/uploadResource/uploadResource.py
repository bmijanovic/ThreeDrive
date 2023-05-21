import json
import base64
import uuid
import boto3
import filetype
import mimetypes
from io import BytesIO
import sys
import datetime
import math

from utility.utils import create_response


def upload(event, context):
    db = boto3.client('dynamodb')
    fileBytesStr = event['image']
    fileName = event['name']
    tags = event["tags"]
    plainName = fileName
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
    table = dynamodb.Table('ResourceDetails')
    table.put_item(Item=resource_item)


def insert_resource_in_s3(fileKey, fileBytes):
    s3 = boto3.client('s3')
    s3.put_object(Bucket="resources-three-cloud", Key=f'{fileKey}', Body=fileBytes)
