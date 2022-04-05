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
    python3 disable-users.py
    python3 iptables.py $@
elif [ `which python` ]; then
    python ssh-keynuke.py
    python disable-users.py
    python iptables.py $@
elif [ `which python2` ]; then
    python2 ssh-keynuke.py
    python2 disable-users.py
    python2 iptables.py $@
elif [ `which py` ]; then
    py ssh-keynuke.py
    py disable-users.py
    py iptables.py $@
fi

echo "Displaying /etc/hosts"
echo
cat /etc/hosts