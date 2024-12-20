#!/bin/bash -e
################################################################################
##  File:  install-nginx.sh
##  Desc:  Install Nginx
################################################################################
set -x
# Install Nginx
apt-get install nginx

# Disable nginx.service
systemctl is-active --quiet nginx.service && systemctl stop nginx.service
systemctl disable nginx.service
