#!/bin/bash

if [ ! $1 ] ;
then
	echo
	echo "$0 -u <uuid> or -n <name> -t <target>"
	echo "pass the uuid or name to migrate, and to what target"
	read -p "hit enter to run 'nova list' for names/uuids"
	. /root/keystonerc_dtaylor 
	nova list
fi
do_uuid () {
	UUID=$1
	if [ -z "$TARGET" ] ;
	then
		echo "need target HOSTNAME to migrate to."
		exit
	fi
	echo "migrating $1 to $TARGET ..."
	#VALUE=$(nova list|grep "$UUID"|awk '{print $2}')
	. /root/keystonerc_admin
	nova live-migration $UUID $TARGET
	if [ $? -ne 0 ]
	then
		echo "Error!! Tailing /var/log/nova/api.log"
		tail -n 10 /var/log/nova/api.log
		echo  
		echo "Resesting vm state..."
		nova reset-state $UUID
		nova reset-state --active $UUID
		echo 
		read -p "Wanna try a regular migration? Let the scheduler decide? [y/N]" answer
		case "$answer" in
		[yY])	echo "Requesting migration ..." ;
			nova migrate $UUID
			;;
		esac
	fi
	. /root/keystonerc_dtaylor 
}
do_name () {
	. /root/keystonerc_dtaylor 
	echo "migrating ${*}..."
	NAME="$*"
	UUID=$(nova list|grep "$NAME"|awk '{print $2}')
	do_uuid $UUID $TARGET
}
main()
{
	while getopts "dt:n:u:" OPTION
	do
		case "$OPTION" in
		# debug
		d) set -x
		;;
		u) DOUUID=$OPTARG
		;;
		n) DONAME="$OPTARG"
		;;
		t) export TARGET="$OPTARG"
		;;
		esac	
	done
	if [ ! -z "$DOUUID" ]
	then
		do_uuid $DOUUID
	elif [ ! -z "$DONAME" ]
	then
		do_name "$DONAME"
	else
		echo "nothing to do."
	fi 
}


main "$@"
exit 0
