import os
import boto3

table_name_resources = os.environ['RESOURCES_TABLE_NAME']


def insert_file_in_dynamo(new_resource):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    table.put_item(Item=new_resource)


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


def delete_resource_from_dynamo(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    table.delete_item(Key={"path": path})