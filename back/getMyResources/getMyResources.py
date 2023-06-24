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

from utility.dynamo_directory import find_directory_by_path_and_name
from utility.utils import create_response

table_name = os.environ['RESOURCES_TABLE_NAME']
bucket_name = os.environ['RESOURCES_BUCKET_NAME']


def getMyResources(event, context):
    path_param=event["queryStringParameters"]["path"]
    directory=None
    if "/" in path_param:
        path,name=path_param.rsplit("/", 1)
        directory=find_directory_by_path_and_name(path + "/", name)
        if directory is None:
            body = {
                'data': json.dumps('Invalid request body')
            }
            return create_response(400, body)
        else:
            body = {
                'data': directory
            }
            return create_response(200, body)
    else:
        path=""
        name=path_param
        directory = find_directory_by_path_and_name(path, name)
        if directory is None:
            body = {
                'data': json.dumps('Invalid request body')
            }
            return create_response(400, body)
        else:
            body = {
                'data': directory
            }
            return create_response(200, body)



