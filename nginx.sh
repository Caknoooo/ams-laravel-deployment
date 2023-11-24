sudo apt-get update
sudo apt-get wget -y
sudo apt-get install nginx -y
sudo apt-get install mariadb-server -y
sudo apt-get install git -y

apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

sudo apt-get install php8.1-mbstring php8.1-xml php8.1-cli php8.1-common php8.1-intl php8.1-opcache php8.1-readline php8.1-mysql php8.1-fpm php8.1-curl -y

service nginx start
service php8.1-fpm start
service mysql start

sudo ufw allow 'Nginx HTTP'

sudo curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

## Check Version
composer --version
mysql --version
php -v

## Setup Mysql Databases
mysql -u root -p

CREATE USER 'testing'@'%' IDENTIFIED BY 'testing';
CREATE USER 'testing'@'localhost' IDENTIFIED BY 'testing';
CREATE DATABASE testing;
GRANT ALL PRIVILEGES ON *.* TO 'testing'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'testing'@'localhost';
FLUSH PRIVILEGES;

mysql -u testing -p 
## Enter Password: testing

## Clone Repository and Install Dependencies
cd /var/www && git clone https://github.com/Caknoooo/ams-laravel-mvc
cd /var/www/ams-laravel-mvc && cp .env.example .env

## Open .env file 
## Change Configuration With Your Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=testing
DB_USERNAME=testing
DB_PASSWORD=testing

## Install Dependencies
cd /var/www/ams-laravel-mvc && composer install
cd /var/www/ams-laravel-mvc && php artisan key:generate
cd /var/www/ams-laravel-mvc && php artisan migrate
cd /var/www/ams-laravel-mvc && php artisan db:seed

## Setup Nginx
cd /etc/nginx/sites-available && rm default

echo 'server {
    listen 80;

    root /var/www/ams-laravel-mvc/public;
    index index.php index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }

    location ~ \.php$ {
      try_files $uri /index.php =404;
      fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

}' > /etc/nginx/sites-available/ams-laravel-mvc

ln -s /etc/nginx/sites-available/ams-laravel-mvc /etc/nginx/sites-enabled/ams-laravel-mvc

service nginx restart