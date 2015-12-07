rm /root/.ssh/authorized_keys
deluser --remove-all-files templateuser
rm -rf /home/templateuser
waagent -deproviion -force
