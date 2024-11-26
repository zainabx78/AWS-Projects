# DEPLOYING A NODE.JS APPLICATION IN AWS

 
 ### Locally testing the node.js application before deploying on AWS

   •  Clone the github repository containing the application code using `git clone <repo link>` into the git bash local 
   environment.


   •  Use `vim .env` to create an environment variables file and add:
```
     DOMAIN= "http://localhost:3000"
                PORT=3000
                STATIC_DIR="./client"
                PUBLISHABLE_KEY=""
                SECRET_KEY=""
```

   • Obtain the publishable key and secret key from stripe at `https://stripe.com/gb`. Make an account, select 'settings'         and then 'developers' followed by 'API keys'. This will grant test mode API keys for the application for project 
       purposes.

   • Install node.js for windows from the official node.js website `https://nodejs.org/en`. 
   
   • Verify installation with `node -v` and `npm -v` in the git bash terminal.
   
   • Install express: `npm install express`.
   
   • In the local linux command line, run `npm run start`.
   

   • The application should be available at `http://localhost:3000` 
   
### Deploying the application on AWS
1. Pre requisites- Create an AWS account (free tier for 12 months).
2. Create an EC2 instance with these settings:
   - Linux 2023 AMI
   - Auto-assign public IP
   - Security groups- add inbound rules
     
   - SSH on port 22 from 0.0.0.0/0.

   - Allow access on port 3000 from 0.0.0.0/0/

3. Clone the github repository with the source code to the EC2 instance using `git clone <repo link>`.
4. Create a .env file for the environment variables with `vim .env`.
5. Install node.js and npm: `sudo yum install nodejs`. Also install express: `npm install express`.
6. Run `npm run start`. The application should now be available at `<ec2PublicIp>:3000`.



Credit to Kunal Verma for the application code and packages. Link to his Github repo: https://github.com/verma-kunal
