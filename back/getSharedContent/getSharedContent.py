import boto3

from utility.dynamo_directory import table_name_directory
from utility.dynamo_resources import table_name_resources
from utility.utils import create_response


def get_content(event, context):
    user = event['requestContext']['authorizer']['username']
    directories = find_shared_content_for_user(user, table_name_directory)
    resources = find_shared_content_for_user(user, table_name_resources)

    key = 'path'
    directories = [item[key] for item in directories if key in item]
    resources = [item[key] for item in resources if key in item]

    for resource in resources:
        for directory in directories:
            if directory in resource:
                resources.remove(resource)

    body = {
        'directories': directories,
        'resources': resources
    }
    return create_response(200, body)


def find_shared_content_for_user(user, table):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table)
    response = table.scan(
        ProjectionExpression='#p',
        FilterExpression='contains(#listOfStrings, :searchString)',
        ExpressionAttributeNames={
            '#p': 'path',
            '#listOfStrings': 'share'
        },
        ExpressionAttributeValues={
            ':searchString': user
        }
    )
    return response['Items']
