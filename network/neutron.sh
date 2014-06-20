#!/bin/bash
echo "setting up neutron..."
set -x
. /root/keystone_admin
neutron net-create MGMT_VLAN3 --provider:network_type vlan --provider:physical_network inter-vlan --provider:segmentation_id 3 --router:external=True
. keystonerc_user

neutron net-list
neutron subnet-list
neutron subnet-create MGMT_VLAN3 --gateway 192.168.3.5 192.168.3.0/24 --enable_dhcp=False  --allocation-pool start=192.168.3.150,end=192.168.3.200
neutron subnet-list
neutron subnet-delete  2b887a60-72d5-4bce-ab10-240aedfb535a
. keystonerc_user
neutron subnet-create MGMT_VLAN3 --gateway 192.168.3.5 192.168.3.0/24 --enable_dhcp=False  --allocation-pool start=192.168.3.150,end=192.168.3.200
. keystonerc_user
neutron net-create VMS_VLAN4 --provider:network_type vlan --provider:physical_network inter-vlan --provider:segmentation_id 4 --tenant-id=b771d19b71bf4a8ab767b5c18e727b60
neutron subnet-create VMS_VLAN4 192.168.4.0/24 --name "NIC1" --allocation-pool start=192.168.4.100,end=192.168.4.254 --tenant-id=b771d19b71bf4a8ab767b5c18e727b60
neutron net-create OPS_VLAN8 --provider:network_type vlan --provider:physical_network inter-vlan --provider:segmentation_id 8 --tenant-id=b771d19b71bf4a8ab767b5c18e727b60
neutron subnet-create OPS_VLAN8 192.168.8.0/24 --name "NIC2" --allocation-pool start=192.168.8.100,end=192.168.8.254 --tenant-id=b771d19b71bf4a8ab767b5c18e727b60
neutron router-create --tenant-id=b771d19b71bf4a8ab767b5c18e727b60 MASKEDRTR
neutron router-gateway-set MASKEDRTR MGMT_VLAN3
neutron router-interface-add MASKEDRTR NIC1

