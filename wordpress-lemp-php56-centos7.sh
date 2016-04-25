#!/bin/bash
set -eux

################
## Base system

# Disable SELinux
/sbin/getenforce | grep -i disabled || /sbin/setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux /etc/selinux/config

# Enable external YUM repos
rpm -q epel-release || yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -q ius-release  || yum -y install https://centos7.iuscommunity.org/ius-release.rpm

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


##########################
## Services configuration

# Change NGINX root
sed -i 's/\/usr\/share\/nginx\/html/\/var\/nginx\/html/g' /etc/nginx/nginx.conf
mkdir -p /var/nginx

# Change php-fpm exec user
sed -i 's/user\ \=\ php-fpm/user\ \=\ nginx/g' /etc/php-fpm.d/www.conf
sed -i 's/group\ \=\ php-fpm/user\ \=\ nginx/g' /etc/php-fpm.d/www.conf

# Enable services
sudo systemctl enable  php-fpm
sudo systemctl enable  nginx

# Start services
sudo systemctl restart php-fpm
sudo systemctl restart nginx

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

##################
## End of process
echo "Installation finished!!!"