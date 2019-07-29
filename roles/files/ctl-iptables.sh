#!/bin/bash
#-------------------------------------------------------------------------------------------
#Author.name: Jack Liu
#Author.email: jac.liu@redhat.com
#Date: 2019-05-06
#Version: 1.0

#usage: ctl-iptables.sh [OPTIONS]
#[OPTIONS]
#   -showport
#   -addport [portocol] [port]
#   -delport [portocol] [port]
#   -help

#-------------------------------------------------------------------------------------------


action=`echo $1 | awk -F'-' '{print $2}'`
protocol=$2
port=$3
lastINPUT='REJECT     all  --  anywhere             anywhere             reject-with'

#Verify Positional Arguments - Begin -----------------------------------

if [ $# -lt 1 ]
then
   echo -n `date '+%Y-%m-%d %H:%M:%S'` - 'Please enter required action item: [showport|addport|delport|help]? '
   read action
fi

if [ $# -lt 2 ] && [ "$action" == addport -o "$action" == delport ]
then
   echo -n `date '+%Y-%m-%d %H:%M:%S'` - 'Please enter required protocol: [ex:tcp|udp|...]? '
   read protocol
fi

if [ $# -lt 3 ] && [ "$action" == addport -o "$action" == delport ]
then
   echo -n `date '+%Y-%m-%d %H:%M:%S'` - 'Please enter required port: '
   read port
fi
#Verify Positional Arguments - End -------------------------------------




#Function Begin###

#Print current iptables - Begin ----------------------------------------

function showTables {
    echo ">>>"
    iptables -L INPUT -n
}

#Print current iptables - End ------------------------------------------



#Add allow port on iptables - Begin ------------------------------------

function addPort {
    index=`iptables -L INPUT --line-num | grep "$lastINPUT" | awk '{print $1}' | head -n1`

    if [ "$port" == "" ]
    then
      iptables -I INPUT $index -p $protocol -j ACCEPT
      echo "---"
      echo "CMD: iptables -I INPUT $index -p $protocol -j ACCEPT"
    else
      iptables -I INPUT $index -p $protocol --dport $port -j ACCEPT
      echo "---"
      echo "CMD: iptables -I INPUT $index -p $protocol --dport $port -j ACCEPT"
    fi
}

#Add allow port on iptables - End --------------------------------------



#Delete allow port on iptables - Begin ---------------------------------

function delPort {
    if [ "$port" == "" ]
    then
      iptables -D INPUT -p $protocol -j ACCEPT
      echo "---"
      echo "CMD: iptables -D INPUT -p $protocol -j ACCEPT"
    else
      iptables -D INPUT -p $protocol --dport $port -j ACCEPT
      echo "---"
      echo "CMD: iptables -D INPUT -p $protocol --dport $port -j ACCEPT"
    fi
}
#Delete allow port on iptables - End -----------------------------------



#Print command usage - Begin -------------------------------------------

function printUsage {
    echo "usage: ctl-iptables.sh [OPTIONS]"
    echo "[OPTIONS]"
    echo "   -showport"
    echo "   -addport [portocol] [port]"
    echo "   -delport [portocol] [port]"
    echo "   -help"
}

#Print command usage - End ---------------------------------------------



#Saving Iptables Firewall Rules Permanently - Begin --------------------

function saveIptables {
    iptables-save > /etc/sysconfig/iptables
}

#Saving Iptables Firewall Rules Permanently - End ----------------------

#Function END###

case $action in
  showport)
    showTables
    exit 0
    ;;
  addport)
    addPort
    showTables
    saveIptables
    exit 0
    ;;
  delport)
    delPort
    showTables
    saveIptables
    exit 0
    ;;
  help)
    printUsage
    exit 0
    ;;
  *)
    echo 'ERROR: Item Unmatched'
    printUsage
    exit 1
    ;;
esac