#!/bin/bash

allow="true"

if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]
then
    for gr in $(id -Gn $PAM_USER)
        do echo $gr
        if [ $gr = "admin" ]
        then
            allow="true"
        else
            allow="false"
        fi
    done
fi

echo -n "allow: "
echo $allow

if [ $allow = "true" ]
then
    exit 0
else
    exit 1
fi
