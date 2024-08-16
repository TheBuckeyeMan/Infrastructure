resource "aws_s3_bucket" "new_bucket_provision" { #Update new_bucket_provision if you would like to change the name - IF YOU UPDATE THIS, UPDATE OUTPUTS.tf FILE
  #Update the bucket name in the variables.tf file
  bucket = var.bucket_name
  tags = {
    Name        = "New S3 Bucket Provision" # Can update the tage here
  }
}



