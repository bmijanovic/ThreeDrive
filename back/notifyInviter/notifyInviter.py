import boto3
import json

ses_client = boto3.client("ses")


def notify_inviter(event, context):
    body = json.loads(event["Records"][0]["Sns"]["Message"])
    ses_client.send_email(
        Source="certificateswebapp@gmail.com",
        Destination={"ToAddresses": [body["receiver"]]},
        Message={"Subject": {"Data": body["subject"]}, "Body": {"Text": {"Data": body["content"]}}},
    )