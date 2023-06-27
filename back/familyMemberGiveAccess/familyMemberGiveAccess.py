import json

from utility.dynamo_directory import find_directory_by_path, insert_directory_in_dynamo


def family_member_give_access(event, context):
    try:
        inviter_username = event['inviter_username']
        inviter_email = event['inviter_email']
        family_member_username = event['family_member_username']
        family_member_email = event['family_member_email']
    except (KeyError, json.decoder.JSONDecodeError):
        return {"valid": False}

    content = find_directory_by_path(inviter_username)
    content = content[0]
    content['share'] += [family_member_username]
    insert_directory_in_dynamo(content)
