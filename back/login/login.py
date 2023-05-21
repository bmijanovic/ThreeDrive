import json
import os

import boto3
import hashlib
from hashlib import sha256
from utility.utils import create_response

table_name = os.environ['USERS_TABLE_NAME']


def login(event, context):
    try:
        body = json.loads(event['body'])
        username = body['username']
        password = body['password']
        results = find_user_by_username(username)
        if results:
            user = results[0]
            password = sha256(password.encode('utf-8')).hexdigest()
            if user['username'] == username and user['password'] == password:
                body = {
                    'data': json.dumps('Logged in successfully')
                }
                return create_response(200, body)
                # return {
                #     'statusCode': 200,
                #     'body': json.dumps('Logged in successfully!')
                # }
        body = {
            'data': json.dumps('Invalid username or password')
        }
        return create_response(404, body)
        # return {
        #     'statusCode': 404,
        #     'body': json.dumps('Invalid username or password')
        # }
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)
        # return {
        #     'statusCode': 400,
        #     'body': json.dumps('Invalid request body')
        # }


def find_user_by_username(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    response = table.scan(
        FilterExpression="username = :username",
        ExpressionAttributeValues={
            ":username": username
        }
    )
    return response['Items']
