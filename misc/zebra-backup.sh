#!/bin/bash
#Purpose = Backup of Zebra Index
#Run daily
SERVICE=koha-index-daemon;
backupdir=$(sed -n 's/[ \t]<backupdir>\(.*\)<\/backupdir>/\1/p' $KOHA_CONF)
zebradir=$(sed -n '0,/<directory>/s/[ \t]<directory>\(.*\)\/biblios<\/directory>/\1/p' $KOHA_CONF)

if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    sudo service $SERVICE stop
    echo "Stopping $SERVICE"
fi

sleep 15

if [ ! -d $backupdir/backup ]; then
  echo "Creating backup $backupdir/backup"
  mkdir $backupdir/backup
fi

if ! ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    find $backupdir/backup/*.tar.gz -mtime +2 -exec rm {} \;
    TIME=`date +%d-%b-%y`
    FILENAME=zebra-backup-$TIME.tar.gz
    SRCDIR=$zebradir
    DESDIR=$backupdir/backup
    tar -cpzf $DESDIR/$FILENAME $SRCDIR
    if ! ps ax | grep -v grep | grep $SERVICE > /dev/null
    then
        echo "Starting $SERVICE"
        sudo service $SERVICE start
    fi
fi