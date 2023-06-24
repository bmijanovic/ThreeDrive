import json

import utility.utils
from utility.utils import create_response


def share(event, context):
    try:
        body = json.loads(event['body'])
        path = body['path']
        type = body['type']
        username = body['username']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    # user = event['requestContext']['authorizer']['username']
    user = None
    try:
        share_content(user, path, type, username)
        body = {
            'data': json.dumps('Content successfully shared')
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


def share_content(user, path, type, username):
    content = None
    if type == 'DIRECTORY':
        content = utility.utils.find_directory_by_path(path)
    elif type == 'RESOURCE':
        content = utility.utils.find_file_by_path(path)
    else:
        raise ValueError("Wrong type")

    if content is None:
        raise ValueError("Invalid request body")
    content = content[0]
    # if content['owner'] != user:
    #     raise ValueError("Invalid request body")

    content['share'] += [username]

    if type == 'DIRECTORY':
        utility.utils.insert_directory_in_dynamo(content)
    elif type == 'RESOURCE':
        utility.utils.insert_file_in_dynamo(content)
    else:
        raise ValueError("Wrong type")
