import json
import os
import boto3

from utility.dynamo_directory import find_directory_by_path
from utility.dynamo_resources import find_resource_by_path, delete_resource_from_dynamo, insert_resource_in_dynamo
from utility.dynamo_users import find_user_by_username
from utility.s3_resources import delete_resource_from_s3
from utility.utils import create_response

directories_table_name = os.environ['DIRECTORIES_TABLE_NAME']
resources_table_name = os.environ['RESOURCES_TABLE_NAME']
resources_bucket_name = os.environ['RESOURCES_BUCKET_NAME']
resource_sns_topic_arn = os.environ['RESOURCE_SNS_TOPIC_ARN']
sns = boto3.client('sns')


def delete(event, context):
    try:
        path = event["queryStringParameters"]["path"]

        resource = find_resource_by_path(path)
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

        try:
            delete_resource_from_dynamo(resource['path'])
        except:
            update_parent_directory_items(head, directory['items'])

        try:
            delete_resource_from_s3(resource['path'])
        except:
            update_parent_directory_items(head, directory['items'])
            insert_resource_in_dynamo(resource)

        user = find_user_by_username(resource['owner'])
        if user is not None:
            user = user[0]
            sns.publish(
                TopicArn=resource_sns_topic_arn,
                Message=json.dumps({
                    "receiver": user['email'],
                    "subject": 'File deleted successfully!',
                    "content": 'Your file ' + resource['path'].split("/")[-1] + ' has been deleted successfully!'
                }),
                Subject='File Delete'
            )

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
        ExpressionAttributeNames={'#resources': 'items'}
    )
