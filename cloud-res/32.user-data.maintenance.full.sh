#!/bin/bash

set -Cu
set -Ee
set -o pipefail
shopt -s nullglob

pname=ec2-bootstrap-script
stime=$(date +%Y%m%d%H%M%S%Z)

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1 3>&2
set -vx

MSG() {
    echo "$pname pid:$$ stime:$stime etime:$(date +%Y%m%d%H%M%S%Z) $@"	>&3
}

tmpd=$(mktemp -d -t "$pname.$stime.$$.XXXXXXXX")/
if [ 0 -ne "$?" ] ; then
    MSG "line:$LINENO FATAL can not make temporally directory."
    exit 1
fi

trap 'BEFORE_EXIT' EXIT
BEFORE_EXIT()	{
    rm -rf $tmpd
}

trap 'ERROR_HANDLER' ERR
export EMSG
ERROR_HANDLER()	{
    [ "$EMSG" ] && MSG $EMSG
    exit 1	# trigger BEFORE_EXIT function
}

############################################################################
# Parameters

AUTOUPDATE=false

############################################################################
# Install Packages

apt -y update
# Satisfying even ubuntu older versions.
apt -y install jq awscli ruby2.0 ||
    apt -y install jq awscli ruby

################################################################
# Information Gathering

pushd $tmpd

EMSG="line:$LINENO ERROR while fetching region information."
region=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r ".region")

################################################################
# Setup CloudWatch

EMSG="line:$LINENO ERROR while downloading CloudWatch Agent package."
curl -O https://s3.${region}.amazonaws.com/amazoncloudwatch-agent-${region}/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

EMSG="line:$LINENO ERROR while installing CloudWatch Agent package."
dpkg -i -E ./amazon-cloudwatch-agent.deb

EMSG="line:$LINENO ERROR while configuring CloudWatch Agent."
mkdir -p /usr/share/collectd
touch /usr/share/collectd/types.db

cat	<<'EOF'	> /opt/aws/amazon-cloudwatch-agent/etc/config.json
{ "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          { "file_path": "/var/log/syslog",
            "log_group_name": "syslog",
            "log_stream_name": "{instance_id}" } ] } } },
  "metrics": {
    "append_dimensions": {
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}",
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}" },
    "metrics_collected": {
      "collectd": {
        "metrics_aggregation_interval": 60 },
      "mem": {
        "measurement": [
          "mem_used_percent" ],
        "metrics_collection_interval": 60 },
      "statsd": {
        "metrics_aggregation_interval": 60,
        "metrics_collection_interval": 10,
        "service_address": ":8125" },
      "swap": {
        "measurement": [
          "swap_used_percent" ],
        "metrics_collection_interval": 60 } } } }
EOF

EMSG="line:$LINENO ERROR while starting CloudWatch Agent."
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json -s  

MSG "line:$LINENO INFO CloudWatch Agent instalation completed."

################################################################
# Setup CodeDeploy

EMSG="line:$LINENO ERROR while downloading CodeDeploy installation script."
curl -O https://aws-codedeploy-${region}.s3.amazonaws.com/latest/install
chmod +x ./install

EMSG="line:$LINENO ERROR while installing CodeDeploy."
./install auto

MSG "line:$LINENO INFO CodeDeploy instalation completed."

if ! $AUTOUPDATE; then
    EMSG="line:$LINENO ERROR while disabling Auto update."
    MSG "line:$LINENO INFO Disabling Auto Update"
    sed -i '/@reboot/d' /etc/cron.d/codedeploy-agent-update
    chattr +i /etc/cron.d/codedeploy-agent-update
fi

################################################################
sudo -u ubuntu mkdir -p /home/ubuntu/.ssh
sudo -u ubuntu touch /home/ubuntu/.ssh/authorized_keys

# !TODO! SSH public key must be placed.
tee -a /home/ubuntu/.ssh/authorized_keys	<<EOF	>&3
ecdsa-sha2-nistp521 AAAAPUBLICKKEY== 
EOF

id -G ubuntu	|
    tr ' \t' '\n'	|
    awk 'NR>1'	|
    sort -mnu <(id -g www-data) -	> $tmpd/ubuntu.sgid.lst
usermod -G $(tr '\n' ',' < $tmpd/ubuntu.sgid.lst|sed 's/,$//') ubuntu

################################################################
apt -y	install	\
	mysql-client-core-5.7	\
	nfs-common

# !TODO! EFS endpoint must be placed.
endpoint=fs-c0000000.efs.ap-northeast-1.amazonaws.com

cat	<<EOF	>> /etc/fstab
# server		local_path	fstype	opetions										 dump_flg fsck_flg
$endpoint:/		/mnt		nfs	defaults,_netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport	0 0
# $endpoint:/www		/var/www	nfs	defaults,_netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport	0 0
# $endpoint:/etc.nginx	/etc/nginx	nfs	defaults,_netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport	0 0
EOF

mount /mnt

# [ -d /var/www.orig ] || mv /var/www{,.orig}
# mkdir -p /mnt/www /var/www
# chown www-data:www-data  /mnt/www /var/www

# [ -d /var/nginx.orig ] || mv /etc/nginx{,.orig}
# if [ -d /mnt/etc.nginx ] ; then
#     cp -rp /etc/nginx.orig /mnt/etc.nginx
#     tee /mnt/etc.nginx/sites-available/default	<<EOF	> /dev/null
# server {
# 	listen 80 default_server;
# 	listen [::]:80 default_server;
# 	server_name _;
# 	location / {
# 		return 403;
# 	}
# }
# EOF
# fi
# mkdir -p /etc/nginx

# mount -a

# systemctl restart nginx

################################################################
popd
EMSG="line:$LINENO FATAL while exiting"
shopt -u nullglob
exit 0
