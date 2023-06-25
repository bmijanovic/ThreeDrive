import json

from utility.dynamo_directory import find_directory_by_path
from utility.dynamo_resources import find_file_by_path
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


def check_parent(user, path):
    print(path)
    if "/" not in path:
        return False

    if "." in path:
        content = find_file_by_path(path)[0]
    else:
        content = find_directory_by_path(path)[0]
    print(content['share'])
    if user in content['share']:
        return True
    else:
        return check_parent(user, "/".join(path.split("/")[:-1]))

