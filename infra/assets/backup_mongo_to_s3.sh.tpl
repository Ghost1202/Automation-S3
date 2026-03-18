#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${aws_region}"
S3_BUCKET_NAME="${s3_bucket_name}"
S3_BACKUP_PREFIX="${s3_backup_prefix}"
MONGO_CONTAINER_NAME="${mongo_container_name}"
MONGO_DB_NAME="${mongo_db_name}"

timestamp="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
backup_file="/tmp/$${MONGO_DB_NAME}-$${timestamp}.archive.gz"
s3_key="$${S3_BACKUP_PREFIX}/$${MONGO_DB_NAME}-$${timestamp}.archive.gz"

cleanup() {
  rm -f "$${backup_file}"
}

trap cleanup EXIT

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is not installed"
  exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "aws cli is not installed"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -Fxq "$${MONGO_CONTAINER_NAME}"; then
  echo "mongo container $${MONGO_CONTAINER_NAME} is not running"
  exit 1
fi

if ! docker exec "$${MONGO_CONTAINER_NAME}" sh -c "command -v mongodump >/dev/null 2>&1"; then
  echo "mongodump is not available inside container $${MONGO_CONTAINER_NAME}"
  exit 1
fi

docker exec "$${MONGO_CONTAINER_NAME}" \
  mongodump \
  --archive \
  --gzip \
  --db "$${MONGO_DB_NAME}" \
  > "$${backup_file}"

aws s3 cp "$${backup_file}" "s3://$${S3_BUCKET_NAME}/$${s3_key}" --region "$${AWS_REGION}"

echo "backup uploaded to s3://$${S3_BUCKET_NAME}/$${s3_key}"
