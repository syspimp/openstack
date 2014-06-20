#!/bin/bash
. /root/keystonerc_user 

if [ ! $1 ] ;
then
	echo
	echo "$0 -u <uuid> or -n <name>"
	echo "pass the uuid or name to boot"
	read -p "hit enter to run 'nova list' for names/uuids"
	. /root/keystonerc_user 
	nova list
fi
do_uuid () {
	echo "reseting state on $1..."
	UUID=$1
	#VALUE=$(nova list|grep "$UUID"|awk '{print $2}')
	for uuid in $UUID
	do
	  . /root/keystonerc_admin
	  nova reset-state $uuid
	  sleep 1
	  nova reset-state --active $uuid
	  . /root/keystonerc_user 
	  sleep 1
	done
}
do_name () {
	echo "reseting state on ${*}..."
	NAME="$*"
	UUID=$(nova list|grep "$NAME"|awk '{print $2}')
	CHECK=$(nova list|grep "$NAME"|awk '{print $6}')
	if [ "$CHECK" == "ACTIVE" ]
	then
		echo "skipping already active $uuid"
		return
	fi
	for uuid in $UUID
	do
	  echo "fixing $uuid..."
	  . /root/keystonerc_admin
	  nova reset-state $uuid
	  sleep 2
	  nova reset-state --active $uuid
	  . /root/keystonerc_user 
	  sleep 2
	done
}
main()
{
	while getopts "dn:u:" OPTION
	do
		case "$OPTION" in
		# debug
		d) set -x
		;;
		u) do_uuid $OPTARG
		;;
		n) do_name "$OPTARG"
		;;
		esac	
	done
}


main "$@"
exit 0
