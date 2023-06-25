import base64
import datetime
import json
import os
from datetime import datetime

import boto3
import filetype

from utility.dynamo_directory import find_directory_by_path_and_name, find_directory_by_path, \
    insert_directory_in_dynamo, delete_directory_from_dynamo
from utility.dynamo_resources import find_file_by_path, insert_file_in_dynamo, delete_resource_from_dynamo
from utility.s3_resources import update_s3_key, delete_resource_from_s3, insert_resource_in_s3
from utility.utils import create_response

table_name = os.environ['DIRECTORIES_TABLE_NAME']
s3_name = os.environ['RESOURCES_BUCKET_NAME']


# name,path,image,tags
def editResource(event, context):
    try:
        body = json.loads(event['body'])
        path = body['path']
        name = body['name']
        image = body['image']
        tags = body['tags']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    file = find_file_by_path(path)
    if len(file) == 0:
        return create_response(400, {'data': json.dumps('Invalid request bodyY')})
    file=file[0]
    slices = path.split('/')
    old_name = slices[len(slices) - 1].rsplit('.', 1)[0]  # TODO DOES ALWAYS HAS EXTENSION
    if name != old_name:
        file['name']=name
        ext="."+path.rsplit('.', 1)[1]
        if image!= "":
            file_b64dec = base64.b64decode(image)
            file_bytes = bytes(file_b64dec)
            if ext is not None:
                ext = "."+filetype.guess_extension(file_bytes)
            else:
                ext=""

        existing_file = find_file_by_path(path.rsplit('/', 1)[0] + "/" + name + ext)
        if len(existing_file) > 0:
            return create_response(400, {'data': json.dumps('File with same name exist in folder')})

        directory = find_directory_by_path(path.rsplit('/', 1)[0])[0]
        directory['items'].remove(path)
        directory['items'] += [path.rsplit('/', 1)[0] + "/" + name + ext]
        insert_directory_in_dynamo(directory)

        file['path'] = path.rsplit('/', 1)[0] + "/" + name + ext
        file['timeModified'] = str(datetime.now())

        file['resource_id'] = path.rsplit('/', 1)[0]+"/"+ name+ext

        delete_resource_from_dynamo(path)
        if image=="":
            update_s3_key(path, file['path'])
        else:
            delete_resource_from_s3(path)
            insert_resource_in_s3(path.rsplit('/', 1)[0] + "/" + name + ext,file_bytes)

    for tag in tags:
        for item in tag:
            file[item] = tag[item]
    if image != "" and name == old_name:
        delete_resource_from_s3(path)
        file_b64dec = base64.b64decode(image)
        file_bytes = bytes(file_b64dec)
        insert_resource_in_s3(path, file_bytes)

    insert_file_in_dynamo(file)

    body = {
        'data': json.dumps('File edited')
    }
    return create_response(200, body)
