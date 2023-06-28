import json
import os
import uuid

import boto3

SECRET_KEY = 'pamuk'


def create_response(status, body):
    return {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:8888',
        },
        'body': json.dumps(body, default=str)
    }
