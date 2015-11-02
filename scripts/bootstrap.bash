#!/bin/bash -eux

sudo cp /tmp/docker.repo /etc/yum.repos.d/docker.repo
sudo chown root:root /etc/yum.repos.d/docker.repo
sudo chmod 0644 /etc/yum.repos.d/docker.repo

sudo yum -y install deltarpm
sudo yum -y install epel-release
sudo yum -y update
sudo yum -y install gcc python-devel python-pip docker-engine
sudo yes | pip install --upgrade pip
sudo yes | pip install ansible==1.9.2

sudo usermod -aG docker vagrant

sudo systemctl enable docker
sudo systemctl start docker

sudo yum -y clean all
sudo rm -f \
  /var/log/messages\
  /var/log/lastlog\
  /var/log/auth.log\
  /var/log/syslog\
  /var/log/daemon.log\
  /var/log/docker.log\
  /home/vagrant/.bash_history\
  /var/mail/vagrant\
  || true

sudo systemctl stop firewalld
sudo systemctl disable firewalld