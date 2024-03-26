import paramiko


def connection(host, username, password):
    byte_dict = dict()
    cmd1 = "echo -n $(hostname)"
    cmd2 = "ip -br addr | grep -v lo | cut -d \" \" -f 1 | awk '{print $0}'"
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=password)
    _stdin, _stdout, _stderr = client.exec_command(cmd1)
    hostname = _stdout.read().decode()
    _stdin, _stdout, _stderr = client.exec_command(cmd2)
    ifaces = _stdout.read().decode()
    for iface in ifaces.splitlines():
        cmd3 = "echo -n $(ip -s link show " + iface + " | tail -n 1 | awk '{print $1}')"
        _stdin, _stdout, _stderr = client.exec_command(cmd3)
        bytes_tx = _stdout.read().decode()
        byte_dict[iface] = bytes_tx
    return hostname, byte_dict

    client.close()


if __name__ == "__main__":

    username = "ubuntu"
    password = "ubuntu"
    ips = ["30", "40", "50"]
    info = ""

    # Workers info
    for i in ips:
        host = f"10.0.0.{i}"
        hostname, byte_dict = connection(host, username, password)
        byte_keys = byte_dict.keys()
        for j in byte_keys:
            info += "\n| " + hostname + " | " + j + " | " + byte_dict[j]
    print(info)
