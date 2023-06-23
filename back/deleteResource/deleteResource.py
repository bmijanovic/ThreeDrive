import json
import os
import boto3

from utility.utils import create_response, find_file_by_path, find_directory_by_path

directories_table_name = os.environ['DIRECTORIES_TABLE_NAME']
resources_table_name = os.environ['RESOURCES_TABLE_NAME']
resources_bucket_name = os.environ['RESOURCES_BUCKET_NAME']

def delete(event, context):
    try:
        path = event["queryStringParameters"]["path"]
        resource = find_file_by_path(path)[0] #TODO needs to be secured

        head = os.path.split(path)[0]
        directory = find_directory_by_path(head)[0] #TODO needs to be secured
        items = directory['items']
        items.remove(path)

        if resource['owner'] != event['requestContext']['authorizer']['username']:
            body = {
                'data': json.dumps('Invalid request body')
            }
            return create_response(400, body)

        update_parent_directory_items(head, items)
        delete_resource_from_dynamo(resource['path'])
        delete_resource_from_s3(resource['path'])

        body = {
            'data': "File Deleted"
        }
        return create_response(200, body)
    except ():
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

def delete_resource_from_dynamo(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(resources_table_name)
    table.delete_item(Key={"path": path})

def delete_resource_from_s3(path):
    s3 = boto3.client('s3')
    s3.delete_object(Bucket=resources_bucket_name, Key=f'{path}')

def update_parent_directory_items(path, resources):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(directories_table_name)
    table.update_item(
        Key={'path': path},
        UpdateExpression='SET #resources = :val',
        ExpressionAttributeValues={':val': resources},
        ExpressionAttributeNames={'#resources':'items'}
    )