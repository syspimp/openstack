#!/bin/bash
# this will return to Active status all my favorite VM's after a power outage or something

VMS_TO_FIX="Admin chef-server chef-client Public NAS Casino PBS Active Jump"

source /root/keystonerc_user
pushd /root/
for vm in ${VMS_TO_FIX}
do
  ./reset-vm-state.sh -n $vm
  sleep 2
done
popd
