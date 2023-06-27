import os

import boto3

table_name_invites = os.environ['INVITES_TABLE_NAME']


def insert_invite_in_dynamo(new_invite):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_invites)
    table.put_item(Item=new_invite)
