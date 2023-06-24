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