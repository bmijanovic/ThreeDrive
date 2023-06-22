import jwt

from utility.utils import find_user_by_username, SECRET_KEY


def validate_token(token):
    try:
        decoded_token = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        username = decoded_token.get('username')
        return find_user_by_username(username)[0]  # needs to be secured

    except jwt.InvalidSignatureError:
        print("InvalidSignatureError")
        return None
    except jwt.ExpiredSignatureError:
        print("ExpiredSignatureError")
        return None
    except jwt.DecodeError:
        print("DecodeError")
        return None


def authorize(event, context):
    token = event.get('authorizationToken').replace("Bearer ", "")
    user = validate_token(token)
    if user:
        policy = generate_policy('Allow', event['methodArn'], user['username'])
    else:
        policy = generate_policy('Deny', event['methodArn'])

    print(policy)
    return policy


def generate_policy(effect, resource, username=None):
    policy = {
        'principalId': 'user',
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        }
    }

    if username:
        policy['context'] = {
            'username': username
        }

    return policy
