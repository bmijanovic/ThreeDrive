import json

from utility.dynamo_directory import find_directory_by_path
from utility.dynamo_resources import find_resource_by_path, check_parent
from utility.utils import create_response


def check(event, context):
    try:
        path_param = event["queryStringParameters"]
        path = path_param["path"]
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    user = event['requestContext']['authorizer']['username']
    body = {
        'data': check_parent(user, path)
    }
    return create_response(200, body)



