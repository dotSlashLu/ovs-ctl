#!/bin/bash
# start ovs, normally you can just use `service openvsiwtch start`
# author: dotslash.lu <dotslash.lu@gmail.com>

prefix=/usr

ovsdb-server --remote=punix:$prefix/var/run/openvswitch/db.sock \
                 --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                 --private-key=db:Open_vSwitch,SSL,private_key \
                 --certificate=db:Open_vSwitch,SSL,certificate \
                 --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
                 --pidfile --detach
ovs-vswitchd --pidfile --detach
