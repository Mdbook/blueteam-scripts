import os, time, sys

isDemo = False
safeMode = True
onlyFlush = False
disableFirewalls = True
flushAllAllow = True
preDrop = False
preKill = False
basicFlush = False
allowEstablished = True
allowICMP = True
isQuiet = False

allowPorts = {
    "tcp":[22, 80, 443],
    "udp":[]
}

tables = [
    "nat",
    "mangle",
    "filter",
    # "raw"
    ]
tables_flush = [
    "nat",
    "mangle",
    "filter",
    "raw"
    ]
chains = {
    "nat":["PREROUTING", "POSTROUTING", "INPUT", "OUTPUT"],
    "mangle":["PREROUTING", "POSTROUTING", "INPUT", "OUTPUT", "FORWARD"],
    "filter":["INPUT", "OUTPUT", "FORWARD"],
    "raw":["PREROUTING", "OUTPUT"],
    "nil":["INPUT", "OUTPUT", "FORWARD"],
}

def exec(str):
    if not isQuiet:
        print(str)
    if not isDemo:
        if isQuiet:
            str += " 2>/dev/null"
        os.system(str)


def safe_mode():
    global allowEstablished, allowPorts, allowICMP
    tcp_allow = ','.join(str(e) for e in allowPorts.get("tcp"))
    udp_allow = ','.join(str(e) for e in allowPorts.get("udp"))
    for table in tables:
        for chain in chains.get(table):
            exec("iptables -t "+table+" -P " + chain + " ACCEPT")
            if allowEstablished:
                exec("iptables -t " + table + " -A " + chain + " -m state --state ESTABLISHED,RELATED -j ACCEPT")
            if tcp_allow != "":
                exec("iptables -t "+table+" -A "+chain+" -p tcp -m tcp -m multiport ! --dports "+tcp_allow+" -j DROP")
            if udp_allow != "":
                exec("iptables -t "+table+" -A "+chain+" -p udp -m udp -m multiport ! --dports "+udp_allow+" -j DROP")
            if not allowICMP:
                exec("iptables -t "+table+" -A "+chain+" -p icmp -j DROP")
    # for chain in chains.get("nil"):
    #     exec("iptables -P " + chain + " ACCEPT")
    #     if allowEstablished:
    #         exec("iptables -A " + chain + " -m state --state ESTABLISHED,RELATED -j ACCEPT")
    #     if tcp_allow != "":
    #         exec("iptables -A "+chain+" -p tcp -m tcp -m multiport ! --dports "+tcp_allow+" -j DROP")
    #     if udp_allow != "":
    #         exec("iptables -A "+chain+" -p udp -m udp -m multiport ! --dports "+udp_allow+" -j DROP")

def iron_wall():
    global allowEstablished, allowPorts, allowICMP
    tcp_allow = ','.join(str(e) for e in allowPorts.get("tcp"))
    udp_allow = ','.join(str(e) for e in allowPorts.get("udp"))
    for table in tables:
        for chain in chains.get(table):
            if tcp_allow != "":
                exec("iptables -t "+table+" -A "+chain+" -p tcp -m tcp -m multiport --dports "+tcp_allow+" -j ACCEPT")
            if udp_allow != "":
                exec("iptables -t "+table+" -A "+chain+" -p udp -m udp -m multiport --dports "+udp_allow+" -j ACCEPT")
            if allowEstablished:
                exec("iptables -t "+table+" -A "+chain+" -m state --state ESTABLISHED,RELATED -j ACCEPT")
            if allowICMP:
                exec("iptables -t "+table+" -A "+chain+" -p icmp --icmp-type echo-request -j ACCEPT")
            exec("iptables -t "+table+" -P "+chain+" DROP")
    # for chain in chains.get("nil"):
    #     if tcp_allow != "":
    #         exec("iptables -A "+chain+" -p tcp -m tcp -m multiport --dports "+tcp_allow+" -j ACCEPT")
    #     if udp_allow != "":
    #         exec("iptables -A "+chain+" -p udp -m udp -m multiport --dports "+udp_allow+" -j ACCEPT")
    #     if allowEstablished:
    #         exec("iptables -A "+chain+" -m state --state ESTABLISHED,RELATED -j ACCEPT")
    #     if allowICMP:
    #         exec("iptables -A "+chain+" -p icmp --icmp-type echo-request -j ACCEPT")
    #     exec("iptables -P "+chain+" DROP")



def pre_kill():
    pass

def disable_firewalls():
    exec("ufw disable 2> /dev/null")
    exec("systemctl disable firewalld 2> /dev/null")
    exec("systemctl stop firewalld 2> /dev/null")

def pre_drop():
    for table in tables_flush:
        for chain in chains.get(table):
            exec("iptables -t " + table + " -P " + chain + " DROP")
    for chain in chains.get("nil"):
        exec("iptables -P " + chain + " DROP")
    time.sleep(1)

def flushall_allow():
    global basicFlush
    if not basicFlush:
        exec("iptables -Z")
        exec("iptables -F")
        exec("iptables -X")
        for table in tables_flush:
            exec("iptables -Z -t " + table)
            exec("iptables -F -t " + table)
            exec("iptables -X -t " + table)
    else:
        exec("iptables -F")
        for table in tables_flush:
            exec("iptables -F -t " + table)


    for table in tables_flush:
        for chain in chains.get(table):
            exec("iptables -t " + table + " -P " + chain + " ACCEPT")
    for chain in chains.get("nil"):
        exec("iptables -P " + chain + " ACCEPT")
    return
    
def main():
    global disableFirewalls, flushAllAllow, preDrop, preKill, onlyFlush, safeMode, allowPorts, basicFlush, isDemo, isQuiet, allowICMP
    for arg in sys.argv:
        if arg == "-f" or arg == "--flush-only":
            onlyFlush = True
        elif arg == "-i" or arg == "--iron-wall":
            safeMode = False
        elif arg == "-d" or arg == "--drop-first":
            preDrop = True
        elif arg == "-b" or arg == "--basic-flush":
            basicFlush = True
        elif arg == "-p" or arg == "--ignore-ping":
            allowICMP = False
        elif arg == "-q" or arg == "--quiet":
            isQuiet = True
        elif arg == "--demo":
            isDemo = True
        elif "--tcp=" in arg:
            allowPorts['tcp'] = arg[6:].split(',')
        elif "--udp=" in arg:
            allowPorts['udp'] = arg[6:].split(',')
        elif arg == "--help" or arg == "-h":
            print("iptables.py- Michael Burke")
            print()
            print("Usage: python3 iptables.py [args]")
            print("-b or --basic-flush    |   Only basic flush (iptables -F)")
            print("-d or --drop-first     |   Drop all incoming connections for 1 second")
            print("                       |   before establishing new ones")
            print("-f or --flush-only     |   Flush all rules; don't establish new ones")
            print("-i or --iron-wall      |   Iron wall mode (NOT for use with cloud boxes)")
            print("-p or --ignore-ping    |   Block ICMP Ping requests")
            print("-q or --quiet          |   Suppress output")
            print("--demo                 |   Display rule commands, but don't execute them")
            print("--tcp=[PORTS]          |   Specify which TCP ports to allow (separated by ,)")
            print("--udp=[PORTS]          |   Specify which UDP ports to allow (separated by ,)")
            exit(0)

            
    if os.popen('whoami').read() != "root\n":
        print("Error: Must be run as root!")
        return
    if disableFirewalls:
        disable_firewalls()
    if flushAllAllow:
        flushall_allow()
    if preDrop:
        pre_drop()
    if preKill:
        pre_kill()
    if not onlyFlush:
        if safeMode:
            safe_mode()
        else:
            iron_wall()
    pass






main()