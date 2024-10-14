```
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-2019.list)"
sudo apt-get update
sudo apt-get install -y mssql-server
sudo /opt/mssql/bin/mssql-conf setup
systemctl status mssql-server --no-pager
```

```
curl https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc
curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo apt-get install mssql-tools18 unixodbc-dev

sudo apt-get update  
sudo apt-get install mssql-tools18

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
source ~/.bash_profile

echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc
```

#Test Connection To SqlCmd 
sqlcmd -S localhost -U sa -P '#L64$h65J68#' -N -C

-----------------------Install  Asp core 

```
sudo apt upgrade -y

wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update -y
sudo apt install -y dotnet-sdk-8.0
sudo apt install nginx -y
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.draton.io
sudo certbot --nginx -d bot.draton.io
```

```
#git clone https://github.com/azureDevOpsTeam/DratonApiPublish.git
#cd DratonApiPublish
mkdir /var/www/api
#sudo cp * /var/www/DratonApi
sudo nano /etc/nginx/sites-available/api
```
```
server {
    listen 443 ssl;
    server_name api.draton.io;
    ssl_certificate /etc/letsencrypt/live/api.draton.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/api.draton.io/privkey.pem; # managed by Certbot

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name api.draton.io;
    return 301 https://$host$request_uri;
}
```

sudo ln -s /etc/nginx/sites-available/api /etc/nginx/sites-enabled/
sudo nginx -t

sudo systemctl reload nginx

sudo nano /etc/systemd/system/api.service   ******
```
[Unit]
Description=Draton API Service
After=network.target

[Service]
WorkingDirectory=/var/www/api/publish
ExecStart=/usr/bin/dotnet /var/www/api/publish/PresentationWebApp.dll
Restart=always
# Environment variables for ASP.NET Core
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
```

#Add Ssh-Key For CI/CD 
ssh-keygen -t rsa -b 4096 -C "api@draton.io" -f ~/.ssh/id_rsa_api
ssh-keygen -t rsa -b 4096 -C "client@draton.io" -f ~/.ssh/id_rsa_client

eval "$(ssh-agent -s)"

ssh-add ~/.ssh/id_rsa_api
ssh-add ~/.ssh/id_rsa_client

cat ~/.ssh/id_rsa_api
cat ~/.ssh/id_rsa_api.pub

cat ~/.ssh/id_rsa_client
cat ~/.ssh/id_rsa_client.pub

#Add Publish Key To this File : 
nano ~/.ssh/authorized_keys

chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys



#Add Publish Project To Server


sudo systemctl enable api
sudo systemctl start api
sudo systemctl status api

sudo mkdir /var/www/client
sudo nano /etc/nginx/sites-available/client    *******

```
server {
    listen 443 ssl;
    server_name bot.draton.io;
    ssl_certificate /etc/letsencrypt/live/bot.draton.io/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/bot.draton.io/privkey.pem; # managed by Certbot

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /var/www/client;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}

# Redirect HTTP to HTTPS
server {
    if ($host = bot.draton.io) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    server_name bot.draton.io;
    return 301 https://$host$request_uri;
}
```



sudo ln -s /etc/nginx/sites-available/client /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx



#install screen 
sudo apt-get install screen
sudo apt update
sudo apt install python3-pip

pip install python-telegram-bot

mkdir /var/www/bot
sudo nano /var/www/bot/start.py

```
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup, WebAppInfo
from telegram.ext import ApplicationBuilder, CommandHandler, CallbackContext

# Function to start the bot
async def start(update: Update, context: CallbackContext) -> None:
    # Get user information
    user = update.effective_user
    referral_code = context.args[0] if context.args else None

    # Determine the correct URL based on whether referral code exists
    if referral_code:
        myUrl = f"https://bot.draton.io?referral={referral_code}"
    else:
        myUrl = "https://bot.draton.io"

    # Create an inline button with WebApp
    keyboard = [
        [InlineKeyboardButton("Open Mini App", web_app=WebAppInfo(url=myUrl))]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    # Send a message with the referral code (if any)
    if referral_code:
        await update.message.reply_text(
                f"Hello {user.first_name}! Welcome!"
                f"Welcome, Adventurer! 🏰🐉\n\n"
                f"You've entered the realm of **Dragon's Treasure**! With your referral code: **{referral_code}**, "
                f"you're on the path to riches. Get ready to uncover hidden treasures and claim your **TON** rewards.\n\n"
                f"Your epic journey begins now—let the adventure unfold!",
                reply_markup=reply_markup
                )
    else:
        await update.message.reply_text(
                "Welcome, Brave Adventurer! 🏰🐉\n\n"
                "You've stepped into the enchanting world of **Dragon's Treasure**! Although you don't have a referral code, "
                "your journey is just beginning.\n\n"
                "Prepare to uncover hidden treasures and unlock amazing rewards in **TON**. The dragons await your challenge, "
                "and epic adventures lie ahead!\n\n"
                "Get ready to embark on your quest—let the adventure unfold!",
                reply_markup=reply_markup
                )

if __name__ == '__main__':
    # Create an application
    application = ApplicationBuilder().token('7305923163:AAHu6Ka30ODUxv9IoO0hy0nnmbNnt8bs4Rs').build()

    # Add handler for the /start command
    application.add_handler(CommandHandler('start', start))

    # Run the bot
    application.run_polling()

```

sudo systemctl reload nginx


#add screen 
screen -S startBot

#view screen 
screen -r startBot

