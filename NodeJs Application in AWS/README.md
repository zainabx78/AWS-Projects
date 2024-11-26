# DEPLOYING A NODE.JS APPLICATION IN AWS: Credit to Kunal Verma for the application code and packages. 

 
 ### LOCALLY TESTING THE APPLICATION BEFORE DEPLOYING IT ON AWS:

    •  Clone the github repository containing the application code using `git clone <repo link>` into local environment.


    •  Use `vim .env` to create an environment variables file and add:
               `DOMAIN= "http://localhost:3000"
                PORT=3000
                STATIC_DIR="./client"
                PUBLISHABLE_KEY=""
                SECRET_KEY=""`

    • Obtain the publishable key and secret key from stripe at `https://stripe.com/gb`. Make an account, select 'settings'         and then 'developers' followed by 'API keys'. This will grant test mode API keys for the application for project 
       purposes.

   • In your local command line, run `npm run start`.
   

   • The application should be available at `http://localhost:3000`
   
