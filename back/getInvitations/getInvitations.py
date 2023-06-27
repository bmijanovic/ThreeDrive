import json

from utility.dynamo_invitations import get_invitations_by_inviter_username_from_dynamo
from utility.utils import create_response


def get_invitations(event, context):
    user = event['requestContext']['authorizer']['username']
    try:
        invitations = get_invitations_by_inviter_username_from_dynamo(user)
        body = {
            'data': invitations
        }
        return create_response(200, body)

    except ValueError as err:
        body = {
            'data': json.dumps(str(err))
        }
        return create_response(400, body)
