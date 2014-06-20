nodeconfigs="/etc/neutron/neutron.conf /etc/neutron/plugin.ini"
ctrlrconfigs="${nodeconfigs} /etc/neutron/l3_agent.ini /etc/neutron/metadata_agent.ini"
echo "OpenVswitch:"
ovs-vsctl show
for file in $ctrlrconfigs ;
do
  echo "${file}:"
  cat $file | grep -v ^$ | grep -v ^#
done
