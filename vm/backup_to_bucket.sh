#!/usr/bin/env bash
set -e


TIMESTAMP=$(date +%F-%H%M)
DUMP_DIR=/tmp/mongodump-$TIMESTAMP
mkdir -p $DUMP_DIR


# Dump the DB (requires mongodump installed — included in mongodb-org package)
mongodump --username taskyuser --password taskypass --authenticationDatabase admin --db tasky --out $DUMP_DIR


# Tar the dump
tar czf /tmp/tasky-backup-$TIMESTAMP.tgz -C $DUMP_DIR .


# Upload to S3 (bucket intentionally public)
aws s3 cp /tmp/tasky-backup-$TIMESTAMP.tgz s3://<PUBLIC_BUCKET_NAME>/backups/tasky-backup-$TIMESTAMP.tgz --acl public-read


# Cleanup
rm -rf $DUMP_DIR /tmp/tasky-backup-$TIMESTAMP.tgz
