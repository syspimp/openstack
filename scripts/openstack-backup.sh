#!/bin/bash
set -x
bckdirs="/etc /var/lib/glance /var/lib/nova /var/lib/keystone /var/lib/cinder"
dbdirs="/var/lib/mongodb"
exclude='--exclude=*nova/instances* --exclude=*glance/images*'
hostname=$(hostname)
date=$(date +%Y%m%d)
base_dir="/shelf/backups/${hostname}/"
backup_dir="/shelf/backups/${hostname}/${date}"

mkdir -p ${backup_dir} > /dev/null 2>&1

# Dump the entire MySQL database
mysqlfilename="${backup_dir}/mysql-${hostname}-${date}.sql.gz"
/usr/bin/mysqldump --opt --all-databases | gzip > $mysqlfilename

# Tar the dirs
tarfilename="${backup_dir}/files-${date}.tgz"
dbtarfilename="${backup_dir}/mongodb-${date}.tgz"
tar zcf ${tarfilename} ${exclude} ${bckdirs}
tar zcf ${dbtarfilename} ${dbdirs}

# make list of installed rpms
rpmlistname="${backup_dir}/rpmlist-${date}.txt"
rpm -qa > ${rpmlistname}

# Delete backups older than 7 days
find $base_dir -ctime +7 -type d -print0 | xargs -0 /bin/rm -rf

# sync to s3
s3cmd sync /shelf/backups/$(hostname) s3://tfound-storage/shelf/backups/
#s3cmd sync /shelf/drobo/users s3://tfound-storage/shelf/
#s3cmd sync /shelf/drobo/software s3://tfound-storage/shelf/
