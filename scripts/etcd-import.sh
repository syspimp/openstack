#!/bin/bash
## import files into etcd
set -x
etcd_svr='10.152.230.239'
rootpath='v2/keys/yourcompany/etc'
dirpath='/yourcompany/etc/'
filter="grep profile"

## find every file in the directory
pushd $dirpath
find . -print |xargs file|grep ASCII|cut -d: -f1| while IFS= read -r -d '' file
do 
	old_IFS=$IFS
	IFS=$'\n'
	lines=($(cat FILE | grep -v '^$' | grep -v '^#' ) ) # array
	IFS=$old_IFS
	KEY=0
	while [ $KEY -lt ${line[#]} ]
	do
	  curl -XPUT http://${etcd_svr}/${rootpath}/${file}/${key} -d value="${line[$KEY]}"
	  KEY=$(( KEY + 1 ))
	  sleep 1
	done
done
popd
