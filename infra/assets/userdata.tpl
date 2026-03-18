#!/bin/bash
set -euo pipefail

APP_USER="ec2-user"
APP_HOME="/home/$${APP_USER}"
APP_DIR="$${APP_HOME}/app"

if command -v dnf >/dev/null 2>&1; then
  dnf -y update
  dnf -y install docker awscli cronie || true
  dnf -y install docker-compose-plugin || true
elif command -v yum >/dev/null 2>&1; then
  yum -y update
  amazon-linux-extras install -y docker || true
  yum -y install docker awscli cronie || true
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y docker.io docker-compose-plugin awscli cron
fi

systemctl enable --now docker

if systemctl list-unit-files | grep -q '^crond.service'; then
  systemctl enable --now crond
  systemctl restart crond
elif systemctl list-unit-files | grep -q '^cron.service'; then
  systemctl enable --now cron
  systemctl restart cron
fi

if id -u "$${APP_USER}" >/dev/null 2>&1; then
  usermod -aG docker "$${APP_USER}" || true
  mkdir -p "$${APP_DIR}"
  chown -R "$${APP_USER}:$${APP_USER}" "$${APP_HOME}"
fi

cat >/usr/local/bin/backup_mongo_to_s3.sh <<'SCRIPT_EOF'
${backup_script}
SCRIPT_EOF

chmod 750 /usr/local/bin/backup_mongo_to_s3.sh

cat >/etc/cron.d/app-db-backup <<'CRON_EOF'
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
0 3 * * * root /usr/local/bin/backup_mongo_to_s3.sh >> /var/log/app-db-backup.log 2>&1
CRON_EOF

chmod 644 /etc/cron.d/app-db-backup
touch /var/log/app-db-backup.log
