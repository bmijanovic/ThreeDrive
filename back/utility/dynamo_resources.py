import os
import boto3

from utility.dynamo_directory import find_directory_by_path

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
