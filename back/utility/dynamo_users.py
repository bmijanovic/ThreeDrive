import os
import boto3

table_name_users = os.environ['USERS_TABLE_NAME']


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


def find_user_by_email(email):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_users)
    response = table.scan(
        FilterExpression="email = :email",
        ExpressionAttributeValues={
            ":email": email
        }
    )
    return response['Items']


def delete_user_from_dynamo(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_users)

    try:
        table.delete_item(Key={"path": username})
        print("User deleted successfully.")
    except Exception as e:
        print(f"Error deleting user from DynamoDB: {str(e)}")