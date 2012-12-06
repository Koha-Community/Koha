#!/bin/sh
# Script to create daily backups of the Koha database.
# Based on a script by John Pennington

DATABASE=`xmlstarlet sel -t -v 'yazgfs/config/database' $KOHA_CONF`
HOSTNAME=`xmlstarlet sel -t -v 'yazgfs/config/hostname' $KOHA_CONF`
PORT=`xmlstarlet sel -t -v 'yazgfs/config/port' $KOHA_CONF`
USER=`xmlstarlet sel -t -v 'yazgfs/config/user' $KOHA_CONF`
PASS=`xmlstarlet sel -t -v 'yazgfs/config/pass' $KOHA_CONF`
BACKUPDIR=`xmlstarlet sel -t -v 'yazgfs/config/backupdir' $KOHA_CONF`
KOHA_DATE=`date '+%Y%m%d'`
KOHA_BACKUP=$BACKUPDIR/koha-$KOHA_DATE.sql.gz

mysqldump --single-transaction --user=$USER --password="$PASS" --port=$PORT --host=$HOST $DATABASE| gzip -9 > $KOHA_BACKUP

if [ -f $KOHA_BACKUP ] ; then
echo "$KOHA_BACKUP was successfully created." | mail $USER -s $KOHA_BACKUP
else
echo "$KOHA_BACKUP was NOT successfully created." | mail $USER -s $KOHA_BACKUP
fi

# Notifies kohaadmin of (un)successful backup creation
# EOF
