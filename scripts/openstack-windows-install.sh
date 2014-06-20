#!/bin/bash
# this script will build a windows VM for you

ISO=/mnt/iso/bie2k8r2411.iso
DRIVERS=/mnt/iso/virtio-win-0.1-49.iso
TAG=$$
TMPIMG=/var/lib/libvirt/images/windowsserver.img.${TAG}
RED='\e[0;31m'
ENDCOLOR="\e[0m";

msg()
{
    echo -e "${RED}**${ENDCOLOR} $*"
}

msg creating raw image for windows install
qemu-img create -f raw $TMPIMG 20G
msg starting instance, please use vnc to connect to $(hostname):5900, finish install then shutdown
/usr/libexec/qemu-kvm -m 2048 -cdrom ${ISO} -drive file=${TMPIMG},if=virtio -boot d -drive file=${DRIVERS},index=3,media=cdrom -net nic,model=virtio -net user -nographic -vnc :4
msg ready to import into glance
read -p "Ill wait.  Ctrl -C to stop script, type y to continue." ANSWER
case $ANSWER in
	[yY])	msg Adding image to glance ...
		glance image-create --name="Windows ${TAG}" --is-public=true --container-format=ovf --disk-format=raw < $TMPIMG
		msg Image is located ${TMPIMG}, remove when ready
	;;
	[nN])	msg Deleting image ...
		rm -f /var/lib/libvirt/images/windowsserver.img.*
	;;
esac
exit 0
