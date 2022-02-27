# TODO: figure out if passwd is shimmed
# TODO: pass parameters to iptables.sh
# TODO: run all scripts

if [ which apt ]; then
    apt-get install --reinstall passwd
    apt-get install --reinstall coreutils
    apt-get install sshpass
    apt-get install golang-go
    apt-get install nmap
elif [ which yum ]; then
    yum 