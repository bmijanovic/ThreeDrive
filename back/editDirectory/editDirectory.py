import datetime
import json
import os

import boto3

from utility.utils import create_response, find_directory_by_path_and_name, find_directory_by_path, \
    insert_file_in_dynamo, find_file_by_path, update_s3_key, insert_directory_in_dynamo, delete_item_from_dynamo

table_name = os.environ['DIRECTORIES_TABLE_NAME']
s3_name = os.environ['RESOURCES_BUCKET_NAME']


def edit(event, context):
    try:
        body = json.loads(event['body'])
        path = body['path']
        name = body['name']
        new_name = body['newName']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    try:
        edit_directory(path, name, new_name)
        body = {
            'data': json.dumps('Directory edited successfully')
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


def edit_directory(path, name, new_name):
    if find_directory_by_path_and_name(path, new_name):
        raise ValueError("Directory already exist!")

    time = str(datetime.datetime.now().time())
    print(time)
    first = True
    level = len(path.split('/')) - 1
    edit_item(level, first, path, name, new_name, time)


def make_path(path, level, new_name):
    slices = path.split('/')
    slices[level] = new_name
    return "/".join(slices)


def edit_item(level, first, path, name, new_name, time):
    old_directory = find_directory_by_path(path)[0]
    old_path = old_directory['path']
    old_directory['path'] = make_path(path, level, new_name)
    if first:
        old_directory['name'] = new_name
        first = False

    old_directory['time_updated'] = time

    for i, item in enumerate(old_directory['items']):
        # dynamodb
        file = find_file_by_path(item)[0]
        file['path'] = make_path(path, level, new_name)
        file['timeModified'] = time
        file['resource_id'] = file['resource_id'].replace(name, new_name)
        insert_file_in_dynamo(file)

        # S3
        update_s3_key(item, make_path(item, level, new_name))

        # local
        old_directory['items'][i] = make_path(item, level, new_name)

    for i, directory in enumerate(old_directory['directories']):
        edit_item(level, first, directory, name, new_name, time)
        old_directory['directories'][i] = make_path(directory, level, new_name)

    insert_directory_in_dynamo(old_directory)
    delete_item_from_dynamo(old_path)
