# install ovs rhel specific scripts
# useful when you build from source

cd rhel
cp etc_init.d_openvswitch                   /etc/init.d/openvswitch
cp etc_logrotate.d_openvswitch                  /etc/init.d/openvswitch
cp etc_sysconfig_network-scripts_ifdown-ovs             /etc/sysconfig/network-scripts/ifdown-ovs
cp etc_sysconfig_network-scripts_ifup-ovs           /etc/sysconfig/network-scripts/ifup-ovs
cp usr_lib_systemd_system_openvswitch-nonetwork.service     /usr/lib/systemd/system/openvswitch-nonetwork.service
cp usr_lib_systemd_system_openvswitch.service           /usr/lib/systemd/system/openvswitch.service
cp usr_lib_systemd_system_ovn-controller-vtep.service       /usr/lib/systemd/system/ovn-controller-vtep.service
cp usr_lib_systemd_system_ovn-controller.service        /usr/lib/systemd/system/ovn-controller.service
cp usr_lib_systemd_system_ovn-northd.service            /usr/lib/systemd/system/ovn-northd.service
cp usr_share_openvswitch_scripts_sysconfig.template         /usr/share/openvswitch/scripts/sysconfig.template
mkdir /usr/share/openvswitch/scripts/systemd
cp usr_share_openvswitch_scripts_systemd_sysconfig.template     /usr/share/openvswitch/scripts/systemd/sysconfig.template
