#!/bin/bash 
# I don't remember what this does, remove unused base images?
# might be for Folsom ...
cd /var/lib/nova/instances 
find -name "disk*" | xargs -n1 qemu-img info | grep backing | sed -e 's/.*file: //' -e 's/ .*//' | sort | uniq > /tmp/ignore 
while read i; do 
ARGS="$ARGS \( ! -path $i \) " 
done < /tmp/ignore 
echo find /var/lib/nova/instances/_base/ -type f $ARGS -delete
