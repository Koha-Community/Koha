#!/bin/sh 
#Purpose = Backup of MongoDB
#Run daily
CONFIG=/home/koha/koha-dev/etc/mongodb-config.xml
HOST=$(sed -n 's/[ \t]<host>\(.*\)<\/host>/\1/p' $CONFIG)
USER=$(sed -n 's/[ \t]<username>\(.*\)<\/username>/\1/p' $CONFIG)
PASS=$(sed -n 's/[ \t]<password>\(.*\)<\/password>/\1/p' $CONFIG)
DATABASE=$(sed -n 's/[ \t]<database>\(.*\)<\/database>/\1/p' $CONFIG)
TIME=`date +%d_%b_%y`
OUT=/home/koha/koha-dev/var/spool/backup/mongodb
BACKUPNAME=mongo_$TIME

if ! [ "$(sudo dpkg-query -l | grep mongodb-org-tools | wc -l)" -eq 1 ]; then
  echo 'Error: mongodb-org-tools is not installed.' >&2
  echo 'Check: https://docs.mongodb.com/getting-started/shell/tutorial/install-mongodb-on-ubuntu/' >&2
  exit 1
fi

echo "Starting backing up"

mongodump --db $DATABASE --out $OUT/$BACKUPNAME --host $HOST --port 27017 -u $USER -p $PASS --authenticationDatabase $DATABASE