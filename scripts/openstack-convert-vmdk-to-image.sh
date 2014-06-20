#!/bin/bash
DATASTORE=/var/lib/nova/instances

if [ ! "$1" ]
then
	echo "need file name ( minus .vmdk ) vmdk in ${DATASTORE} to convert. "
	echo "example PBX if exists ${DATASTORE}/PBX.vmdk"
fi

FILE="$1"

pushd ${DATASTORE}
if [ -e "${DATASTORE}/${FILE}-flat.vmdk" ]
then
	echo converting $FILE
	
	if [ ! -e "./${FILE}.qcow2" ]
	then
		qemu-img convert -O qcow2 ./${FILE}-flat.vmdk ./${FILE}.qcow2
	else
		echo "already exists"
	fi
	if [ $? -eq 0 ]
	then
		echo uploading ${FILE} to glance
		glance image-create --name="${FILE}" --is-public=true --container-format=ovf --disk-format=raw <  ./${FILE}.qcow2
		echo Done.
	else
		echo "error occurred while converting"
	fi
fi
popd
