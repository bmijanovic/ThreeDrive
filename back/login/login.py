import json
from hashlib import sha256

import jwt

from utility.utils import create_response, find_user_by_username, SECRET_KEY


def login(event, context):
    try:
        body = json.loads(event['body'])
        username = body['username']
        password = body['password']
        results = find_user_by_username(username)
        if results:
            user = results[0]
            password = sha256(password.encode('utf-8')).hexdigest()
            if user['username'] == username and user['password'] == password:
                token = generate_token(username)

                body = {
                    'message': json.dumps('Logged in successfully'),
                    'token': token
                }
                return create_response(200, body)
        body = {
            'data': json.dumps('Invalid username or password')
        }
        return create_response(404, body)
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)


def generate_token(username):
    payload = {
        'username': username,
    }
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token
