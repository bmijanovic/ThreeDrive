import json

from utility.dynamo_directory import find_directory_by_path
from utility.dynamo_resources import update_path_for_resource_in_dynamo, find_resource_by_path
from utility.s3_resources import update_s3_key
from utility.utils import create_response


def moving(event, context):
    try:
        body = json.loads(event['body'])
        path = body['path']
        new_path = body['new_path']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    user = event['requestContext']['authorizer']['username']
    user = None

    try:
        move(path, new_path, user)
        body = {
            'data': json.dumps('Content successfully moved')
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


def move(path, new_path, user):
    if "." in path:
        content = find_resource_by_path(path)
    else:
        raise ValueError("Directory cannot be moved")

    if content is None:
        raise ValueError("Content does not exist")

    content = content[0]

    if content['owner'] != user:
        raise ValueError("Invalid request body")

    update_path_for_resource_in_dynamo(path, new_path)
    new_path = new_path + "/" + content['name'] + '.' + content['extension']
    update_s3_key(path, new_path)


