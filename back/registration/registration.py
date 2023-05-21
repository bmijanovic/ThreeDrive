import json
import os
import boto3
import uuid
import re
from hashlib import sha256
from dateutil.parser import parse

from utility.utils import create_response

table_name = os.environ['USERS_TABLE_NAME']


def registration(event, context):
    try:
        body = json.loads(event['body'])
        username = body['username']
        password = body['password']
        email = body['email']
        birthdate = body['birthdate']
        name = body['name']
        surname = body['surname']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)
        # return {
        #     'statusCode': 400,
        #     'body': json.dumps('Invalid request body')
        # }

    try:
        register(username, password, email, birthdate, name, surname)
        body = {
            'data': json.dumps('User registration successful')
        }
        return create_response(200, body)
        # return {
        #     'statusCode': 200,
        #     'body': json.dumps('User registration successful')
        # }
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)
        # return {
        #     'statusCode': 400,
        #     'body': json.dumps(str(err))
        # }


def register(username, password, email, birthdate, name, surname):
    # Validate user data
    if not username or not password or not email or not birthdate or not name or not surname:
        raise ValueError("All fields are required!")

    # Check if email is in valid format
    if not is_valid_email(email):
        raise ValueError("Email is invalid!")

    if not is_parsable_date(birthdate):
        raise ValueError("Birthdate is invalid")

    # Check if the user already exists
    if does_user_exist(username, email):
        raise ValueError("User already exist!")

    # Create a new user
    user_item = {
        'id': str(uuid.uuid4()),
        'username': username,
        'password': sha256(password.encode('utf-8')).hexdigest(),
        'email': email,
        'name': name,
        'surname': surname,
        'birthdate': birthdate
    }
    insert_user_in_dynamo(user_item)


def is_valid_email(email):
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email)


def is_parsable_date(date_string):
    try:
        parse(date_string)
        return True
    except ValueError:
        return False


def does_user_exist(username, email):
    if find_user_by_email(email):
        return True
    if find_user_by_username(username):
        return True
    return False


def find_user_by_username(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    response = table.scan(
        FilterExpression="username = :username",
        ExpressionAttributeValues={
            ":username": username
        }
    )
    return response['Items']


def find_user_by_email(email):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    response = table.scan(
        FilterExpression="email = :email",
        ExpressionAttributeValues={
            ":email": email
        }
    )
    return response['Items']


def insert_user_in_dynamo(user_item):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name)
    table.put_item(Item=user_item)
