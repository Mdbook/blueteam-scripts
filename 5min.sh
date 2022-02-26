# TODO: figure out if passwd is shimmed
# TODO: pass parameters to iptables.sh
# TODO: run all scripts

if [ which apt ]; then
    apt-get install --reinstall passwd
    apt-get install --reinstall coreutils
elif [ which yum ]; then
    yum 