import datetime
import json
import os

import boto3

from utility.utils import create_response, does_directory_exist, find_directory

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
            'data': json.dumps('Directory creation successfully')
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

    time = datetime.datetime.now().time()

    new_directory = {
        'path': path + name,
        'name': name,
        'owner': 'TODO',
        'items': [],
        'directories': [],
        'time_created': str(time),
        'time_updated': str(time)
    }

    insert_directory_in_dynamo(new_directory)

    if len(path.split("/")) < 2:
        return

    parent_directory = find_directory(path[:-1])[0]

    parent_directory['directories'] += [new_directory['path']]
    parent_directory['time_updated'] = str(time)

    insert_directory_in_dynamo(parent_directory)


def update_parent(id, list):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    table.update_item(
        Key={'id': id},
        UpdateExpression='SET directories = :val',
        ExpressionAttributeValues={':val': list}
    )


def insert_directory_in_dynamo(new_directory):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    table.put_item(Item=new_directory)


def find_directory_by_path(email):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    response = table.scan(
        FilterExpression="email = :email",
        ExpressionAttributeValues={
            ":email": email
        }
    )
    return response['Items']
