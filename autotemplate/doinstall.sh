#!/bin/bash -x
export vmname=$1
export vmlfullname=$1.cloudapp.net
# make sure we use the latest package repository info
apt-get update
# install some basic tooling. 
apt-get install -y debconf-i18n jove git

# prepare settings so we don't get asked during install
#echo 'mysql-server  mysql-server/root_password password  '  |debconf-set-selections
#echo 'mysql-server  mysql-server/root_password_again password   '  |debconf-set-selections

#install packets
apt-get install -y apache2 apache2-bin php5 php5-curl 
#apt-get install -y mysql-server php5-mysql
apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python 

#when something isn't available in the repository, pull it via wget
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.760_all.deb

#and install it from a local package file
dpkg --install webmin_1.760_all.deb

#example code to set up a website and create an initial database schema
#mysql -u root < /home/templateuser/createdb.mysql
#cd /var/www/html
#git clone https://github.com/<url to sourcecode to pull from github>
