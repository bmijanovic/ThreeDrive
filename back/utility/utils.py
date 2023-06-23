import json
import os
import boto3

table_name_directory = os.environ['DIRECTORIES_TABLE_NAME']
table_name_users = os.environ['USERS_TABLE_NAME']
table_name_resources = os.environ['RESOURCES_TABLE_NAME']
SECRET_KEY = 'pamuk'



def create_response(status, body):
    return {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:8888',
        },
        'body': json.dumps(body, default=str)
    }


def find_directory_by_path_and_name(path, name):
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



def find_directory_by_path(path):
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


def insert_directory_in_dynamo(new_directory):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    table.put_item(Item=new_directory)


def find_file_by_path(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
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