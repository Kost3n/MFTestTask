#!/bin/bash

cd MFTestTask
tar -xf github.tar.xz && cd github

cd
cd ..

apt get update

ip link set eno2 up
cp /home/dhcpserver/MFTestTask/github/HostB/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
netplan apply
systemctl restart networkd-dispatcher.service

apt install isc-dhcp-server -y
systemctl enable isc-dhcp-server
systemctl start isc-dhcp-server

apt install postgresql-client -y

cd /home/dhcpserver/
wget https://github.com/prometheus/prometheus/releases/download/v2.45.3/prometheus-2.45.3.linux-amd64.tar.gz
tar -xzf prometheus*.tar.gz
rm prometheus*.tar.gz
cd prometheus*/
groupadd --system prometheus
useradd -s /sbin/nologin --system -g prometheus prometheus
mv prometheus /usr/local/bin
mv promtool /usr/local/bin
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
mkdir /etc/prometheus
mkdir /var/lib/prometheus
mv consoles /etc/prometheus
mv console_libraries /etc/prometheus
mv prometheus.yml /etc/prometheus
chown prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries
chown -R prometheus:prometheus /var/lib/prometheus

cd /home/dhcpserver/
wget https://mirrors.cloud.tencent.com/grafana/apt/pool/main/g/grafana-enterprise/grafana-enterprise_11.0.0~preview_amd64.deb
apt install adduser libfontconfig1 musl -y
dpkg -i grafana-enterprise_*_amd64.deb

cd
cd ..

cp /home/dhcpserver/MFTestTask/github/HostB/sshd_config /etc/ssh/sshd_config
cp /home/dhcpserver/MFTestTask/github/HostB/authorized_keys /root/.ssh/authorized_keys
cp /home/dhcpserver/MFTestTask/github/HostB/authorized_keys /home/dhcpserver/.ssh/authorized_keys
cp /home/dhcpserver/MFTestTask/github/HostB/isc-dhcp-server /etc/default/isc-dhcp-server
cp /home/dhcpserver/MFTestTask/github/HostB/dhcpd.conf /etc/dhcp/dhcpd.conf
cp /home/dhcpserver/MFTestTask/github/HostB/prometheus.service /etc/systemd/system/prometheus.service
cp /home/dhcpserver/MFTestTask/github/HostB/prometheus.yml /etc/prometheus/prometheus.yml

systemctl restart ssh
ufw allow 9090/tcp
ufw allow 3000/tcp
systemctl restart ufw
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
systemctl enable grafana-server
systemctl start grafana-server
