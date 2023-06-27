import boto3

def notifyUploadCompletion(event, context):
    message = event['Records'][0]['Sns']['Message']
    print(message)