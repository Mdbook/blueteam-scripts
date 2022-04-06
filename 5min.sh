# Install packages
if [ `which apt` ]; then
    apt-get update
    apt-get install --reinstall passwd
    apt-get install --reinstall coreutils
    apt-get install sshpass
    apt-get install golang-go
    apt-get install nmap
elif [ `which yum` ]; then
    yum update
    yum install epel-release -y
    yum reinstall passwd -y
    yum reinstall coreutils -y
    yum install sshpass -y
    yum install golang -y
    yum install nmap -y
elif [ `which pacman` ]; then
    pacman -Syu --noconfirm
    pacman -Scc passwd --noconfirm
    pacman -Scc coreutils --noconfirm
    pacman -S sshpass --noconfirm
    pacman -S go --noconfirm
    pacman -S nmap --noconfirm
elif [ `which dnf` ]; then
    dnf update -y
    dnf reinstall passwd-y
    dnf reinstall coreutils -y
    dnf install sshpass-y
    dnf install golang -y
    dnf install nmap-y
else
    echo "No valid package installers found"
fi

cd scripts

if [ `which python3` ]; then
    python3 ssh-keynuke.py
    python3 disable_users.py
    chmod +x iptables.py
    cp iptables.py /usr/sbin/iptables-service
    python3 create-service.py --name=iptables --desc=iptables_service --path=/usr/sbin/iptables-service --command="-l -q $@"
    # python3 iptables.py $@
elif [ `which python` ]; then
    python ssh-keynuke.py
    python disable-users.py
    chmod +x iptables.py
    cp iptables.py /usr/sbin/iptables-service
    cp $(which python) /usr/bin/python3
    python create-service.py --name=iptables --desc=iptables_service --path=/usr/sbin/iptables-service --command="-l -q $@"
elif [ `which python2` ]; then
    python2 ssh-keynuke.py
    python2 disable_users.py
    python2 iptables.py $@
elif [ `which py` ]; then
    py ssh-keynuke.py
    py disable_users.py
    chmod +x iptables.py
    cp iptables.py /usr/sbin/iptables-service
    cp $(which py) /usr/bin/python3
    py create-service.py --name=iptables --desc=iptables_service --path=/usr/sbin/iptables-service --command="-l -q $@"
fi

echo "Displaying /etc/hosts"
echo
cat /etc/hosts