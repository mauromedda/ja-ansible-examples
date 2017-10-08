#!/bin/bash

INSTANCE_IP="$(curl -q http://169.254.169.254/latest/meta-data/public-ipv4)"

curl -q -X "POST" -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "X-Rundeck-Auth-Token: XXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
  -d "{\"argString\":\"-pk centos.pem -playbook httpd.yml -repo_name https://github.com/mauromedda/ja-ansible-examples -target $INSTANCE_IP \"}" \
  http://$RUNDECK_IP:4440/api/20/job/b5f66a21-52b1-4b7a-9ff8-31aa0751892b/run > /tmp/.rundeck_$INSTANCE_IP.log

