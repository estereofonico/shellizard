#!/bin/bash
set -eux

####################
## External scripts

MYSQLHELPER='https://raw.githubusercontent.com/saisyukusanagi/shellizard/master/mysql57-root-password.expect'

################
## Base system

# Disable SELinux
/sbin/getenforce | grep -i disabled || /sbin/setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux /etc/selinux/config

# Enable external YUM repos
rpm -q epel-release || yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -q ius-release  || yum -y install https://centos7.iuscommunity.org/ius-release.rpm
rpm -q mysql57-community-release || yum -y install https://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm

# System update
yum -y update

# Useful utilities
sudo yum -y install htop vim sysstat nc expect pwgen


######################
## Install LEMP stack

# Nginx
yum -y install nginx

# PHP
yum -y install php56u-fpm-nginx php56u-mysql

# MySQL
yum -y install mysql-community-server


##########################
## Services configuration

# Change NGINX root
sed -i 's/\/usr\/share\/nginx\/html/\/var\/nginx\/html/g' /etc/nginx/nginx.conf
mkdir -p /var/nginx

# Enable services
sudo systemctl enable  php-fpm
sudo systemctl enable  nginx
sudo systemctl enable  mysqld

# Start services
sudo systemctl restart php-fpm
sudo systemctl restart nginx
sudo systemctl restart mysqld

#######################
## MySQL Configuration

if [ -f /root/.mylogin.cnf ]; then
   echo "MySQL user config already exists"
else
   curl $MYSQLHELPER -o /var/lib/mysql/.root-password.expect -L
   expect /var/lib/mysql/.root-password.expect $(grep -i 'A temporary password' /var/log/mysqld.log | awk '{print $NF}')
   rm -f /var/lib/mysql/.root-password.expect
fi

##########################
## Wordpress installation

if [ -d /var/nginx/html ]; then
   echo "Wordpress already installed"
else
   curl https://wordpress.org/latest.tar.gz -o /var/nginx/wp-installer.tar.gz -L
   tar -xvzf /var/nginx/wp-installer.tar.gz -C /var/nginx
   mv /var/nginx/wordpress /var/nginx/html
   chown nginx: /var/nginx/html
fi

if [ -d /var/lib/mysql/wordpress ]; then
   echo "Database already exists"
else
   WPMYPASS=$(pwgen -1 -B 14)
   echo "CREATE DATABASE wordpress;" | mysql
fi


#if [ -d /var/lib/mysql/wordpress ]; then
#   echo "Database already exists"
#else
   WPMYPASS=$(pwgen -1 -yncB 14)
#   echo "CREATE DATABASE wordpress;" | mysql
   echo "GRANT ALL PRIVILEGES ON wordpress.* TO wordpress IDENTIFIED BY "\'$WPMYPASS\'";" | mysql
   echo "FLUSH PRIVILEGES;" | mysql
#fi

echo "Your Wordpress MySQL user is: wordpress"
echo "Your Wordpress MySQL password is: $WPMYPASS"
