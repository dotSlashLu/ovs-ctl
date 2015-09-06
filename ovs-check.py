# test ovs running status
import os.path

def ovs_check():
  prefix = "/usr/var/run/openvswitch"
  db_pid = prefix + "/ovsdb-server.pid"
  daemon_pid = prefix + "/ovs-vswitchd.pid"

  if not os.path.exists(db_pid):
    print("ovsdb not running")
    return False

  if not os.path.exists(daemon_pid):
    print("ovs-vswichd not running")
    return False

  return True

if __name__ == "__main__":
  ovs_check()
