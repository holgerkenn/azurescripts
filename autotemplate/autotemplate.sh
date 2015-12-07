#!/bin/bash -x
export vmname=$1
export vmfullname=$vmname.cloudapp.net
export templatename=$2
ssh-keygen -f ~/.ssh/known_hosts  -R $vmfullname
bash create_ubuntu_14.sh $vmname
bash waitforup.sh $vmfullname 22
scp -i myPrivateKey.key ./doinstall.sh deprovision.sh templateuser@$vmfullname:
ssh -i myPrivateKey.key -l templateuser $vmfullname sudo bash ./doinstall.sh $vmname
ssh -i myPrivateKey.key -l templateuser $vmfullname sudo at now + 1 minutes \</home/templateuser/deprovision.sh
sleep 120
azure vm shutdown $vmname
azure vm capture -t $vmname $templatename
