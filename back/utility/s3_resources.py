import os
import boto3

bucket_name_resources = os.environ['RESOURCES_BUCKET_NAME']


def get_files_from_s3(path):
    s3 = boto3.resource('s3')
    bucket = s3.Bucket(bucket_name_resources)
    files = []
    for obj in bucket.objects.filter(Prefix=path):
        files.append(obj)
    return files


def insert_resource_in_s3(fileKey, fileBytes):
    s3 = boto3.client('s3')
    s3.put_object(Bucket=bucket_name_resources, Key=f'{fileKey}', Body=fileBytes)


def update_s3_key(old_key, new_key):
    s3 = boto3.client('s3')

    try:
        # Copy the object to the new key
        s3.copy_object(
            Bucket=bucket_name_resources,
            CopySource={'Bucket': bucket_name_resources, 'Key': old_key},
            Key=new_key
        )

        # Delete the object with the old key
        s3.delete_object(Bucket=bucket_name_resources, Key=old_key)

        print(f"Object key updated: '{old_key}' -> '{new_key}'")
    except Exception as e:
        print(f"Error updating object key: {str(e)}")


def delete_resource_from_s3(path):
    s3 = boto3.client('s3')
    s3.delete_object(Bucket=bucket_name_resources, Key=f'{path}')


def get_resource_from_s3(path):
    s3 = boto3.client('s3')
    try:
        response = s3.get_object(Bucket=bucket_name_resources, Key=path)
        file_contents = response['Body'].read()
        return file_contents
    except boto3.exceptions.botocore.exceptions.ClientError:
        return None
