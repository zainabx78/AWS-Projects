# Creating a messaging system using amazon SNS and SQS in AWS cloud

### Prerequisites
   - VPC
   - EC2 instance configured with cloud9 access
   - Security groups
   - S3 bucket with static website hosting enabled- contains the website code

### Setting up cloud9 environment to host the application on an EC2 instance
   1) Log in to the AWS console and enter the cloud9 environment for the cloud9 EC2 instance.
   2) Download the application files and necessary python scripts: Download code.zip
```
wget https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCDEV-2-91558/10-lab-sqs/code.zip -P /home/ec2-user/environment
```
   3) Unzip the code.zip application file `unzip code.zip`
   4) Set permissions for the shell script which updates python and the AWS cli `chmod +x ./resources/setup.sh && ./resources/setup.sh` Input IP address to enforce security so that the S3 bucket is only accessible from that IP address.
   5) Check AWS Cli version and verify python SDK installation `aws --version` `pip show boto3`

### Configuring an SQS dead-letter queue
This has to be created first- it can then be defined as a target for the main SQS queue.
   1) A script in the EC2 instance contains information for the dead-letter queue configuration:
```
{
    "FifoQueue": "true",
    "VisibilityTimeout": "20",
    "ReceiveMessageWaitTimeSeconds": "0",
    "ContentBasedDeduplication": "false",
    "DeduplicationScope": "queue"
}
```
- Run this script in the cloud9 terminal with aws CLI commands to create a dead-letter queue.
```
aws sqs create-queue --queue-name DeadLetterQueue.fifo --attributes file://deadletterqueue.json
```
   2) The dead-letter queue requires a policy to enable access security. Only the owner of the queue should be able to communicate with the queue. Create the following policy, where SQS access is allowed explicitly to the account ID specified and therefore automatically denied to everyone else.
```
{"Policy": "{\"Version\": \"2008-10-17\",\"Id\": \"DlqSqsPolicy\",\"Statement\": [{\"Sid\": \"dead-letter-sqs\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"arn:aws:iam::<accountID>:root\"},\"Action\": [\"SQS:*\"],\"Resource\": \"arn:aws:sqs:us-east-1:<accountID>:DeadLetterQueue.fifo\"}]}"}
```
   3) Update the dead-letter queue's policy. Successful execution shouldnt yield an output.
```
aws sqs set-queue-attributes --queue-url "https://sqs.us-east-1.amazonaws.com/533267211698/DeadLetterQueue.fifo" --attributes file://deadletterqueue.json
```
### Creating the main SQS queue
