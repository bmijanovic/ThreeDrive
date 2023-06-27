import json

from utility.dynamo_invitations import check_invitation_in_dynamo, insert_invite_in_dynamo
from utility.utils import create_response


def resolve_invitation(event, context):
    try:
        body = json.loads(event['body'])
        email = body['email']
        accept = body['accept']
    except (KeyError, json.decoder.JSONDecodeError):
        body = {
            'data': json.dumps('Invalid request body')
        }
        return create_response(400, body)

    try:
        user = event['requestContext']['authorizer']['username']
        invitation = check_invitation_in_dynamo(user, email)
        if not invitation:
            raise ValueError("Invitation does not exist")
        invitation = invitation[0]

        if accept:
            invitation["status"] = "accepted"
        else:
            invitation["status"] = "rejected"

        insert_invite_in_dynamo(invitation)

        body = {
            'data': json.dumps('Invitation resolved successfully')
        }
        return create_response(200, body)

    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)
