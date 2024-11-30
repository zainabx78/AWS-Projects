# Creating a messaging system using amazon SNS and SQS in AWS cloud

### Setting up cloud9 environment to host the application on an EC2 instance
   1) Log in to the AWS console and enter the cloud9 environment for the cloud9 EC2 instance.
   2) Download the application files and necessary python scripts: Download code.zip
```
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCDEV-2-91558/10-lab-sqs/code.zip -P /home/ec2-user/environment
```
   3) unzip the code.zip application file `unzip code.zip`
   4) Set permissions for the shell script which updates python and the AWS cli `chmod +x ./resources/setup.sh && ./resources/setup.sh` Input IP address to enforce security so that the S3 bucket is only accessible from that IP address.
   5) Check AWS Cli version and verify python SDK installation `aws --version` `pip show boto3`

