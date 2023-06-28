import os
from datetime import datetime

import boto3

from utility.dynamo_directory import find_directory_by_path, insert_directory_in_dynamo

table_name_resources = os.environ['RESOURCES_TABLE_NAME']


def insert_resource_in_dynamo(new_resource):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    table.put_item(Item=new_resource)


def find_resource_by_path(path):
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


def delete_resource_from_dynamo(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    table.delete_item(Key={"path": path})


def update_path_for_resource_in_dynamo(path, new_path):
    item = find_resource_by_path(path)[0]

    if new_path[-1] == "/":
        new_path = new_path[:-1]

    item['path'] = new_path + "/" + item['name'] + '.' + item['extension']
    item['timeModified'] = str(datetime.now())

    delete_resource_from_dynamo(path)
    insert_resource_in_dynamo(item)

    new_directory = find_directory_by_path(new_path)[0]
    new_directory['items'] += [item['path']]
    insert_directory_in_dynamo(new_directory)

    old_directory = find_directory_by_path("/".join(path.split("/")[:-1]))[0]
    old_directory['items'].remove(path)
    insert_directory_in_dynamo(old_directory)


def check_parent(user, path):
    if "/" not in path:
        return False

    if "." in path:
        content = find_resource_by_path(path)[0]
    else:
        content = find_directory_by_path(path)[0]
    print(content['share'])
    if user in content['share']:
        return True
    else:
        return check_parent(user, "/".join(path.split("/")[:-1]))
