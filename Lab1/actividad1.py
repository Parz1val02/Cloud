import paramiko
import smtplib
import subprocess
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart


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
    client.close()
    return hostname, byte_dict


def sendEmail(info):
    password = "qumz znxi uqne qyxv"
    sender_email = "rodrigoedu11@gmail.com"
    receiver_email = "r.barrios@pucp.edu.pe"
    message = MIMEMultipart("alternative")
    message["Subject"] = "LAB1_TEL141_2024-1_20202073"
    message["From"] = sender_email
    message["To"] = receiver_email
    cc_recipients = ["jbzambrano@pucp.edu.pe"]
    message["Cc"] = ", ".join(cc_recipients)

    # write the text/plain part
    text = ""
    x = info.splitlines()
    for i in x:
        text += i + "<br>"

    # write the HTML part
    html = f"""\
    <html>
      <body>
        <p><strong>{text}</strong></p>
      </body>
    </html>
    """

    # convert both parts to MIMEText objects and add them to the MIMEMultipart message
    part1 = MIMEText(info, "plain")
    part2 = MIMEText(html, "html")
    message.attach(part1)
    message.attach(part2)

    # send your email
    with smtplib.SMTP("smtp.gmail.com", 587) as server:
        server.starttls()
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message.as_string())


if __name__ == "__main__":
    username = "ubuntu"
    password = "ubuntu"
    ips = ["30", "40", "50"]
    info = "| HOSTNAME DEL EQUIPO REMOTO | INTERFAZ DEL EQUIPO REMOTO | BYTES TRANSFERIDOS |"

    # Workers info
    for i in ips:
        host = f"10.0.0.{i}"
        ping = "ping -c 1 " + host + ' | grep -w "received" | cut -d" " -f4'
        ping_command = subprocess.check_output(ping, shell=True)
        check_ping = ping_command.decode("utf-8")
        if check_ping.strip() == "1":
            hostname, byte_dict = connection(host, username, password)
            byte_keys = byte_dict.keys()
            for j in byte_keys:
                info += (
                    "\n|\t "
                    + hostname
                    + " \t|\t "
                    + j
                    + " \t|\t "
                    + byte_dict[j]
                    + " \t|"
                )
        else:
            print(f"No se pudo entablar conexion con {host}")
    print(info)
    sendEmail(info)
