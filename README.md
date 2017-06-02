openstack
=========

Configurations and scripts related to openstack
scripts/rabbit_monitor is a python based app that listens to the openstack queue and sends jobs to a worker. I used it to contral a Proteus DNS applicance. Whenever a server was booted, it was create the CNAME and point to a static A record that contained the environment and the IP address, for example: You create Openstack VM "My New VM", and when it is created, a notification goes out on the rabbit queue nova.notifications. The monitor.py process will grab the hostname and pass it to the worker with a request to create a dns cname for host 'my-new-vm' with IP 1.2.3.4.  The worker is hardcoded with environment 'dev' and would make a CNAME of 'my-new-vm.cld.yourcompany.com' pointing to A record dev1.2.3.4.yourcompany.com'. You will have to create the A records before hand. There is a script with a for loop that populates the Proteus device in this case. 
