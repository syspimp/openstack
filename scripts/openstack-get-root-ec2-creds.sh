source /root/keystonerc_admin
USER_ID=$(keystone user-list | awk '/admin / {print $2}')
ACCESS_KEY=$(keystone ec2-credentials-list --user-id $USER_ID | awk '/admin / {print $4}')
SECRET_KEY=$(keystone ec2-credentials-list --user-id $USER_ID | awk '/admin/ {print $6}')
cat > /root/novarc <<EOF
export EC2_URL=http://localhost:8773/services/Cloud
export EC2_ACCESS_KEY=$ACCESS_KEY
export EC2_SECRET_KEY=$SECRET_KEY
EOF
chmod 600 /root/novarc
source /root/novarc
