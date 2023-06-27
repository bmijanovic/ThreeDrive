import json

import boto3

from utility.dynamo_invitations import insert_invite_in_dynamo
from utility.dynamo_users import find_user_by_email
from utility.utils import create_response


def family_member_invitation(event, context):
    try:
        body = json.loads(event['body'])
        family_member_email = body['family_member_email']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    # user = 'mrmijan'
    user = event['requestContext']['authorizer']['username']

    try:
        invite(user, family_member_email)
        body = {
            'data': json.dumps('User successfuly invited')
        }
        return create_response(200, body)
    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)


def invite(user, family_member_email):
    users = find_user_by_email(family_member_email)
    print(users)
    if users:
        raise ValueError("This family member already has account")

    new_invite = {
        'id': user + "/" + family_member_email,
        'status': 'invited'
    }
    insert_invite_in_dynamo(new_invite)

    sender_email = "certificateswebapp@gmail.com"
    recipient_email = family_member_email
    subject = "Invitation to TreeCloud"
    body = f'You are invited by {user} to join TreeCloud. Download the application and in register tab ' \
           f'check that you are invited and enter the username from person that invited you!'

    ses_client = boto3.client("ses")
    ses_client.send_email(
        Source=sender_email,
        Destination={"ToAddresses": [recipient_email]},
        Message={"Subject": {"Data": subject}, "Body": {"Text": {"Data": body}}},
    )
