#!/bin/bash
# this will build a fed18 vm for you
ISO=/mnt/software/ISO/Fedora-18-x86_64-netinst.iso
#DRIVERS=/mnt/iso/virtio-win-0.1-49.iso
TAG=$$
TMPIMG=/var/lib/libvirt/images/fed18-64bit.img.${TAG}
RED='\e[0;31m'
ENDCOLOR="\e[0m";

msg()
{
    echo -e "${RED}**${ENDCOLOR} $*"
}

msg creating raw image for fed18 install
qemu-img create -f raw $TMPIMG 20G
msg starting instance, please use vnc to connect to $(hostname):5908, finish install then shutdown
/usr/libexec/qemu-kvm -m 2048 -cdrom ${ISO} -drive file=${TMPIMG} -boot d -net nic -net user -nographic -vnc 0.0.0.0:8
msg ready to import into glance
read -p "Ill wait.  Ctrl -C to stop script, type y to continue." ANSWER
case $ANSWER in
	[yY])	msg Adding image to glance ...
		glance image-create --name="Fedora18-64bit" --is-public=true --container-format=ovf --disk-format=raw < $TMPIMG
		msg Image is located ${TMPIMG}, remove when ready
	;;
	[nN])	msg Deleting image ...
		rm -f $TMPIMG
	;;
esac
exit 0
