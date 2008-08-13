#!/bin/bash
USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
DBNAME=__DB_NAME__
NAME=koha-zebra-ctl.$DBNAME
LOGDIR=__LOG_DIR__
ERRLOG=$LOGDIR/koha-zebradaemon.err
STDOUT=$LOGDIR/koha-zebradaemon.log
OUTPUT=$LOGDIR/koha-zebradaemon-output.log
KOHA_CONF=__KOHA_CONF_DIR__/koha-conf.xml
RUNDIR=__ZEBRA_RUN_DIR__
LOCKDIR=__ZEBRA_LOCK_DIR__
# you may need to change this depending on where zebrasrv is installed
ZEBRASRV=__PATH_TO_ZEBRA__/zebrasrv
ZEBRAOPTIONS="-v none,fatal,warn"

test -f $ZEBRASRV || exit 0

OTHERUSER=''
if [[ $EUID -eq 0 ]]; then
    OTHERUSER="--user=$USER.$GROUP"
fi

case "$1" in
    start)
      echo "Starting Zebra Server"

      # create run and lock directories if needed;
      # /var/run and /var/lock are completely cleared at boot
      # on some platforms
      if [[ ! -d $RUNDIR ]]; then
        umask 022
        mkdir -p $RUNDIR
        if [[ $EUID -eq 0 ]]; then
            chown $USER:$GROUP $RUNDIR
        fi
      fi
      if [[ ! -d $LOCKDIR ]]; then
        umask 022
        mkdir -p $LOCKDIR
        mkdir -p $LOCKDIR/biblios
        mkdir -p $LOCKDIR/authorities
        if [[ $EUID -eq 0 ]]; then
            chown -R $USER:$GROUP $LOCKDIR
        fi
      fi

      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 $OTHERUSER -- $ZEBRASRV $ZEBRAOPTIONS -f $KOHA_CONF 
      ;;
    stop)
      echo "Stopping Zebra Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 $OTHERUSER --stop -- $ZEBRASRV -f $KOHA_CONF 
      ;;
    restart)
      echo "Restarting the Zebra Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 $OTHERUSER --restart -- $ZEBRASRV -f $KOHA_CONF 
      ;;
    *)
      echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
      exit 1
      ;;
esac
