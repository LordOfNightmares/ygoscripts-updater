import boto3
from botocore.exceptions import ClientError
import os


def upload_s3(path, file):
    try:
        s3 = boto3.client('s3')
        filename = os.path.join(path, file)
        bucket_name = os.environ.get('BUCKET_NAME')
        s3.upload_file(filename, bucket_name, file)
    except ClientError as e:
        logging.error(e)
        raise Exception(500,e)
    return create_presigned_url(s3, bucket_name, file, expiration=3600)


def create_presigned_url(s3_client, bucket_name, object_name, expiration=3600):
    try:
        url = s3_client.generate_presigned_url('get_object',
                                               Params={'Bucket': bucket_name,
                                                       'Key': object_name},
                                               ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        raise Exception(500,e)
    return url
