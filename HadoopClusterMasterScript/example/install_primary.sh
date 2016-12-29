#!/bin/sh
setenforce 0
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
yum -y install ambari-server
ambari-server setup -s --java-home=/usr/lib/jvm/jre/
ambari-server start
sh /vagrant/install_client.sh
