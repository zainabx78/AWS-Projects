# Deploying an application in amazon ECS with cloudformation templates

### Setting up application using cloudshell
- Using the cloudshell terminal, download given application files using the `wget` command.
```
wget https://ws-assets-prod-iad-r-iad-ed304a55c2ca1aee.s3.us-east-1.amazonaws.com/6d753373-da0f-46a6-8195-4f001e507961/pack.zip
```
- Use the commands `unzip` and `cd` to unzip the zipped application files and then change directories to enter the directory with the scripts inside containing aws cli commands to create cloudformation stacks.
- run the cloudformation script with certain perameters needed:
```
bash ./build_application.sh <region> <accountid> <sysops@domain.com> <owner@domain.com>
```
- This script builds 2 cloudformation stacks.
- Once the cloudformation stacks are completely created, confirm subscription to the emails sent to the emails you input in the previous command when running the scripts.
- In the outputs section of the cloudformation stack, make note of the application endpoint: `http://walab-op-alb-enfsi6uyrhoc-2119319783.us-east-1.elb.amazonaws.com`
- Create a variable to store the endpoint: `ALBEndpoint="<ApplicationEndpoint>"`
- Input this endpoint into the command to send a POST request to the API
```
curl --header "Content-Type: application/json" --request POST --data '{"Name":"Bob","Text":"Run your operations as code"}' $ALBEndpoint/encrypt
```
- Take a note of the key in the output of this command and input it into the next command:
```
curl --header "Content-Type: application/json" --request GET --data '{"Name":"Bob","Key":"EncryptKey"}' $ALBEndpoint/decrypt
```
