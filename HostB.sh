#!/bin/bash

cd MFTestTask
tar -xf github.tar.xz && cd github

cd
cd ..

cp /home/dhcpserver/MFTestTask/github/HostB/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
cp /home/dhcpserver/MFTestTask/github/HostB/sshd_config /etc/ssh/sshd_config
cp /home/dhcpserver/MFTestTask/github/HostB/authorized_keys /root/.ssh/authorized_keys
cp /home/dhcpserver/MFTestTask/github/HostB/authorized_keys /home/dhcpserver/.ssh/authorized_keys
cp /home/dhcpserver/MFTestTask/github/HostB/isc-dhcp-server /etc/default/isc-dhcp-server
cp /home/dhcpserver/MFTestTask/github/HostB/dhcpd.conf /etc/dhcp/dhcpd.conf

apt get update
systemctl restart ssh

apt install isc-dhcp-server -y
ip link set eno2 up
netplan apply
systemctl start isc-dhcp-server
systemctl enable isc-dhcp-server
systemctl restart networkd-dispatcher.service

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

cd
cd ..

cp /home/dhcpserver/MFTestTask/github/HostB/prometheus.service /etc/systemd/system/prometheus.service
cp /home/dhcpserver/MFTestTask/github/HostB/prometheus.yml /etc/prometheus/prometheus.yml

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus
ufw allow 9090/tcp
systemctl restart ufw

cd /home/dhcpserver/
wget https://mirrors.cloud.tencent.com/grafana/apt/pool/main/g/grafana-enterprise/grafana-enterprise_11.0.0~preview_amd64.deb
apt install adduser libfontconfig1 musl -y
dpkg -i grafana-enterprise_*_amd64.deb
systemctl start grafana-server
systemctl enable grafana-server
ufw allow 3000/tcp
systemctl restart ufw
