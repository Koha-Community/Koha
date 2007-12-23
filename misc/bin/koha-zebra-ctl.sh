#!/bin/bash
USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
NAME=koha-zebra-ctl
LOGDIR=__LOG_DIR__
ERRLOG=$LOGDIR/koha-zebradaemon.err
STDOUT=$LOGDIR/koha-zebradaemon.log
OUTPUT=$LOGDIR/koha-zebradaemon-output.log
KOHA_CONF=__KOHA_CONF_DIR__/koha-conf.xml
# you may need to change this depending on where zebrasrv is installed
ZEBRASRV=/usr/bin/zebrasrv

test -f $ZEBRASRV || exit 0

case "$1" in
    start)
      echo "Starting Zebra Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --user=$USER.$GROUP -- $ZEBRASRV -f $KOHA_CONF 
      ;;
    stop)
      echo "Stopping Zebra Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --user=$USER.$GROUP --stop -- $ZEBRASRV -f $KOHA_CONF 
      ;;
    restart)
      echo "Restarting the Zebra Server"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --user=$USER.$GROUP --restart -- $ZEBRASRV -f $KOHA_CONF 
      ;;
    *)
      echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
      exit 1
      ;;
esac
