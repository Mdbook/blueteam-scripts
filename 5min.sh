# Install packages
if [ `which apt` ]; then
    apt-get update
    apt-get install --reinstall passwd -y
    apt-get install --reinstall coreutils -y
    apt-get install sshpass -y
    apt-get install golang-go -y
    apt-get install nmap -y
    apt-get install python3 -y
elif [ `which yum` ]; then
    yum update
    yum install epel-release -y
    yum reinstall passwd -y
    yum reinstall coreutils -y
    yum install sshpass -y
    yum install golang -y
    yum install nmap -y
    yum install python3 -y
elif [ `which pacman` ]; then
    pacman -Syu --noconfirm
    pacman -Scc passwd --noconfirm
    pacman -Scc coreutils --noconfirm
    pacman -S sshpass --noconfirm
    pacman -S go --noconfirm
    pacman -S nmap --noconfirm
    pacman -S python3 --noconfirm
elif [ `which dnf` ]; then
    dnf update -y
    dnf reinstall passwd -y
    dnf reinstall coreutils -y
    dnf install sshpass -y
    dnf install golang -y
    dnf install nmap -y
    dnf install python3 -y
else
    echo "No valid package installers found"
    exit
fi

echo "---Displaying /etc/hosts---"
echo
cat /etc/hosts
TEST="nil"
read -p "Press any key to continue..." $TEST

cd scripts

if [ `which python3` ]; then
    python3 ssh-keynuke.py
    echo "---Creating new user---"
    ./create_user.sh
    echo "Displaying /etc/passwd..."
    cat /etc/passwd
    python3 disable-users.py
    # chmod +x ipchairs.py
    # cp ipchairs.py /usr/sbin/ipchairs
    # python3 create-service.py --name=ipchairs --desc=iptables_service --path=/usr/sbin/ipchairs --command="-l -q $@"
    # python3 ipchairs.py $@
else
    echo "Error: python3 is not installed."
fi

./recurring_plan.sh