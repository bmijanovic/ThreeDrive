import json
import os


from utility.utils import create_response, find_directory_by_path, \
    delete_directory_from_dynamo, delete_resource_from_s3, delete_resource_from_dynamo

table_name = os.environ['DIRECTORIES_TABLE_NAME']
s3_name = os.environ['RESOURCES_BUCKET_NAME']


def delete(event, context):
    try:
        body = json.loads(event['body'])
        path = body['path']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    try:
        delete_directory(path)
        body = {
            'data': json.dumps('Directory deleted successfully')
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


def delete_directory(path):
    directory = find_directory_by_path(path)[0]
    for i, item in enumerate(directory['items']):
        # dynamodb
        delete_resource_from_dynamo(item)
        # S3
        delete_resource_from_s3(item)

    paths = []
    for i, directory in enumerate(directory['directories']):
        paths.append(directory)

    print(path)
    delete_directory_from_dynamo(path)
    print('Deleted: ' + path)

    for p in paths:
        delete_directory(p)


