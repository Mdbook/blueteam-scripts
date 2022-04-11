import os
import sys
if sys.version_info[0] < 3:
    startuser = raw_input("Username to start with: ")
    whitelist = raw_input("Whitelist (separated by commas): ")
else:
    startuser = input("Username to start with: ")
    whitelist = input("Whitelist (separated by commas): ")
whitelist = whitelist.split(",")

go = False
userlist = open("/etc/passwd", "r")
line = userlist.readline()
while line:
    username = line.split(":")[0]
    if username == startuser:
        go = True
    if go and username not in whitelist:
        # os.system("sudo killall -u " + str(username))
        # os.system("sudo skill -kill -u " + str(username))
        os.system("sudo usermod -L " + str(username))
        os.system("sudo passwd -l " + str(username))
        os.system("sudo chage -E0 " + str(username))
        os.system("sudo usermod -s /sbin/nologin " + str(username))
        print("Disabled " + username)
    else:
        print("Skipping " + username)
    line = userlist.readline()