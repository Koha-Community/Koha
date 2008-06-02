#!/bin/sh
# Script to create daily backups of the Koha database.
# Based on a script by John Pennington
KOHA_DATE=`date '+%y%m%d'`
KOHA_DUMP=/tmp/koha-$KOHA_DATE.dump
KOHA_BACKUP=/tmp/koha-$KOHA_DATE.dump.gz

mysqldump --single-transaction -u koha -ppassword koha > $KOHA_DUMP &&
gzip -f $KOHA_DUMP &&
# Creates the dump file and compresses it;
# -u is the Koha user, -p is the password for that user.
# The -f switch on gzip forces it to overwrite the file if one exists.

mv $KOHA_BACKUP /home/kohaadmin &&
chown kohaadmin.users /home/kohaadmin/koha-$KOHA_DATE.dump.gz &&
chmod 600 /home/kohaadmin/koha-$KOHA_DATE.dump.gz &&
# Makes the compressed dump file property of the kohaadmin user.
# Make sure that you replace kohaadmin with a real user.

echo "$KOHA_BACKUP was successfully created." | mail kohaadmin -s $KOHA_BACKUP ||
echo "$KOHA_BACKUP was NOT successfully created." | mail kohaadmin -s $KOHA_BACKUP
# Notifies kohaadmin of (un)successful backup creation
# EOF
