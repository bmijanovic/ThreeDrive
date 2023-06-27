import json
import re
import uuid
from datetime import datetime
from hashlib import sha256

from registration.registration import insert_user_in_dynamo
from utility.dynamo_directory import insert_directory_in_dynamo
from utility.dynamo_invitations import check_invitation_in_dynamo
from utility.dynamo_users import find_user_by_username, find_user_by_email
from utility.utils import create_response
from dateutil.parser import parse


def registration(event, context):
    try:
        body = json.loads(event['body'])
        username = body['username']
        password = body['password']
        email = body['email']
        birthdate = body['birthdate']
        name = body['name']
        surname = body['surname']
        inviter = body['inviter']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    try:
        if not check_invitation_in_dynamo(inviter, email):
            raise ValueError("User is not invited by this user")
        register(username, password, email, birthdate, name, surname)
        body = {
            'data': json.dumps('User registration successful')
        }
        return create_response(200, body)

    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


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
    make_user_home_directory(username)


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


def make_user_home_directory(username):
    time = datetime.now().time()
    new_directory = {
        'path': username,
        'name': username,
        'owner': username,
        'items': [],
        'directories': [],
        'time_created': str(time),
        'time_updated': str(time)
    }

    insert_directory_in_dynamo(new_directory)
