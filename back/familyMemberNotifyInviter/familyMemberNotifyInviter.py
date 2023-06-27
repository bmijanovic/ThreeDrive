import json
import os

import boto3

sns_client = boto3.client("sns")
notify_inviter_topic = os.environ["NOTIFY_INVITER_SNS_TOPIC_ARN"]


def family_registration_notify_inviter(event, context):
    try:
        inviter = event["inviter_email"]
        family_member = event["family_member_username"]
    except (KeyError, json.decoder.JSONDecodeError):
        return {"valid": False}

    sns_client.publish(
        TopicArn=notify_inviter_topic,
        Message=json.dumps(
            {
                "subject": f"{family_member} registered by your invitation",
                "content": "In the application if you want to add permission to all your files click Yes or if you do "
                           "not click No!",
                "receiver": inviter,
            }
        ),
    )

    return event
