#!/bin/sh
# Script to create daily backups of the Koha database.
# Based on a script by John Pennington
BACKUPDIR=`xmlstarlet sel -t -v 'yazgfs/config/backupdir' $KOHA_CONF`
KOHA_DATE=`date '+%y%m%d'`
KOHA_BACKUP=$BACKUPDIR/koha-$KOHA_DATE.sql.gz

mysqldump --single-transaction -u koha -ppassword koha | gzip -9 > $KOHA_BACKUP

#mv $KOHA_BACKUP /home/kohaadmin &&
#chown kohaadmin.users /home/kohaadmin/koha-$KOHA_DATE.dump.gz &&
#chmod 600 /home/kohaadmin/koha-$KOHA_DATE.dump.gz &&
# Makes the compressed dump file property of the kohaadmin user.
# Make sure that you replace kohaadmin with a real user.

[ -f $KOHA_BACKUP] && echo "$KOHA_BACKUP was successfully created." | mail kohaadmin -s $KOHA_BACKUP ||
echo "$KOHA_BACKUP was NOT successfully created." | mail kohaadmin -s $KOHA_BACKUP
# Notifies kohaadmin of (un)successful backup creation
# EOF
