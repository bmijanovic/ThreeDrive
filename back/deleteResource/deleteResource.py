import os

from utility.utils import create_response


table_name = os.environ['RESOURCES_TABLE_NAME']
bucket_name = os.environ['RESOURCES_BUCKET_NAME']

def delete(event, context):


    body = {
        'data': "File Deleted"
    }
    return create_response(200, body)