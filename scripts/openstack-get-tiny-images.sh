source /root/keystonerc_admin
source /root/novarc
mkdir -p /root/images
pushd /root/images
curl -L http://github.com/downloads/citrix-openstack/warehouse/tty.tgz | tar xvfzo -
glance add name=aki-tty disk_format=aki container_format=aki is_public=true < aki-tty/image
glance add name=ami-tty disk_format=ami container_format=ami is_public=true < ami-tty/image
glance add name=ari-tty disk_format=ari container_format=ari is_public=true < ari-tty/image
popd