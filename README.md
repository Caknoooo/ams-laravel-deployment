# Deployment Laravel 
Repository ini digunakan untuk mengimplementasikan tahap deployment dengan menggunakan ``nginx`` web server pada repository ``https://github.com/Caknoooo/ams-laravel-mvc``

## Daftar Isi 
- [Prerequisite](#prerequisite)
- [Penjelasan Singkat](#penjelasan-singkat)
- [Installation](#installation)
- [Deployment](#deployment)

## Prerequisite

Karena kita akan melakukan ``deployment`` pada repository ``https://github.com/Caknoooo/ams-laravel-mvc`` dibutuhkan beberapa persiapan sebagai berikut 

- PHP >= 8.0
- PHP-FPM >= 8.0
- MySQL or MariaDB >=  Ver 15.1 Distrib 10.6.12-MariaDB, for debian-linux-gnu (x86_64) using  EditLine wrapper
- Composer >= 2.4

## Penjelasan Singkat

**Linux**: Sistem operasi terbuka yang paling diterima oleh pengembang selama bertahun-bertahun. Ini akan menjadi OS yang mendukung aplikasi web kita.

**Nginx**: Aplikasi proksi yang memiliki resources yang kecil dibandingkan dengan ``apache``. Memgunkinkannya menangani beban permintaan HTTP yang lebih tinggi. Ini akan membantu kami menangani perutean kami (permintaan/tanggap)

**PHP / MySQL**: Bahasa pemrograman dan program penyimpanan default di belakang laravel.

## Installation 
Berikut merupakan hal-hal yang akan kita siapkan untuk melakukan ``deployment``

### Install Nginx dan MariaDB Server
```sh
sudo apt-get update
sudo apt-get wget -y
sudo apt-get install git -y
sudo apt-get install nginx -y
sudo apt-get install mariadb-server -y
```

### Install PHP dan PHP-FPM (Fastcgi Package Manager)
```sh
apt-get install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2
curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

sudo apt-get install php8.1-mbstring php8.1-xml php8.1-cli php8.1-common php8.1-intl php8.1-opcache php8.1-readline php8.1-mysql php8.1-fpm php8.1-curl -y
```

## Deployment

Lalu jalankan **PHP-FPM**, **Nginx**, **MySQL**
```sh
service nginx start
service php8.1-fpm start
service mysql start
```

Cek Version 
```sh
php -v
composer --version
mariadb --version
```

Cek ``firewall`` atau biasa disebut ``ufw`` dengan menjalankan perintah 
```sh
ufw app list
```

![image](https://github.com/Caknoooo/ams-laravel-deployment/assets/92671053/36490973-8cab-499e-af2c-98785eac637a)

Setelah itu jalankan perintah berikut 
```sh
ufw allow 'Nginx HTTP'
ufw allow 'Nginx HTTPS'
ufw allow 'Nginx Full'
```

#### Setup MySQL
Setelah itu kita fokus pada ``MySQL`` terlebih dahulu dengan menjalankan perintah berikut
```sh 
mysql -u root -p

CREATE USER 'testing'@'%' IDENTIFIED BY 'testing';
CREATE USER 'testing'@'localhost' IDENTIFIED BY 'testing';
CREATE DATABASE testing;
GRANT ALL PRIVILEGES ON *.* TO 'testing'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'testing'@'localhost';
FLUSH PRIVILEGES;
```

![image](https://github.com/Caknoooo/ams-laravel-deployment/assets/92671053/d9e36dae-4063-4c28-aeb4-20c4eb630d30)

Jika ingin melakukan ``testing``, maka jalankan perintah berikut 
```sh
mysql -u testing -p
#enter your password: testing
```

#### Setup git
Jalankan perintah Berikut
```sh 
cd /var/www && git clone https://github.com/Caknoooo/ams-laravel-mvc
cd /var/www/ams-laravel-mvc && cp .env.example .env
```

Setelah itu buka folder ``ams-laravel-mvc``, lalu buka file ``.env``. Ubah konfigurasi ``.env`` tersebut menjadi berikut
```
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=testing
DB_USERNAME=testing
DB_PASSWORD=testing
```

Setelah itu jalankan beberapa ``perintah`` berikut untuk melakukan beberapa konfigurasi dan melakukan ``install dependencies`` 
```sh
cd /var/www/ams-laravel-mvc && composer install
cd /var/www/ams-laravel-mvc && php artisan key:generate
cd /var/www/ams-laravel-mvc && php artisan migrate
cd /var/www/ams-laravel-mvc && php artisan db:seed
```

#### Setup Nginx 
Sekarang kita melakukan setup ``web-server`` yang menggunakan ``nginx`` dengan menjalankan perintah berikut 

```sh
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
```

Setelah itu lakukan ``restart`` pada nginx dengan perintah Berikut
```sh 
service nginx restart
```