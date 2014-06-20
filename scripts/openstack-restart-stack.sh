#!/bin/bash
# old restart script for Folsom release, can be reused

doit()
{
	for i in cert xvpvncproxy volume scheduler objectstore novncproxy console consoleauth network compute ;
	do 
		/etc/init.d/openstack-nova-${i} $1 ; 
		if [ "$1" == "stop" ] ;
		then
			chkconfig openstack-nova-${i} off
		elif [ "$1" == "start" ]
		then
			chkconfig openstack-nova-${i} on
		else
			echo "not changing chkconfig"
		fi	
	done
}


while getopts "rsx" OPTION
do
    case "$OPTION" in
    # debug
    s) doit stop
    ;;
    x) doit start
    ;;
    r) doit stop ; sleep 3 ; doit start
    ;;
    esac
done
