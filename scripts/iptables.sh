#Script to reset and initialize

#TODO: add mangle

#---CONFIG---
SAFE_MODE=TRUE
#In regular mode, the device will completely close off if the
#tables are flushed at any point. Safe mode prevents this.

#Enable/disable rules 
INPUT_RULES=TRUE
OUTPUT_RULES=FALSE
FORWARD_RULES=FALSE
PREROUTING_RULES=FALSE
POSTROUTING_RULES=FALSE

PRE_FLUSHALL=TRUE #Totally reset all rules before establishing new rules
PRE_DROPALL=TRUE #Attempt to drop connections before establishing new rules
DISABLE_FIREWALLS=TRUE #Disables UFW and Firewalld
BASIC_FLUSH=FALSE #Only flushes rules, skips setting zero counter and deleting chains

#Define the initial ports
#Every port has to have SOMETHING so the default is 1
INPUT_TCP=22,80,443
INPUT_UDP=1
FORWARD_TCP=1
FORWARD_UDP=1
OUTPUT_TCP=1
OUTPUT_UDP=1
PREROUTING_TCP=1
PREROUTING_UDP=1
POSTROUTING_TCP=1
POSTROUTING_UDP=1

#---INITIALIZATION---

#Disable other firewalls
if [ $DISABLE_FIREWALLS = TRUE ] ; then
    sudo ufw disable 2> /dev/null
    sudo systemctl disable firewalld 2> /dev/null
    sudo systemctl stop firewalld 2> /dev/null
fi
if [ $PRE_FLUSHALL = TRUE ] ; then
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P PREROUTING ACCEPT
    sudo iptables -P POSTROUTING ACCEPT
    if [ $BASIC_FLUSH = FALSE ] ; then
        sudo iptables -Z
        sudo iptables -F
        sudo iptables -X
    else
        sudo iptables -F
    fi
fi
if [ $PRE_DROPALL = TRUE ] ; then
    sudo iptables -P INPUT DROP
    sudo iptables -P OUTPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P PREROUTING DROP
    sudo iptables -P POSTROUTING DROP
    sleep 1
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P PREROUTING ACCEPT
    sudo iptables -P POSTROUTING ACCEPT
fi

#---INITIALIZE RULES---

#Rules: allow tcp ports, allow udp ports, allow established, drop all others

#---SAFE MODE---
if [ $SAFE_MODE = TRUE ] ; then
    #Input rules
    if [ $INPUT_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -P INPUT ACCEPT && sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A INPUT -p tcp -m tcp -m multiport ! --dports $INPUT_TCP -j DROP && sudo iptables -A INPUT -p udp -m udp -m multiport ! --dports $INPUT_UDP -j DROP
    fi

    #The rest of these rules are untested, but should work

    #Output rules
    if [ $OUTPUT_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -P OUTPUT ACCEPT && sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A OUTPUT -p tcp -m tcp -m multiport ! --dports $OUTPUT_TCP -j DROP && sudo iptables -A OUTPUT -p udp -m udp -m multiport ! --dports $OUTPUT_UDP -j DROP    fi
    fi

    #Forward rules
    if [ $FORWARD_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -P FORWARD ACCEPT && sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A FORWARD -p tcp -m tcp -m multiport ! --dports $FORWARD_TCP -j DROP && sudo iptables -A FORWARD -p udp -m udp -m multiport ! --dports $FORWARD_UDP -j DROP    fi
    fi

    #Prerouting rules
    if [ $PREROUTING_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -P PREROUTING ACCEPT && sudo iptables -A PREROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A PREROUTING -p tcp -m tcp -m multiport ! --dports $PREROUTING_TCP -j DROP && sudo iptables -A PREROUTING -p udp -m udp -m multiport ! --dports $PREROUTING_UDP -j DROP    fi
    fi

    #Postrouting rules
    if [ $POSTROUTING_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -P POSTROUTING ACCEPT && sudo iptables -A POSTROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A POSTROUTING -p tcp -m tcp -m multiport ! --dports $POSTROUTING_TCP -j DROP && sudo iptables -A POSTROUTING -p udp -m udp -m multiport ! --dports $POSTROUTING_UDP -j DROP    fi
    fi

elif [ $SAFE_MODE = FALSE] ; then
    #---IRON WALL RULES---

    #CAUTION: THIS WILL COMPLETELY DISABLE ALL CONNECTIVITY IF THE IPTABLES RULES GET MESSED WITH!
    #ENABLE SAFE MODE INSTEAD FOR CLOUD DEVICES
    
    #Input rules
    if [ $INPUT_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -A INPUT -p tcp -m tcp -m multiport --dports $INPUT_TCP -j ACCEPT && sudo iptables -A INPUT -p udp -m udp -m multiport --dports $INPUT_UDP -j ACCEPT && sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT && sudo iptables -P INPUT DROP
    fi

    #The rest of these rules are untested, but should work

    #Output rules
    if [ $OUTPUT_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -A OUTPUT -p tcp -m tcp -m multiport --dports $OUTPUT_TCP -j ACCEPT && sudo iptables -A OUTPUT -p udp -m udp -m multiport --dports $OUTPUT_UDP -j ACCEPT && sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT && sudo iptables -P OUTPUT DROP
    fi

    #Forward rules
    if [ $FORWARD_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -A FORWARD -p tcp -m tcp -m multiport --dports $FORWARD_TCP -j ACCEPT && sudo iptables -A FORWARD -p udp -m udp -m multiport --dports $FORWARD_UDP -j ACCEPT && sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT && sudo iptables -P FORWARD DROP
    fi

    #Prerouting rules
    if [ $PREROUTING_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -A PREROUTING -p tcp -m tcp -m multiport --dports $PREROUTING_TCP -j ACCEPT && sudo iptables -A PREROUTING -p udp -m udp -m multiport --dports $PREROUTING_UDP -j ACCEPT && sudo iptables -A PREROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A PREROUTING -p icmp --icmp-type echo-request -j ACCEPT && sudo iptables -P PREROUTING DROP
    fi

    #Postrouting rules
    if [ $POSTROUTING_RULES = TRUE ] ; then
        sudo iptables -F && sudo iptables -A POSTROUTING -p tcp -m tcp -m multiport --dports $POSTROUTING_TCP -j ACCEPT && sudo iptables -A POSTROUTING -p udp -m udp -m multiport --dports $POSTROUTING_UDP -j ACCEPT && sudo iptables -A POSTROUTING -m state --state ESTABLISHED,RELATED -j ACCEPT && sudo iptables -A POSTROUTING -p icmp --icmp-type echo-request -j ACCEPT && sudo iptables -P POSTROUTING DROP
    fi

else
    echo "Safe mode is not enabled/disabled correctly. Flushing all rules and exiting..."
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P PREROUTING ACCEPT
    sudo iptables -P POSTROUTING ACCEPT
    if [ $BASIC_FLUSH = FALSE ] ; then
        sudo iptables -Z
        sudo iptables -F
        sudo iptables -X
    else
        sudo iptables -F
    fi
fi

