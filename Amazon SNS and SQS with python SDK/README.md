# Creating a messaging system using amazon SNS and SQS in AWS cloud

### Prerequisites
   - VPC
   - EC2 instance configured with cloud9 access
   - Security groups
   - S3 bucket with static website hosting enabled- contains the website code

![undefined](https://github.com/user-attachments/assets/008c0263-8f68-47d6-9536-32a241cb7126)

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
   1) Create a script in the EC2 instance which contains information for the dead-letter queue configuration:
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
This queue will receive messages from SNS and send the failed ones to the dead-letter queue while processing the successful ones.
   1) Create a python script to store attributes for the SQS queue. Run this script with AWS cli:
```
{
    "FifoQueue": "true",
    "VisibilityTimeout": "30",
    "ReceiveMessageWaitTimeSeconds": "20",
    "ContentBasedDeduplication": "true",
    "DeduplicationScope": "queue",
    "RedrivePolicy": "{\"deadLetterTargetArn\":\"arn:aws:sqs:us-east-1:<AccountID>:DeadLetterQueue.fifo\",\"maxReceiveCount\":\"5\"}"
}
```
```
aws sqs create-queue --queue-name updated_beans.fifo --attributes file://mainqueue.json
```
- Both SQS queues (dead-letter and main) must use the same queue type e.g. in this project its FIFO.

   2) Update the policy on the main SQS queue with unique account ID:
```
{"Policy": "{\"Version\": \"2008-10-17\",\"Id\": \"BeansSqsPolicy\",\"Statement\": [{\"Sid\": \"beans-sqs\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"arn:aws:iam::<AccountID>:root\"},\"Action\": \"SQS:*\",\"Resource\": \"arn:aws:sqs:us-east-1:<AccountID>:updated_beans.fifo\"},{\"Sid\": \"topic-subscription\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"arn:aws:iam::<AccountID>:root\",\"Service\": \"sns.amazonaws.com\"},\"Action\": \"SQS:SendMessage\",\"Resource\": \"arn:aws:sqs:us-east-1:<AccountID>:updated_beans.fifo\",\"Condition\": {\"ArnLike\": {\"aws:SourceArn\": \"arn:aws:sns:us-east-1:<AccountID>:updated_beans_sns.fifo\"}}},{\"Sid\": \"get-messages\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": [\"arn:aws:iam::<AccountID>:role/aws-elasticbeanstalk-ec2-role\",\"arn:aws:iam::<AccountID>:root\"]},\"Action\": [\"sqs:ChangeMessageVisibility\",\"sqs:DeleteMessage\",\"sqs:ReceiveMessage\"],\"Resource\": \"arn:aws:sqs:us-east-1:<AccountID>:updated_beans.fifo\"}]}"}
```
   3) Run the policy script and update the policy for the main queue:
```
aws sqs set-queue-attributes --queue-url "https://sqs.us-east-1.amazonaws.com/533267211698/updated_beans.fifo" --attributes file://beans-queue-policy.json
```
### Creating the SNS Topic
This SNS topic will receive messages from the suppliers and send them to the application

1) Use the AWS CLI command to create the SNS topic: Identical messages/content won't be processed again for 5 minutes. 
```
aws sns create-topic --name updated_beans_sns.fifo --attributes DisplayName="updated beans sns",ContentBasedDeduplication="true",FifoTopic="true"
```
2) Create a policy document to attach to the sns queue- gives full sns priviliges to the topic owner.
```
{
    "TopicArn": "arn:aws:sns:us-east-1:<AccountID>:updated_beans_sns.fifo",
    "AttributeName": "Policy",
    "AttributeValue": "{\"Version\": \"2008-10-17\",\"Id\": \"BeansTopicPolicy\",\"Statement\": [{\"Sid\": \"BeansAllowActions\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"arn:aws:iam::<AccountID>:root\"},\"Action\": [\"SNS:Publish\",\"SNS:RemovePermission\",\"SNS:SetTopicAttributes\",\"SNS:DeleteTopic\",\"SNS:ListSubscriptionsByTopic\",\"SNS:GetTopicAttributes\",\"SNS:Receive\",\"SNS:AddPermission\",\"SNS:Subscribe\"],\"Resource\": \"arn:aws:sns:us-east-1:<AccountID>:updated_beans_sns.fifo\",\"Condition\": {\"StringEquals\": {\"AWS:SourceOwner\": \"<AccountID>\"}}},{\"Sid\": \"BeansAllowPublish\",\"Effect\": \"Allow\",\"Principal\": {\"AWS\": \"*\"},\"Action\": \"SNS:Publish\",\"Resource\": \"arn:aws:sns:us-east-1:<AccountID>:updated_beans_sns.fifo\"}]}"
}
```
3) Apply the policy through the cloud9 terminal
```
aws sns set-topic-attributes --cli-input-json file://topic-policy.json
```
### Link Amazon SNS to SQS queues
   1) Create a subscription from the SQS queue to the SNS topic:
```
aws sns subscribe --topic-arn "arn:aws:sns:us-east-1:533267211698:updated_beans_sns.fifo" --protocol sqs --notification-endpoint "arn:aws:sqs:us-east-1:533267211698:updated_beans.fifo"

``` 


