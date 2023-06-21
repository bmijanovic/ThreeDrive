import json
import os

import boto3

from utility.utils import create_response

table_name = os.environ['DIRECTORIES_TABLE_NAME']


def create(event, context):
    try:
        body = json.loads(event['body'])
        path = body['path']
        name = body['name']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    try:
        create_directory(path, name)
        body = {
            'data': json.dumps('Directory creation successfull')
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


def create_directory(path, name):
    if does_directory_exist(path, name):
        raise ValueError("Directory already exist!")

    new_directory = {
        'path': path + name,
        'name': name,
        'owner': 'TODO',
        'items': [],
        'directories': [],
    }

    insert_directory_in_dynamo(new_directory)



def does_directory_exist(path, name):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
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


def insert_directory_in_dynamo(new_directory):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    table.put_item(Item=new_directory)