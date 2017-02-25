#!/bin/bash
#
# Script: tower-install.sh
# Author: Mauro Medda <mauro.medda at yoox.com >
# Version: 0.1A
# Date: Wed Aug 03 2016
# Purpose: This script performs a full stack installation of Ansible Tower 3+ in a single
#          AWS EC2 instance using the ansible-tower-setup package.
#
# Revisions:
#
#

## GLOBAL VARS ##

epel_url="http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm"
ansible_version="3.0.1"
ansible_src_url="http://releases.ansible.com/ansible-tower/setup/"
ansible_src_arc="ansible-tower-setup-${ansible_version}.tar.gz"
work_dir="/tmp/tower"
ansible_admin_passwd="XXXXXXX"
ansible_dbadmin_passwd=${ansible_admin_passwd}
script=${0##*/}
thishost=${HOSTNAME%%.*}
today=$(date +%Y%m%d)
temp01=/tmp/${script}.01.$$

log=/var/log/tower/${script}.log

ver=0.1

## FUNCTIONS ##


Log() {
        message=$(echo ${1} | sed -e "s,(,\\\(,g" -e "s,),\\\),g")

        if [ "${silent}" = "" ]; then
                TEE=" | tee -a ${log}"
          else
                TEE=" >> ${log}"
        fi

        if [ -z "${message}" ]; then
                eval echo "\$(date '+%h %d %H:%M:%S') ${thishost} ${script}[$$]: no message provided" ${TEE}
          else
                eval echo "$(date '+%h %d %H:%M:%S') ${thishost} ${script}[$$]: ${message}" ${TEE}
        fi

        return 0
}


update_os () {

   Log "Updating OS..."
   sudo yum update -y
   Log "OS Update finished"

}

install_dependencies() {

   Log "Installing Ansible Tower dependencies"
   yum install -y $epel_url
   yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional
   yum clean all
   yum update -y
   yum install -y python-setuptools
   yum install -y python-daemon
   yum install -y pystache
   yum install -y python-ecdsa
   yum install -y python-paramiko
   yum install -y python-keyczar
   yum install -y python-crypto
   yum install -y python-httplib2
   yum install -y wget
   Log "Dependencies installation finished"
}

download_tower () {
   Log "Downloading the latest Tower release"
   wget -N ${ansible_src_url}/${ansible_src_arc}
   Log "Ansible Tower setup archive saved in $(pwd)"

}

extract_src_dist_file () {

   Log "Extracting distribution file and change ownership and permissions"

   tar xf ${ansible_src_arc} &&
   chown -R 0:0 ansible-tower-setup* &&
   chmod -R go-ws ansible-tower-setup*

}

install_tower () {

   Log "Changing working dir to ansible-tower-setup*"

   cd ansible-tower-setup*

   Log "Working Directory $(pwd)"

   Log "Relaxing the min var requirements"
   sed -i -e "s/10000000000/100000000/" roles/preflight/defaults/main.yml

   Log "Allowing sudo with out tty"
   sed -i -e "s/Defaults    requiretty/Defaults    \!requiretty/" /etc/sudoers

   Log "Creating inventory file"

   Log "Creating inventory file"
   sed -i "s#admin_password=''#admin_password\='${ansible_admin_passwd}'#g" inventory
   sed -i "s#redis_password=''#redis_password\='${ansible_dbadmin_passwd}'#g" inventory
   sed -i "s#pg_password=''#pg_password\='${ansible_dbadmin_passwd}'#g" inventory
   
   Log "Runnig setup"

   ANSIBLE_SUDO=True ./setup.sh

   Log "Ansible Tower setup execution finished!"


}

## MAIN ##

if [[ $(id -u) -ne 0 ]]; then
   Log "You MUST be ROOT to run this script. Execute sudo $0"
   exit 127
fi

Log "Creating working and log directory"
mkdir -pv $work_dir
mkdir -pv /var/log/tower

Log "Moving to working directory $work_dir"
cd $work_dir

Log "Working directory $(pwd)"

Log "Execute functions"
install_dependencies
download_tower
extract_src_dist_file
install_tower

Log "Ansible Tower installation completed"
Log "Remember to change your admin password. Use: tower-manage changepassword admin"
Log "You can access to your Ansible Tower installation trough: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
