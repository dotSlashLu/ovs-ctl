#!/bin/bash
# author: dotslash.lu <dotslash.lu@gmail.com>

rpm_baseurl=''
install_prefix='/usr'

# in some CentOS dist(6.6 included),
# /lib/modules/`uname -r`/build which links to
# /usr/src/kernels/`uname -r` is broken, we need to fix this
# to build kernel module
function fix_kern_link
{
  kern_build_dir=/lib/modules/`uname -r`/build
  ls $kern_build_dir/ 2>&1 >/dev/null || {
    echo fix buggy kernel build symlink
    arr=($(find /usr/src/kernels/ -maxdepth 1 ! -name *.debug))
    target_dir=${arr[1]}
    if [ -d $target_dir ]; then
      rm $kern_build_dir
      ln -s $target_dir $kern_build_dir
    else
      echo no kernel source, please install kernel-devel
      exit 1
    fi
  }
}

function dep
{
  yum install gcc make python-devel openssl-devel kernel-devel graphviz \
   kernel-debug-devel autoconf automake rpm-build redhat-rpm-config \
   libtool
}

function build
{
  mv ovs ovs.bak 2>/dev/null
  git clone https://github.com/openvswitch/ovs.git
  cd ovs
  ./boot.sh
  ./configure --prefix=$install_prefix --with-linux=/lib/modules/`uname -r`/build CFLAGS="-O2"
  make -j`nproc`
  make install
  make modules_install
  modprobe openvswitch
  cp rhel/etc_init.d_openvswitch /etc/init.d/openvswitch
  cp rhel/etc_sysconfig_network-scripts_ifdown-ovs /etc/sysconfig/network-scripts/ifdown-ovs
  cp rhel/etc_sysconfig_network-scripts_ifup-ovs /etc/sysconfig/network-scripts/ifup-ovs
}

function install_rpm
{
  wget $rpm_baseurl/openvswitch-2.4.90-1.x86_64.rpm
  wget $rpm_baseurl/kmod-openvswitch-2.4.90-1.el6.x86_64.rpm
  yum localinstall -y openvswitch-2.4.0-1.x86_64.rpm kmod-openvswitch-2.4.90-1.el6.x86_64.rpm
}

function init
{
  ovsdb-tool create $install_prefix/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
}

function startup
{
  ovsdb-server --remote=punix:$install_prefix/var/run/openvswitch/db.sock \
                 --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                 --private-key=db:Open_vSwitch,SSL,private_key \
                 --certificate=db:Open_vSwitch,SSL,certificate \
                 --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
                 --pidfile --detach
  ovs-vsctl --no-wait init
  ovs-vswitchd --pidfile --detach
}


function install_from_git
{
  dep
  fix_kern_link
  build
  init
}

function install_from_rpm
{
  install_rpm
}

install_from_git
# install_from_rpm
init
startup
