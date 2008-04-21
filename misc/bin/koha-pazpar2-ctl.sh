#!/bin/bash
USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
DBNAME=__DB_NAME__
NAME=koha-pazpar2-ctl.$DBNAME
LOGDIR=__LOG_DIR__
ERRLOG=$LOGDIR/koha-pazpar2daemon.err
STDOUT=$LOGDIR/koha-pazpar2daemon.log
OUTPUT=$LOGDIR/koha-pazpar2daemon-output.log
PAZPAR2_CONF=__PAZPAR2_CONF_DIR__/pazpar2.xml
PAZPAR2SRV=/usr/sbin/pazpar2

test -f $PAZPAR2SRV || exit 0

OTHERUSER=''
if [[ $EUID -eq 0 ]]; then
    OTHERUSER="--user=$USER.$GROUP"
fi

case "$1" in
    start)
      echo "Starting PazPar2 Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 $OTHERUSER -- $PAZPAR2SRV -f $PAZPAR2_CONF 
      ;;
    stop)
      echo "Stopping PazPar2 Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --stop -- $PAZPAR2SRV -f $PAZPAR2_CONF 
      ;;
    restart)
      echo "Restarting the PazPar2 Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --restart -- $PAZPAR2SRV -f $PAZPAR2_CONF 
      ;;
    *)
      echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
      exit 1
      ;;
esac
