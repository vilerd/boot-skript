#!/bin/bash

echo -e "\e[1;36m~~~START~~~\e[0m"

mkdir /tmp/bootlog
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

apt-get update -y
apt-get upgrade -y
echo -e "\e[1;32mSystem updated\e[0m"
echo "System updated" >> /tmp/bootlog/logboot.txt

apt-get install ssh -y
sed -i '/Port 22/c\Port 2202' /etc/ssh/sshd_config
echo -e "\e[1;32mThe SSH package is installed The connection port is specified\e[0m"
/etc/init.d/ssh restart
echo "Install SSH Port=22" >> /tmp/bootlog/logboot.txt

mkdir /tmp/boot
wget -P /tmp/boot https://raw.githubusercontent.com/vilerd/boot.sh/master/demonforiptables
mv /tmp/boot/demonforiptables /etc/init.d/iptables
chmod +x /etc/init.d/iptables
mkdir /etc/iptables.d
wget -P /tmp/boot https://raw.githubusercontent.com/vilerd/boot.sh/master/iptablesactive
wget -P /tmp/boot https://raw.githubusercontent.com/vilerd/boot.sh/master/iptablesinactive
sleep 1s
mv /tmp/boot/iptablesactive /etc/iptables.d/active
sleep 1s
mv /tmp/boot/iptablesinactive /etc/iptables.d/inactive
sleep 1s
/etc/init.d/iptables start
iptables-save
echo "#! /sbin/iptables-restore" > /etc/network/if-up.d/iptables-rules
iptables-save >> /etc/network/if-up.d/iptables-rules
chmod +x /etc/network/if-up.d/iptables-rules
ls -lA /etc/network/if-up.d/ipt*
echo -e "\e[1;32mIPtables active\e[0m"
echo "Iptables active!" >> /tmp/bootlog/logboot.txt

apt-get install vim -y
echo -e "\e[1;32mInstall vim\e[0m"
echo "Install vim" >> /tmp/bootlog/logboot.txt

apt-get install mc -y
echo -e "\e[1;32mInstall mc\e[0m"
echo "Install mc" >> /tmp/bootlog/logboot.txt

apt-get install ntp -y
echo -e "\e[1;32mInstall ntp\e[0m"
echo "Install ntp" >> /tmp/bootlog/logboot.txt

sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password 1993'
sudo debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password 1993'
sudo apt-get install -y mysql-server mysql-client
echo -e "\e[1;32mInstall MySQL\e[0m"
echo -e "\e[1;34mPASS=1993\e[0m"
echo "Install MySQL-pass=1993" >> /tmp/bootlog/logboot.txt

mysql -u root -p1993 <<EOF
CREATE DATABASE wordpress;
CREATE USER wordpressuser@localhost IDENTIFIED BY '1993';
FLUSH PRIVILEGES;
EOF
echo -e "\e[1;32mDatabase WordPress created\e[0m"
echo -e "\e[1;34mDB USER=vilerd PASS=1993\e[0m"
echo "Created DB USER=vilerd PASS=1993" >> /tmp/bootlog/logboot.txt

rm -r /tmp/boot
echo -e "\e[1;31mGarage remove\e[0m"
echo "Garage remove" >> /tmp/bootlog/logboot.txt

echo -e "\e[1;33mvilerd 2k17\e[0m"
