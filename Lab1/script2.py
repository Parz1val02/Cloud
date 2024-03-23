import paramiko
import subprocess


def connection(host, username, password, cmd1, cmd2):
    client = paramiko.client.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(host, username=username, password=password)
    _stdin, _stdout, _stderr = client.exec_command(cmd1)
    hostname = _stdout.read().decode()
    _stdin, _stdout, _stderr = client.exec_command(cmd2)
    ifaces = _stdout.read().decode()
    client.close()
    return hostname, ifaces


if __name__ == "__main__":

    username = "ubuntu"
    password = "ubuntu"
    cmd = "echo -n $(hostname)"
    cmd2 = 'ip -br addr | grep -v lo | cut -d " " -f 1 | awk \'{print NR " -> " $0}\''
    ips = ["30", "40", "50"]

    # HeadNode info
    returned_output = subprocess.check_output(cmd, shell=True)
    hostnameH = returned_output.decode("utf-8")
    returned_output2 = subprocess.check_output(cmd2, shell=True)
    ifacesH = returned_output2.decode("utf-8")
    salidaH = hostnameH + " -> ("
    for line in ifacesH.splitlines():
        salidaH += line + " / "
    salidaH += ")"
    print(salidaH)

    # Workers info
    for i in ips:
        host = f"10.0.0.{i}"
        hostnameW, ifacesW = connection(host, username, password, cmd, cmd2)
        salidaW = hostnameW + " -> ("
        for line in ifacesW.splitlines():
            salidaW += line + " / "
        salidaW += ")"
        print(salidaW)
