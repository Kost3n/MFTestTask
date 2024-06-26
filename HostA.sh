#!/bin/bash

cd MFTestTask

tar -xf github.tar.xz && cd github

cd
cd ..

apt update

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt install docker-ce -y
gpasswd -a $USER docker
apt install docker-compose -y
apt install postgresql-client -y

wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz
tar zxvf node_exporter-1.0.1.linux-amd64.tar.gz && cd node_exporter-1.0.1.linux-amd64
cp node_exporter /usr/local/bin/
useradd --no-create-home --shell /bin/false prometheus
chown -R nodeusr:nodeusr /usr/local/bin/node_exporter

cp /home/dbserver/MFTestTask/github/HostA/00-installer-config.yaml /etc/netplan/00-installer-config.yaml
cp /home/dbserver/MFTestTask/github/HostA/sshd_config /etc/ssh/sshd_config
cp /home/dbserver/MFTestTask/github/HostA/authorized_keys /root/.ssh/authorized_keys
cp /home/dbserver/MFTestTask/github/HostA/authorized_keys /home/dbserver/.ssh/authorized_keys
cp /home/dbserver/MFTestTask/github/HostA/docker-compose.yaml /home/dbserver/docker-compose.yaml
cp /home/dbserver/MFTestTask/github/HostA/node_exporter.service /etc/systemd/system/node_exporter.service
cp /home/dbserver/MFTestTask/github/HostA/docker.service.d /etc/systemd/system/docker.service.d
cp -r /home/dbserver/MFTestTask/github/HostA/data/ /home/dbserver/

ip link set enp2s0f1 up
netplan apply
systemctl restart networkd-dispatcher.service
systemctl restart ssh
systemctl daemon-reload
systemctl start docker
systemctl enable docker
systemctl enable node_exporter
systemctl start node_exporter

cd /home/dbserver/
docker-compose up --build -d
