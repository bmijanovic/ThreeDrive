import os
import boto3

table_name_directory = os.environ['DIRECTORIES_TABLE_NAME']


def insert_directory_in_dynamo(new_directory):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)
    table.put_item(Item=new_directory)


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

def delete_directory_from_dynamo(key):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_directory)

    try:
        table.delete_item(Key={"path": key})
        print("Item deleted successfully.")
    except Exception as e:
        print(f"Error deleting item from DynamoDB: {str(e)}")