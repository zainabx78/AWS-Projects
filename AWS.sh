#!/bin/bash
#Author: Zainab Farooq
#Date: 23/11/2024
#V1
#A simple bash script to gain information on AWS services: S3, EC2, IAM, Lambda.
#Prerequisite--> have AWS CLI installed and run AWS configure in your terminal. 

#run in debug mode
set -x

#list s3 buckets
aws s3 ls

#list ec2 instance ID's only.
aws ec2 describe-instances | jq 'reservations [].Instances[].InstanceId'

#list lambda functions
aws lambda list-functions

#list iam users
aws iam list-users
