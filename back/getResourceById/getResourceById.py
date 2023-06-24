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

from utility.utils import create_response, find_file_by_path, get_resource_from_s3

table_name = os.environ['RESOURCES_TABLE_NAME']
bucket_name = os.environ['RESOURCES_BUCKET_NAME']

def getResourceById(event, context):
    path=event["queryStringParameters"]["path"]
    file = get_resource_from_s3(path)
    if file is None:
        body = {
            'data': json.dumps('There is no such resource!')
        }
        return create_response(400, body)
    body = {
        'data':file
    }
    return create_response(200, body)



