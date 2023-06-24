import json
import os
import boto3

table_name_directory = os.environ['DIRECTORIES_TABLE_NAME']
table_name_users = os.environ['USERS_TABLE_NAME']
table_name_resources = os.environ['RESOURCES_TABLE_NAME']
s3_name_resources = os.environ['RESOURCES_BUCKET_NAME']
SECRET_KEY = 'pamuk'


def create_response(status, body):
    return {
        'statusCode': status,
        'headers': {
            'Access-Control-Allow-Origin': 'http://localhost:8888',
        },
        'body': json.dumps(body, default=str)
    }


def find_directory_by_path_and_name(path, name):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    response = table.scan(
        FilterExpression="#p = :paths",
        ExpressionAttributeNames={
            "#p": "path"
        },
        ExpressionAttributeValues={
            ":paths": path + name
        }
    )
    return response['Items']


def find_directory_by_path(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    response = table.scan(
        FilterExpression="#p = :paths",
        ExpressionAttributeNames={
            "#p": "path"
        },
        ExpressionAttributeValues={
            ":paths": path
        }
    )
    return response['Items']


def find_user_by_username(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_users)
    response = table.scan(
        FilterExpression="username = :username",
        ExpressionAttributeValues={
            ":username": username
        }
    )
    return response['Items']


def insert_directory_in_dynamo(new_directory):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    table.put_item(Item=new_directory)


def insert_file_in_dynamo(new_resource):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    table.put_item(Item=new_resource)


def find_file_by_path(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    response = table.scan(
        FilterExpression="#p = :paths",
        ExpressionAttributeNames={
            "#p": "path"
        },
        ExpressionAttributeValues={
            ":paths": path
        }
    )
    return response['Items']


def get_files_from_s3(path):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(s3_name_resources)
    files = []
    for obj in bucket.objects.filter(Prefix=path):
        files.append(obj)
    return files


def update_s3_key(old_key, new_key):
    s3 = boto3.client('s3')

    try:
        # Copy the object to the new key
        s3.copy_object(
            Bucket=s3_name_resources,
            CopySource={'Bucket': s3_name_resources, 'Key': old_key},
            Key=new_key
        )

        # Delete the object with the old key
        s3.delete_object(Bucket=s3_name_resources, Key=old_key)

        print(f"Object key updated: '{old_key}' -> '{new_key}'")
    except Exception as e:
        print(f"Error updating object key: {str(e)}")


def delete_directory_from_dynamo(key):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)

    try:
        table.delete_item(Key={"path": key})
        print("Item deleted successfully.")
    except Exception as e:
        print(f"Error deleting item from DynamoDB: {str(e)}")


def delete_resource_from_dynamo(path):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_resources)
    table.delete_item(Key={"path": path})


def delete_resource_from_s3(path):
    s3 = boto3.client('s3')
    s3.delete_object(Bucket=s3_name_resources, Key=f'{path}')
