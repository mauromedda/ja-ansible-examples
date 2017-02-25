#!/bin/bash
# Script: ansible-install.sh
# Description: A simple bash script that install Ansible

#set -x                 # Enabling debug
#set -e                 # Exit immediatly if an error occurred
#set -n                 # Check syntax but not execute



### Variables

script=${0##*/}
log=/tmp/.${script}.$$.log
thishost=${HOSTNAME%%.*}
pkgs_list="epel-release python2-pip git ansible"
ansible_bin=/usr/bin/ansible

##
## Basic function
##

##
## Print a script utility recap
##
Header() {

  cat <<-EOF | sed 's,  ,,g'

  It's a simple and stupid script that install basic tools to start to code and
  delivery infrastructure using Ansible.

  It performs an unattended installation of the tools below:

  - ansible
  - git

  Execute the ${script} as super user.

  $ sudo -E ${script}


EOF

return 0
}

##
## Pretty logs function
##
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

# Check for uid 0

Check_UID() {

   if [[ $(id -u) -ne 0 ]];
    then
       Log "You MUST be root to execute ${script} [err=001]"
       Header
       exit 1
   fi

   return 0
}


##
## Check if distro is redhat or centos
##
Check_RHEL() {

    Log "Check distribution type"

        major_ver=$( rpm -qa \*-release | grep -Ei "redhat|centos" | cut -d"-" -f3 )
        if [[ "${major_ver}x" == "x" ]]; then
            Log "Not RedHat-like distro [err=002]"
            exit  2
        fi

    Log "Distribution: $(rpm -qa \*-release | grep -Ei "redhat|centos" | cut -d"-" -f1 ) ${major_ver}"

    return 0
}

##
## Update basic OS and package meta-data
##
Update_OS() {

    Log "Update OS packages and package metadata"

    yum_rc=$(yum update -y > /dev/null 2>&1 ; echo $? )
    if [[ $yum_rc -gt 0 ]] ; then
       Log "Yum update failed [err=003]"
       exit 3
    fi

    Log "Distro update complete"
    return 0
}

##
## Install required packages
##
Install_Req() {

    for pkg in ${pkgs_list}; do
        rc=$( rpm -qa | grep -q ^${pkg} 2>&1 > /dev/null ; echo $? )
        if [[ $rc -gt 0 ]]; then
            yum_rc=$( yum install -y $pkg 2>&1 > /dev/null ; echo $? )
            if [[ $yum_rc -gt 0 ]]; then
                Log "Package installation error [err=004]"
                exit 4
            fi
            Log "Package ${pkg} installation: SUCCESS!"
        else
            Log "Package ${pkg} already installed"
        fi
     done

    return 0
}

##
## Print Ansible installation recap
##

Ansible_Version(){
   if [[ -x $ansible_bin ]]; then
     $ansible_bin --version
     exit 0
   fi
}

### Main ###
Check_UID
Check_RHEL
Update_OS
Install_Req
Ansible_Version

exit 0
