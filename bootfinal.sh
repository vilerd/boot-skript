#!/bin/bash

echo -e "\e[1;36m~~~The magic begins~~~\e[0m"
echo -e "\e[1;36m~~~START~~~\e[0m"
echo -e "\e[1;33mVersion 1.0.1\e[0m"

sudo mkdir /tmp/bootlog
echo -e "\e[1;34mLogging is performed in /tmp/bootlog/logboot.txt\e[0m"
echo "Start" >> /tmp/bootlog/logboot.txt
echo -e "\e[1;32mDirectory for logging created!\e[0m"

ADDRESS="www.google.ua"
if ping -c 1 -s 1 -W 1 $ADDRESS
then
echo -e "\e[1;32mConnection OK!\e[0m"
echo "Network OK!" >> /tmp/bootlog/logboot.txt
else
echo -e "\e[1;31mConnection Lost!!!\e[0m"
echo -e "\e[1;33mCheck network connection!\e[0m"
echo "Network faill" >> /tmp/bootlog/logboot.txt
exit
fi

sudo apt-get update && apt-get upgrade -y
echo -e "\e[1;32mSystem updated\e[0m"
echo "System updated" >> /tmp/bootlog/logboot.txt

sudo apt-get install ssh -y
sed -i '/Port 22/c\Port 2202' /etc/ssh/sshd_config
echo -e "\e[1;32mThe SSH package is installed The connection port is specified\e[0m"
/etc/init.d/ssh restart
echo "Install SSH Port=22" >> /tmp/bootlog/logboot.txt

sudo mkdir /tmp/boot
sudo wget -P /tmp/boot https://raw.githubusercontent.com/vilerd/boot.sh/master/demonforiptables
sudo mv /tmp/boot/demonforiptables /etc/init.d/iptables
sudo chmod +x /etc/init.d/iptables
sudo mkdir /etc/iptables.d
sudo wget -P /tmp/boot https://raw.githubusercontent.com/vilerd/boot.sh/master/iptablesactive
sudo wget -P /tmp/boot https://raw.githubusercontent.com/vilerd/boot.sh/master/iptablesinactive
sleep 1s
sudo  mv /tmp/boot/iptablesactive /etc/iptables.d/active
sleep 1s
sudo mv /tmp/boot/iptablesinactive /etc/iptables.d/inactive
sleep 1s
/etc/init.d/iptables start
iptables-save
echo "#! /sbin/iptables-restore" > /etc/network/if-up.d/iptables-rules
iptables-save >> /etc/network/if-up.d/iptables-rules
sudo chmod +x /etc/network/if-up.d/iptables-rules
sudo ls -lA /etc/network/if-up.d/ipt*
echo -e "\e[1;32mIPtables active\e[0m"
echo "Iptables active!" >> /tmp/bootlog/logboot.txt

sudo apt-get install vim -y
echo -e "\e[1;32mInstall vim\e[0m"
echo "Install vim" >> /tmp/bootlog/logboot.txt

sudo apt-get install mc -y
echo -e "\e[1;32mInstall mc\e[0m"
echo "Install mc" >> /tmp/bootlog/logboot.txt

sudo apt-get install ntp -y
echo -e "\e[1;32mInstall ntp\e[0m"
echo "Install ntp" >> /tmp/bootlog/logboot.txt

sudo apt install curl -y
echo -e "\e[1;32mInstall curl\e[0m"
echo "Install curl" >> /tmp/bootlog/logboot.txt

sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password 1993'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password 1993'
sudo apt-get install -y mysql-server mysql-client
echo -e "\e[1;32mInstall MySQL\e[0m"
echo -e "\e[1;34mPASS=1993\e[0m"
echo "Install MySQL-pass=1993" >> /tmp/bootlog/logboot.txt

mysql -u root -p1993 <<EOF
CREATE DATABASE wordpress;
CREATE USER vilerd@localhost IDENTIFIED BY '1993';
grant all privileges on wordpress.* to 'vilerd'@'localhost';
FLUSH PRIVILEGES;
EOF
echo -e "\e[1;32mDatabase WordPress created\e[0m"
echo -e "\e[1;34mDB USER=vilerd PASS=1993\e[0m"
echo "Created DB USER=vilerd PASS=1993" >> /tmp/bootlog/logboot.txt

sudo apt install nginx -y
echo -e "\e[1;32mInstall nginx\e[0m"
echo "Install nginx" >> /tmp/bootlog/logboot.txt

sudo apt install -y php7.0-fpm php7.0-mysql php7.0-mbstring php7.0-xml php7.0-curl php7.0-zip php7.0-gd php7.0-xmlrpc
sudo cp  /etc/php/7.0/fpm/php.ini  /etc/php/7.0/fpm/php.ini.orig
sudo cp  /etc/php/7.0/fpm/pool.d/www.conf  /etc/php/7.0/fpm/pool.d/www.conf.orig
sudo sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/'  /etc/php/7.0/fpm/php.ini
sudo sed -i 's|listen = /run/php/php7.0-fpm.sock|listen =127.0.0.1:9000|g' /etc/php/7.0/fpm/pool.d/www.conf
echo -e "\e[1;32mInstall php modules\e[0m"
echo "Install php modules" >> /tmp/bootlog/logboot.txt

sudo rm /var/www/html/index.nginx-debian.html
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

sudo wget -P /tmp/boot/ https://raw.githubusercontent.com/vilerd/boot.sh/master/virtualhostwp 
sudo mv /tmp/boot/virtualhostwp /etc/nginx/sites-available/wordpress
sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress

wget http://wordpress.org/latest.tar.gz -q -P /tmp/boot
tar xzfC /tmp/boot/latest.tar.gz /tmp/boot
sudo cp /tmp/boot/wordpress/wp-config-sample.php  /tmp/boot/wordpress/wp-config.php
echo -e "\e[1;32mDownload Wordpress and its preparation\e[0m"
echo "Download Wordpress and its preparation" >> /tmp/bootlog/logboot.txt

sudo sed -i "s/database_name_here/wordpress/"  /tmp/boot/wordpress/wp-config.php
sudo sed -i "s/username_here/vilerd/"       /tmp/boot/wordpress/wp-config.php
sudo sed -i "s/password_here/1993/"   /tmp/boot/wordpress/wp-config.php
sudo sed -i "s/wp_/wnotp_/"               /tmp/boot/wordpress/wp-config.php

SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
sudo printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /tmp/boot/wordpress/wp-config.php
sudo cp -a /tmp/boot/wordpress/. /var/www/html/
sudo chown -R www-data: /var/www/html
echo -e "\e[1;32mWordpress prepared\e[0m"
echo "Wordpress prepared" >> /tmp/bootlog/logboot.txt

/etc/init.d/nginx restart
/etc/init.d/php7.0-fpm restart
echo -e "\e[1;32mnginx & php restart\e[0m"
echo "nginx & php restart" >> /tmp/bootlog/logboot.txt


wite=`curl http://smart-ip.net/myip | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"`
echo -e "\e[1;36mYour external IP=$wite\e[0m"
localip=`ip route show | grep -o -E "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)"`
echo "$localip" >> /tmp/boot/ip.txt
ip=`cat /tmp/boot/ip.txt | sed -n '3p' | awk '{print $1}'`
echo -e "\e[1;36mYour local IP=$ip\e[0m"

rm -r /tmp/boot
echo -e "\e[1;31mGarage remove\e[0m"
echo "Garage remove" >> /tmp/bootlog/logboot.txt

echo "Created by ~Vilerd~  | Version 1.0.1" >> /tmp/bootlog/logboot.txt
echo -e "\e[1;33mCreated by ~Vilerd~ | Version 1.1\e[0m"
echo -e "\e[1;33m~~~BYE~~~\e[0m"
