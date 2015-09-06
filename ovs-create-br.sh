#!/bin/bash

DEBUG=0

if [ $# -lt 2 ]; then
  echo "$0 <interface name> <bridge name> <options>"
  exit 1
fi

iface=$1
br=$2
shift; shift

# getopts
while [[ $# > 1 ]]
  do
  key="$1"

  case $key in
      -i|--ip)
        ip="$2"
        shift
      ;;
      -g|--gateway)
        gw="$2"
        shift
      ;;
      -n|--netmask)
        nm="$2"
        shift
      ;;
      *)
        # unknown option
        echo "unknow option $1"
        echo "usage:"
        echo "$0 <interface name> <bridge name> <Options>"
        echo "Options: -i/--ip <ip> -g/--gateway <gateway> -n/--netmask <netmask>"
        exit 1
      ;;
  esac
  shift
done

# backup ifcfg-<iface>
ifcfg_dir=/etc/sysconfig/network-scripts
if [ $DEBUG -eq 0 ]; then
  cp $ifcfg_dir/ifcfg-$iface $ifcfg_dir/ifcfg-${iface}.bak 2>/dev/null
fi

# create new ovs ifcfg
ifcfg_ctnt="\
DEVICE=$iface    \n\
TYPE=OVSPort     \n\
DEVICETYPE=ovs   \n\
ONBOOT=yes       \n\
BOOTPROTO=none   \n\
OVS_BRIDGE=ovsbr \n\
HOTPLUG=no"

# keep bonding options for bond device
bonding_opts=`grep '^BONDING_OPTS' $ifcfg_dir/ifcfg-${iface}`
ifcfg_ctnt="$ifcfg_ctnt \n $bonding_opts"

if [ $DEBUG -eq 0 ]; then
  echo -e $ifcfg_ctnt > $ifcfg_dir/ifcfg-$iface
else
  echo -e "new ifcfg-$iface: \n $ifcfg_ctnt"
fi

# create bridge ifcfg
bridge_ifcfg_ctnt="
DEVICE=$br        \n\
TYPE=OVSBridge    \n\
DEVICETYPE=ovs    \n\
ONBOOT=yes        \n\
BOOTPROTO=static  \n\
IPADDR=$ip        \n\
NETMASK=$nm       \n\
GATEWAY=$gw       \n\
HOTPLUG=no"

# backup possible existing bridge ifcfg and create the new one
if [ $DEBUG -eq 0 ]; then
  mv $ifcfg_dir/ifcfg-$br $ifcfg_dir/ifcfg-${br}.bak 2>/dev/null
  echo -e $bridge_ifcfg_ctnt > $ifcfg_dir/ifcfg-$br
else
  echo
  echo "ifcfg-#{br}:"
  echo -e $bridge_ifcfg_ctnt
fi

ovs-vsctl add-br $br
ovs-vsctl add-port $br $iface
