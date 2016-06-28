#!/bin/bash
echo -n "Enter your full name:"
read name
echo -n "Enter release version:"
read version

curl -H "x-api-key:YOUR_API_KEY" -d "deployment[app_name]=hub" -d "deployment[revision]=$version" -d "deployment[user]=$name" https://api.newrelic.com/deployments.xml
 
if [[ $? != 0 ]];
                then
                echo "Error! Something goes wrong."
                exit 1
                else
                echo "Information successfully added to NewRelic"
                exit 1
        fi
