import os

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

name = input("Service name: ") + ".service"
path = input("Executable binary path: ")
command = input("Command and args: ")
desc = input("Description: ")

service = service.replace("{description}", desc).replace("{exec}", path + " " + command)
f = open("/etc/systemd/system/" + name, "w")
f.write(service)
f.close()
print(service)
print()
print("Wrote to /etc/systemd/system/" + name)
os.system("systemctl enable " + name)
os.system("systemctl start " + name)
print("Started and enabled service.")