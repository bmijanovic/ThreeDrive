import json
import boto3
import hashlib
from hashlib import sha256

def lambda_handler(event, context):
    try:
        username = event['username']
        password = event['password']
        results = find_user_by_username(username)
        if (results):
            user = results[0]
            password = sha256(password.encode('utf-8')).hexdigest()
            if (user['username'] == username and user['password'] == password):
                return {
                    'statusCode': 200,
                    'body': json.dumps('Logged in successfully!')
                }
        return {
            'statusCode': 404,
            'body': json.dumps('Invalid username or password')
        }
    except (KeyError, json.decoder.JSONDecodeError):
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid request body')
        }


def find_user_by_username(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('Users')
    response = table.scan(
        FilterExpression="username = :username",
        ExpressionAttributeValues={
            ":username": username
        }
    )
    return response['Items']