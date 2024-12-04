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
