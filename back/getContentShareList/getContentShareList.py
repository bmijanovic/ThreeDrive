import json

from utility.dynamo_directory import find_directory_by_path
from utility.dynamo_resources import find_file_by_path
from utility.utils import create_response


def get_list(event, context):
    try:
        path_param = event["queryStringParameters"]
        path = path_param["path"]
        type = path_param["type"]

    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    user = event['requestContext']['authorizer']['username']
    # user = None
    print(path, type)
    try:
        if type == 'DIRECTORY':
            content = find_directory_by_path(path)
        elif type == 'RESOURCE':
            content = find_file_by_path(path)
        else:
            raise ValueError("Wrong type")

        if content is None:
            raise ValueError("Invalid request body")
        content = content[0]
        if content['owner'] != user:
            raise ValueError("Invalid request body")
        body = {
            'data': content['share']
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)