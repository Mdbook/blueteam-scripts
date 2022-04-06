#!/usr/bin/env python3
import os, sys

service = "[Unit]\n"\
"Description={description}\n"\
"After=network.target\n"\
"StartLimitIntervalSec=0\n"\
"\n"\
"[Service]\n"\
"Type=simple\n"\
"Restart=always\n"\
"RestartSec=1\n"\
"User=root\n"\
"ExecStart={exec}\n"\
"\n"\
"[Install]\n"\
"WantedBy=multi-user.target"

name = False
desc = False
path = False
command = False

for arg in sys.argv:
    if "--name=" in arg:
        name = arg.split('=')[1] + ".service"
    if "--path=" in arg:
        path = arg.split('=')[1]
    if "--command=" in arg:
        command = arg.split('=')[1]
    if "--desc=" in arg:
        desc = arg.split('=')[1]
    if arg == "-h" or arg == "--help":
        print("Usage: python3 createservice.py [--name=NAME] [--path=PATH] [--command=COMMAND] [--desc=DESC]")
        exit(0)
if not name:
    name = input("Service name: ") + ".service"
if not path:
    path = input("Executable binary path: ")
if not command:
    command = input("Command and args: ")
if not desc:
    desc = input("Description: ")

service = service.replace("{description}", desc).replace("{exec}", path + " " + command)
f = open("/lib/systemd/system/" + name, "w")
f.write(service)
f.close()
print(service)
print()
print("Wrote to /lib/systemd/system/" + name)
os.system("systemctl enable " + name)
os.system("systemctl start " + name)
print("Started and enabled service.")