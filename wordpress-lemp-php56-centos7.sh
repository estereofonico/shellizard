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
rpm -q mysql57-community-release || yum -y install https://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm

# System update
yum -y update

# Useful utilities
sudo yum -y install htop vim sysstat nc


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
mkdir -p /var/nginx/html
chown nginx: /var/nginx/html

# Enable services
sudo systemctl enable  php-fpm
sudo systemctl enable  nginx
sudo systemctl enable  mysqld

# Start services
sudo systemctl restart php-fpm
sudo systemctl restart nginx



