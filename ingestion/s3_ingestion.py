import os
import boto3
import pandas as pd


def upload_files_to_s3(local_directory,bucket_name,s3_prefix):
    
    s3_client=boto3.client('s3')
    
    # Ensure the local directory exists
    if not os.path.isdir(local_directory):
        print(f"Error: Local directory '{local_directory}' not found.")
        return

    print(f"Searching for CSV files in '{local_directory}'...")
    
    for filename in os.listdir(local_directory):
        local_file_path = os.path.join(local_directory, filename)
        s3_key = os.path.join(s3_prefix, filename)
            
        print(f"Uploading {local_directory} to s3://{bucket_name}/{s3_key}...")
            
        try:
            s3_client.upload_file(local_file_path,bucket_name,s3_key)
            print(f"Successfully uploaded {local_file_path} to s3://{bucket_name}/{s3_key}")
        except Exception as e:
            print(f"Error uploading {local_file_path} to s3://{bucket_name}/{s3_key}: {e}")

if __name__ == "__main__":
     # --- Configuration ---
    #PLEASE UPDATE BUCKET NAME to match your setup
    
    LOCAL_DATA_DIR = 'C:/Users/EbotK/OneDrive/Documents/Projects/archive'
    
    S3_BUCKET = 'project-ecommerce-lakehouse-raw' # The name of your S3 bucket
    S3_BRONZE_PATH = 'bronze/'        # The target folder in your S3 bucket

    # --- Run the Upload Function ---
    upload_files_to_s3(LOCAL_DATA_DIR, S3_BUCKET, S3_BRONZE_PATH)