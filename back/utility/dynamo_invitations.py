import os

import boto3

table_name_invites = os.environ['INVITES_TABLE_NAME']


def insert_invite_in_dynamo(new_invite):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_invites)
    table.put_item(Item=new_invite)


def check_invitation_in_dynamo(inviter, email):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_invites)
    response = table.scan(
        FilterExpression="#i = :ids",
        ExpressionAttributeNames={
            "#i": "id"
        },
        ExpressionAttributeValues={
            ":ids": inviter + "/" + email
        }
    )
    return response['Items']


def get_invitations_by_inviter_username_from_dynamo(username):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table(table_name_invites)
    response = table.scan(
        FilterExpression="contains(#i, :search_string)",
        ExpressionAttributeNames={
            "#i": "id"
        },
        ExpressionAttributeValues={
            ':search_string': username
        }
    )

    return response['Items']
