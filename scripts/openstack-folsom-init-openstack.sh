#!/bin/bash

pushd /root/packstack/root/packstack


/root/packstack/root/packstack/bin/packstack --answer-file=/tmp/compute1-ans-file.txt
cp -f /etc/nova/nova.conf /etc/nova/conf.default
cp -f /root/packstack/etc/nova/nova.conf /etc/nova/nova.conf
cp -f /root/packstack/root/get-ec2-creds.sh /root/
cp -f /root/packstack/root/get-initial-images.sh /root/

openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_inject_partition -1
/etc/init.d/openstack-nova-console restart
/etc/init.d/openstack-nova-consoleauth restart
/etc/init.d/openstack-nova-compute restart

echo "make sure you log into the dashboard and download ec2 creds to generate the key"
read -p "press enter to continue"

cd /root/
source /root/keystonerc_admin
source /root/get-ec2-creds.sh
source /root/novarc

nova keypair-add admin-openstack > /root/.ssh/admin-openstack.priv
chmod 600 /root/.ssh/admin-openstack.priv
source /root/get-initial-images.sh
cd /root/
glance add name=f17-jeos is_public=true disk_format=qcow2 container_format=ovf       copy_from=http://berrange.fedorapeople.org/images/2012-11-15/f17-x86_64-openstack-sda.qcow2
mkdir /mnt/iso
mount nas3:/mnt/software/ISO /mnt/iso
yum -y install /usr/bin/oz-install
pushd /var/www/html/
ln -s /iso/CentOS-6.3-x86_64-bin-DVD1.iso
popd
oz-install -d3 -u /root/centos6-64.tdl
echo
echo "you should reboot"
echo
popd