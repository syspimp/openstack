#!/bin/bash
systemctl restart rpcbind.service
systemctl restart nfs-server.service
systemctl restart nfs-lock.service
systemctl restart nfs-idmap.service

exit 0
