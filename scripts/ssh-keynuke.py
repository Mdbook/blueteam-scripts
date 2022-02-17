import os

os.chdir("/home")
for file in os.listdir("."):
    if os.path.isdir(file):
        print(file)
        # os.system("rm -rf " + file + "")
