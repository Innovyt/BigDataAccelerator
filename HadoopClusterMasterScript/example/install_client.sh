#!/bin/sh
setenforce 0
wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo
yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel
yum -y install ambari-agent
echo '192.168.2.51 server1.innovyt.com' >> /etc/hosts
echo '192.168.2.52 server2.innovyt.com' >> /etc/hosts
echo '192.168.2.53 server3.innovyt.com' >> /etc/hosts
cat /etc/ambari-agent/conf/ambari-agent.ini |sed 's/localhost/server1.innovyt.com/g' > /etc/ambari-agent/conf/ambari-agent.ini.new
mv -f /etc/ambari-agent/conf/ambari-agent.ini.new /etc/ambari-agent/conf/ambari-agent.ini
ambari-agent start
ln -s /usr/bin/jps /usr/lib/jvm/jre//bin/jps
ln -s /usr/bin/jar /usr/lib/jvm/jre/bin/jar
yum -y install ntp
systemctl enable ntpd
service ntpd start
yum install -y deltarpm
DOWNIF=`ip addr |grep DOWN |cut -d ' ' -f2 |cut -d ':' -f1` 
DOWNIFCHECK=`ip addr |grep DOWN |cut -d ' ' -f2 |cut -d ':' -f1 |wc -l` 
if [ $DOWNIFCHECK == 1 ] ; then
  ifdown $DOWNIF
  ifup $DOWNIF
fi
