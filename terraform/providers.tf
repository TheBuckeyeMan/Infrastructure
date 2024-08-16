#Ensure both AWS_ACCESS_KEY and AWS_SECRET_KEY Repo Secrets are properly configured in your repo
provider "aws" {
    region     = var.region
    access_key  = var.aws_access_key
    secret_key  = var.aws_secret_key
}