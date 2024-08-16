# DockerCICDPipeline
Create poc repo to send a simple spring boot application to dockerhub, containerize it, then use as part of a cicd repo

DOCKER COMMANDS TO USE DOCKER - DOCKERFILE ONLY BUILDING A SINGLE DOCKER IMAGE - NOT CONTAINER

PREREQUASITE
it is always best practice to log into docker as soon as you plan on begin using it 
1. log into docker via cli
docker login
username: <account email address>
password: <account password>
enter you should see the following
Login Succeeded

2. Ensure your Dockerfile is configured correctly 
FROM <base_container>  #check to see if new verison is avaliable - additionally, if we want this hosted on another base container, we cna explore other base containers
ARG JAR_FILE=<./<Jar filepath relative to the Dockerfile file>> #Make sure to include ./ before you paste in your copy relitive path
COPY <target/<your jar file name here.jar>> <name of new jar file>.jar
ENTRYPOINT ["java","-jar","<name of new jar file>.jar"]

Example
FROM openjdk:17-jdk
ARG JAR_FILE=./save_file_to_s3_springboot_app/target/APIData-0.0.1-SNAPSHOT.jar
COPY target/APIData-0.0.1-SNAPSHOT.jar /app.jar app.jar
ENTRYPOINT ["java","-jar","app.jar"]


RUNNING THE DOCKER COMMANDS
1. check for docker images if any currently exist
docker images

2. make the build 
docker build -t <name of the new image you give this>/<build from where>:<tagName>

#Example
docker build -t testimage .

3. run the docker image 
docker run <name of image> ---> you cna get this by running command 1

Example
docker images
testimage             latest    507e60ecfeca   29 minutes ago   540MB

example
docker run testimage

deleting an image 
docker rmi -f <Name of the image>
or 
docker rm <image id>
exmaple 
docker rmi -f testimage
**Will remove the test image we created

-----------------------------------------------------------------
PUSHING TO DOCKERHUB - from prebuilt image - not tagged properly 

1. We first need to create the image locally remmeber, we do this docker build -t <name of image> <from this directory>

2. List images via docker images

3. Apply a tag to docker 
In the format of 
docker tag <image id> <docker username - not the email- but your username>/<repo name - find in docker hub>:<tag with a custom tag in your repo - you decide this>

example
docker tag 507e60ecfeca thebuckeyeman20/springbootimages:apiapp

4. Push yoiur docker image to DOCKERHUB
docker push <docker username - not the email - but your username>/<image name>:<tag with a custom tag in your repo - you decide this - MUST match what tag you specified in step 3>

exmaple
docker push thebuckeyeman20/springbootimages:tagname
-----------------------------------------------------------------
DOCKER IMAGE NOW PUSHED TO DOCKERHUB
-----------------------------------------------------------------

PUSHING TO DOCKERHUB - FROM NEW IMAGE BUILD

1. We first need to create the image locally
docker build -t <docker username - not the email- but your username>/<repo name - find in docker hub>:<tag with a custom tag in your repo - you decide this> <build from where>

example 
docker build -t thebuckeyeman20/springbootimages:apiapplication .
**This will create an image with the tag of thebuckeyeman20/springbootimages:apiapplication

2. Push to docker hub
docker push <docker username - not the email - but your username>/<image name>:<tag with a custom tag in your repo - you decide this - MUST match what tag you specified in step 1>

exmaple 
docker push thebuckeyeman20/

-----------------------------------------------------------------
DOCKER IMAGE NOW PUSHED TO DOCKERHUB
-----------------------------------------------------------------

PULLING DOCKER IMAGE FROM DOCKER hub
1. log into docker via cli - if you have not already
docker login
username: <account email address>
password: <account password>
enter you should see the following
Login Succeeded

2. Pull the docker image already stored in docker hub

docker pull <docker username - not the email - but your username>/<image name>:<tag - See on dockerhub>

example 
docker pull thebuckeyeman20/springbootimages:apiapp
this will pull the docker image in the springbootapp repo with the tag of apiapp

3. Run the pulled docker container locally via cli
docker run <docker username - not the email - but your username>/<image name>:<tag - See on dockerhub>
**Yopur file is not running locally and pulled form dockerhub



USING DOCKER_COMPOSE TO BUILD CONTAINERS
1. befor we begin we generally already need to have followed the steps above. We need images created, tagged, and uploaded to the docker hub. After we have thease containers uploaded, we can begin with docker-compose.yml

Why Docker-compose.yml? 
Well with docker-compose.yml, we can create containers to host a variety of images and run them locally on our machiene, as well as 
**Possibly - look into - Automatically have the application deploy resources upon build - see capabilities later

2. Beghin by adding the following code to docker-compose.yml
version: '3.8'

services: #We will define the services in our app here
  springbootapp:
    image: thebuckeyeman20/springbootimages:apiapp #Replace with the actual image repo and tag
    container_name: springbootapp #Adding a custom name for our docker container
    ports:
      - 8081:8081 #Specify the ports we want this running on
    environment: #Set environment variables needed by spring boot app
      - SPRING_PROFILES_ACTIVE=dev #Enabling the dev environemnt
#We can add in additional containers to run in the docker-compose area, this is super nice if we want to have somethign running while we work
**Review the comments and adjust as nessasary, this is all pretty self explanitory

3. After you have added all of the different images we want to run in the single container into docker-compoase.yml we can run
docker-compose up
**This will build the container, as well as start the server




-----------------------------------------------------------------
SETTING UP THE CI/CD PIPELINE
-----------------------------------------------------------------
Prerequasites:
1. Create the docker-compose.yml file 
version: '3.8'

services:
  container1:
    image: thebuckeyeman20/cicd:image1
    container_name: container1
    ports:
      - 8082:8082
    environment:
      - SPRING_PROFILES_ACTIVE=dev

#We need to add in all repos we want to make a build off every commit(Every time we make a commit, build what) this usually will refer to the current workspace so if we make a commit on this repo, build an image of this repo in dockerhub

-----------------------------------------------------------------
# Terraform Provisioning Via CICD - For Infrastructure
-----------------------------------------------------------------

With any cicd pipeline, if we want to deploy to the cloud, we will need to set up our terraform code to create the resource we need. In order to acomplish this, make sure to do the following

1. In github, add srepo secret variable for AWS_ACCESS_KEY_ID <Add your aws_access_key> and AWS_SECRET_ACCESS_KEY <Add your secret access key>

2. In your project, navigate to your terraform directory(This should be right under your main repo directory) add aws crednetials config
    a. Add Enviroment variables to providers.tf - see below
    provider "aws" {
        region     = "us-east-2"
        access_key  = var.aws_access_key
        secret_key  = var.aws_secret_key
        }
    b. Add variables in variables.tf - see below
        variable "aws_access_key" {
        description = "AWS access key"
        type        = string
        }

        variable "aws_secret_key" {
        description = "AWS secret key"
        type        = string
        }   
    c. After you do this your aws credential config IN TERRAFORM should be complete 
3. Add in your Terraform CICD Code - See below 
name: Infrastructure CI/CD Pipeline

on:
    push:
      branches: #Add additional branches if we neeed to add additional branches
        - master
        - dev
        - test
        - feature/infrastructure

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest 

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      - name: Terraform Init
        run: terraform init
        working-directory: terraform #Adjust if we have our terraform file in a different directory

      - name: Terraform Validate
        run: terraform validate
        working-directory: terraform 

      - name: Terraform Plan
        run: terraform plan -var="aws_access_key=${{ secrets.AWS_ACCESS_KEY_ID }}" -var="aws_secret_key=${{ secrets.AWS_SECRET_ACCESS_KEY }}"
        working-directory: terraform

      - name: Terraform Apply
        run: terraform apply -auto-approve -var="aws_access_key=${{ secrets.AWS_ACCESS_KEY_ID }}" -var="aws_secret_key=${{ secrets.AWS_SECRET_ACCESS_KEY }}"
        working-directory: terraform

      - name: Terraform Destroy 
        run: terraform destroy -auto-approve -var="aws_access_key=${{ secrets.AWS_ACCESS_KEY_ID }}" -var="aws_secret_key=${{ secrets.AWS_SECRET_ACCESS_KEY }}"
        working-directory: terraform # Adjust if your Terraform configuration is in a different directory


Adjustments
1. If you plan on provisioning infrastructure and it is not just for practice, remove the code block of name: terraform Destroy
2. Ensure your terraform_version: <latest terraform version> -> Check for latest if you are haviong issues with the cicd pipeline
3. Ensure working-directory: <Directory from repo root directory of the terraform directory> - configure the correct directory
4. Add in your environment variables for AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY after terraform plan and terraform apply -> -var="aws_access_key=${{ secrets.AWS_ACCESS_KEY_ID }}" -var="aws_secret_key=${{ secrets.AWS_SECRET_ACCESS_KEY }}"
**If you do not add this, terraform will fail to authenticate with aws and will be unable to provision resources
**After you have completed the above, you can modify your terrform code to provision any # of resources to your aws account as you would like.**
**Your Terraform should now deploy to the aws cloud

-----------------------------------------------------------------
TROUBLESHOOTING Infrastructure Deployment:
1. ensure the branch you are commiting code to is listed in the list of branches at the top of ci.yml

2. Check your github repo actions tab for logs on the run and build to see if anything failed and get error details.

3. Ensure the correct file structure
Repository Directory
    |-.github
        |-workflows
            |-ci.yml
    |-terraform
        |-.terraform
        |-variables
            |-local.tfvars
            |-dev.tfvars
        |-iam.tf
        |-main.tf
        |-outputs.tf
        |-providers.tf
        |-variables.tf
4. S3: If you have already provisioned an s3 bucket in the past, you cannot create another s3 bucket WITH the same name, please rename your new S3 Bucket
5. If you provision infrastructure via cicd and try to destroy it after, you may be unable to due to the different terraform state. You can manually delete from the console.
 
-----------------------------------------------------------------
# CI/CD: Docker image creation - push to docker hub/AWS ECR - Deploy to ECS Instance
-----------------------------------------------------------------
In order to set up the CI pipeline in dockerhub we first need to configure a few things. 
1. In github, navigate to your repo -> settings -> Serets and variables -> Action -> New Repositorty Secret
Add in the following Secrets
DOCKER_PASSWORD <your docker hub username(not email)>
DOCKER_USERNAME <your docker hub password>

2. After you have your gitgub repo secrets set up, it is time to make the pipeline
Create a new directory in the root of your project 
.github
|-workflows
   |-ci.yml

3. Add in the following code for the CI pipeline -> CICD Pipeline for Java Spring Boot Apps
name: CI/CD Pipeline

on:
  push:
    branches:
      - main 
      - dev
      - test
      - feature/dockerimagecreation
      - feature/cd
      - feature/ecs

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest 

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Jacoco - Generate Test Coverage Report
        run: |
          mvn jacoco:report

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Log in to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Configure AWS credentials 
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        run: |
          aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
          aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
          aws configure set default.region us-east-2
          aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-2.amazonaws.com

      - name: Build Docker image
        run: |
          docker build -t thebuckeyeman20/cicd:image1 .
          docker tag thebuckeyeman20/cicd:image1 ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-2.amazonaws.com/containers_for_ecs:containerforecs

      - name: Push Docker image to Docker Hub
        run: |
          docker push thebuckeyeman20/cicd:image1

      - name: Push Docker image to AWS ECR
        run: |
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-2.amazonaws.com/containers_for_ecs:containerforecs


Pipeline Adjustments:
1. Ensure ALL Environment variables are saved in github repository secrets settings -> secrets and variables -> Actions -> Add Repository Secret <Add all environment variables and there values here>
2. Ensure you have properly ran a terraform apply to create a new AWS ECR resource via terraform in AWS before you commit your code -> If you need help creating resources, you can see my other github repo here for infrastructure https://github.com/TheBuckeyeMan/Infrastructure/tree/feature/infrastructure
3. Ensure the AWS Regions configured match the region you want to deploy your resources too AND that region matches the region of your deployed infrastructure.-> See step 2
4. Modify the tags for your docker images. Ensure your docker images for docker hub follow the format <docker hub username>/<docker hub repo>:<unique tag you specify> For AWS Image upload to ECR we need to folow the format docker tag <docker hub username>/<docker hub repo>:<unique tag you specify> ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.<specified region>.amazonaws.com/<Specified ECR Registry>:<Specified ECR Image Tag>

Adjustments:
1. If you want to add additional configuration to kick off builds of additional images specify them in the  - name: Build Docker image and - name: Push Docker images sections
2. If you create a new branch and want the cicd process to be kicked off as part of the process, ensure that you add in additional configuration under *Branches* you will specify the name of your new branch
3. You can specify a new repo and new tag for your build and push in the pipeline above under the sections Build Docker image and Push Docker image








