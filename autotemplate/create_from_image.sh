#!/bin/bash -x


UBUNTUIMAGE="<your image name goes here>"
PASSWORD="<your password goes here>"
echo Password is $PASSWORD

#azure vm create -e -t myCert.pem -z "Small" -l "West Europe" $1 $UBUNTUIMAGE azureuser "$PASSWORD"

azure vm endpoint create $1 10000 10000
azure vm endpoint create $1 25 25
