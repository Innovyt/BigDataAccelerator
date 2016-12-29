#!/bin/bash

LOC=`pwd`
vfile=Vagrantfile
pfile=install_primary.sh
cfile=install_client.sh
hfile=setup_hosts.tmp
lfile=setup_localhost.tmp
nnum=1 #node number
domain=innovyt.com
all_nodes=''

echo " "
echo  "Enter number of servers > "
read nodes
echo " "
	echo "Vagrant.configure(2) do |config|" > $LOC/$vfile
	echo "  config.ssh.insert_key = false" >> $LOC/$vfile
#echo $((nodes+nodes))
echo "Domain is set to: "$domain
	while [ $((nodes)) -gt 0 ]
	do
echo "############################### "
echo "Please enter details for server: "$nnum
echo " "
echo  "Enter network IP > "
read nip
echo  "Enter memory(MB) > "
read nmem
echo "Enter number of CPUs > "
read ncpu
	echo " config.vm.define \"server$nnum\" do |server$nnum|"				>> $LOC/$vfile
	echo "   server$nnum.vm.box = \"geerlingguy/centos7\""					>> $LOC/$vfile
	echo "   server$nnum.vm.network \"private_network\", ip: \"$nip\" "			>> $LOC/$vfile
	echo "   server$nnum.vm.hostname = \"server$nnum.$domain\" "				>> $LOC/$vfile
if [ $nnum -eq 1 ]; then
	echo "   server$nnum.vm.provision \"shell\", path: \"install_primary.sh\" "	>> $LOC/$vfile
	echo "   server$nnum.vm.network \"forwarded_port\", guest: 8080, host: 8080"		>> $LOC/$vfile
echo "cat /etc/ambari-agent/conf/ambari-agent.ini |sed 's/localhost/server$nnum.$domain/g' > /etc/ambari-agent/conf/ambari-agent.ini.new" > $LOC/$lfile
else
	echo "   server$nnum.vm.provision \"shell\", path: \"install_client.sh\" "	>> $LOC/$vfile
fi
	echo "   server$nnum.vm.provider \"virtualbox\" do |v|"					>> $LOC/$vfile
	echo "      v.memory = $nmem"								>> $LOC/$vfile
	echo "		v.name= \"server$nnum.$domain\""								>> $LOC/$vfile
	echo "		v.cpus= $ncpu"								>> $LOC/$vfile
	echo  " 	v.customize ['modifyvm', :id, '--cableconnected1', 'on']"               >>$LOC/$vfile
	echo "     end"										>> $LOC/$vfile
	echo "   end"										>> $LOC/$vfile

## setup /etc/hosts
echo "echo '$nip server$nnum.$domain' >> /etc/hosts" >> $LOC/$hfile
all_nodes=server$nnum' '$all_nodes	#used by vagrant

	nodes=$((nodes - 1))
	nnum=$((nnum+1))
done
	echo "end"										>> $LOC/$vfile

################# install primary

echo "#!/bin/sh" > $LOC/$pfile
echo "setenforce 0" >> $LOC/$pfile
echo "wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo" >> $LOC/$pfile
echo "yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel" >> $LOC/$pfile
echo "yum -y install ambari-server" >> $LOC/$pfile
echo "ambari-server setup -s --java-home=/usr/lib/jvm/jre/" >> $LOC/$pfile
echo "ambari-server start" >> $LOC/$pfile
echo "sh /vagrant/install_client.sh" >> $LOC/$pfile

###################### install client

echo "#!/bin/sh" > $LOC/$cfile
echo "setenforce 0" >> $LOC/$cfile
echo "wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.2.0.0/ambari.repo -O /etc/yum.repos.d/ambari.repo" >> $LOC/$cfile
echo "yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel" >> $LOC/$cfile
echo "yum -y install ambari-agent" >> $LOC/$cfile

cat $LOC/$hfile >> $LOC/$cfile

## set /etc/hosts
cat $LOC/$lfile >> $LOC/$cfile
echo "mv -f /etc/ambari-agent/conf/ambari-agent.ini.new /etc/ambari-agent/conf/ambari-agent.ini" >> $LOC/$cfile

echo "ambari-agent start" >> $LOC/$cfile

echo "ln -s /usr/bin/jps /usr/lib/jvm/jre//bin/jps" >> $LOC/$cfile

echo "ln -s /usr/bin/jar /usr/lib/jvm/jre/bin/jar" >> $LOC/$cfile

echo "yum -y install ntp" >> $LOC/$cfile
echo "systemctl enable ntpd" >> $LOC/$cfile
echo "service ntpd start" >> $LOC/$cfile

echo "yum install -y deltarpm" >> $LOC/$cfile

# fix DOWN interfaces - bug in centos7 box
echo "DOWNIF=\`ip addr |grep DOWN |cut -d ' ' -f2 |cut -d ':' -f1\` " >> $LOC/$cfile
echo "DOWNIFCHECK=\`ip addr |grep DOWN |cut -d ' ' -f2 |cut -d ':' -f1 |wc -l\` " >> $LOC/$cfile
echo "if [ \$DOWNIFCHECK == 1 ] ; then" >> $LOC/$cfile
echo "  ifdown \$DOWNIF" >> $LOC/$cfile
echo "  ifup \$DOWNIF" >> $LOC/$cfile
echo "fi" >> $LOC/$cfile

############# Download and install VB, Vagrant

echo "Scripts are generated... Please run 'vagrant up $all_nodes' to start the cluster."

