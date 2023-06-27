import json
import boto3

ses_client = boto3.client("ses")

def notifyResourceAction(event, context):
    print(event)
    body = json.loads(event["Records"][0]["Sns"]["Message"])
    ses_client.send_email(
        Source="certificateswebapp@gmail.com",
        Destination={"ToAddresses": [body["receiver"]]},
        Message={"Subject": {"Data": body["subject"]}, "Body": {"Text": {"Data": body["content"]}}},
    )