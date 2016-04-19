#!/bin/bash
set -eux

################
## Base system

# Disable SELinux
/sbin/getenforce | grep -i disabled || /sbin/setenforce 0
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/sysconfig/selinux /etc/selinux/config

# Enable external YUM repos
yum -y reinstall https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y reinstall https://centos7.iuscommunity.org/ius-release.rpm
yum -y reinstall https://repo.mysql.com/mysql57-community-release-el7-8.noarch.rpm

# System update
yum -y update

# Useful utilities
sudo yum -y install htop vim sysstat nc

######################
## Install LEMP stack

# Nginx
yum -y install nginx

# PHP
yum -y install php56u php56u-fpm-nginx

# MySQL
yum -y install mysql-comunity-server
