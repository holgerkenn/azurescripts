#!/bin/bash 

while (dig $1 |grep ^$1|awk -e '{if ($5=="0.0.0.0") {exit 0} else {exit 1}}'); do
	echo $1 not started, sleeping
	sleep 10;
	done

while ! (ssh -i myPrivateKey.key -p $2 $1 /bin/true); do
	echo $1 not responding on port $2, sleeping
	sleep 10;
	done
	
