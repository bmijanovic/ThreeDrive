import json

from utility.dynamo_invitations import check_invitation_in_dynamo


def family_member_check_approval(event, context):
    try:
        inviter_username = event['inviter_username']
        inviter_email = event['inviter_email']
        family_member_username = event['family_member_username']
        family_member_email = event['family_member_email']
    except (KeyError, json.decoder.JSONDecodeError):
        return {"valid": False}

    invitation = check_invitation_in_dynamo(inviter_username, family_member_email)
    if not invitation:
        raise ValueError("Invitation does not exist")
    invitation = invitation[0]

    if invitation['status'] == 'rejected':
        return {"valid": False}

    if invitation['status'] == "registered":
        raise ValueError("Invitation does not approved yet")

    return {
        "valid": invitation['status'] == "accepted",
        "inviter_email": inviter_email,
        "inviter_username": inviter_username,
        "family_member_username": family_member_username,
        "family_member_email": family_member_email
    }