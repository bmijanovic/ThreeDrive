import json
import os
import boto3

from utility.dynamo_directory import find_directory_by_path
from utility.dynamo_resources import find_file_by_path, delete_resource_from_dynamo
from utility.s3_resources import delete_resource_from_s3
from utility.utils import create_response

directories_table_name = os.environ['DIRECTORIES_TABLE_NAME']
resources_table_name = os.environ['RESOURCES_TABLE_NAME']
resources_bucket_name = os.environ['RESOURCES_BUCKET_NAME']

def delete(event, context):
    try:
        path = event["queryStringParameters"]["path"]

        resource = find_file_by_path(path)
        if resource is None:
            return create_response(400, {'data': json.dumps('Resource does not exist')})
        resource = resource[0]
        if resource['owner'] != event['requestContext']['authorizer']['username']:
            return create_response(400, {'data': json.dumps('Resource does not exist')})

        head = os.path.split(path)[0]
        directory = find_directory_by_path(head)
        if directory is None:
            return create_response(400, {'data': json.dumps('Directory does not exist')})
        directory = directory[0]

        items = directory['items']
        items.remove(path)
        update_parent_directory_items(head, items)
        delete_resource_from_dynamo(resource['path'])
        delete_resource_from_s3(resource['path'])

        body = {
            'data': "File Deleted"
        }
        return create_response(200, body)
    except:
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)



def update_parent_directory_items(path, resources):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(directories_table_name)
    table.update_item(
        Key={'path': path},
        UpdateExpression='SET #resources = :val',
        ExpressionAttributeValues={':val': resources},
        ExpressionAttributeNames={'#resources':'items'}
    )