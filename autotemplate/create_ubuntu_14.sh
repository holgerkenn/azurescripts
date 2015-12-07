#!/bin/bash -x

UBUNTUIMAGE=`azure vm image list |grep -i Ubuntu-14_04-LTS-amd64-server |tail -1 | awk '{print $2}'`

azure vm create -e -t myCert.pem -P -z "Small" -l "West Europe" $1 $UBUNTUIMAGE templateuser

