# BigDataAccelerator
Accelerators for Big data

1. Hadoop Cluster Script

Hadoop cluster script is a shell file which automates the creation of a hadoop cluster based on the CentOS distribution. 

The master script ask the users for the number of nodes that they want to configure in the cluster and the resources that are assigned to each node. The script then generates a Vagrant file and the required scripts to initialize the nodes with Ambari. These Vagrant files and scripts which can be used to create the cluster. 

The following examples shows the output of the sample run of the script for a 3 node cluster

Enter number of servers > 
3
 
Domain is set to: innovyt.com
############################### 
Please enter details for server: 1
 
Enter network IP > 
192.168.2.51

Enter memory(MB) > 
1000

Enter number of CPUs > 
1
############################### 
Please enter details for server: 2
 
Enter network IP > 
192.168.2.52

Enter memory(MB) > 
1000

Enter number of CPUs > 
1
############################### 
Please enter details for server: 3
 
Enter network IP > 
192.168.2.53

Enter memory(MB) > 
1000

Enter number of CPUs > 
1

Scripts are generated... Please run 'vagrant up server3 server2 server1 ' to start the cluster.

There is a example folder which holds the files generated for the above sample script. 
