import json
import os
import boto3

table_name_directory = os.environ['DIRECTORIES_TABLE_NAME']
table_name_users = os.environ['USERS_TABLE_NAME']
SECRET_KEY = 'pamuk'



def create_response(status, body):
    return {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:8888',
        },
        'body': json.dumps(body, default=str)
    }


def does_directory_exist(path, name):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    response = table.scan(
        FilterExpression="#p = :paths",
        ExpressionAttributeNames={
            "#p": "path"
        },
        ExpressionAttributeValues={
            ":paths": path + name
        }
    )
    return response['Items']



def find_directory(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    response = table.scan(
        FilterExpression="#p = :paths",
        ExpressionAttributeNames={
            "#p": "path"
        },
        ExpressionAttributeValues={
            ":paths": path
        }
    )
    return response['Items']


def find_user_by_username(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_users)
    response = table.scan(
        FilterExpression="username = :username",
        ExpressionAttributeValues={
            ":username": username
        }
    )
    return response['Items']