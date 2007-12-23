#!/bin/bash
USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
NAME=koha-zebraqueue-ctl
LOGDIR=__LOG_DIR__
PERL5LIB=__PERL_MODULE_DIR__
KOHA_CONF=__KOHA_CONF_DIR__/koha-conf.xml
ERRLOG=$LOGDIR/koha-zebraqueue.err
STDOUT=$LOGDIR/koha-zebraqueue.log
OUTPUT=$LOGDIR/koha-zebraqueue-output.log
export KOHA_CONF
export PERL5LIB
ZEBRAQUEUE=__PERL_MODULE_DIR__/misc/bin/zebraqueue_daemon.pl

test -f $ZEBRAQUEUE || exit 0

case "$1" in
    start)
      echo "Starting Zebraqueue Daemon"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --user=$USER.$GROUP -- perl -I $PERL5LIB $ZEBRAQUEUE -f $KOHA_CONF 
      ;;
    stop)
      echo "Stopping Zebraqueue Daemon"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --user=$USER.$GROUP --stop -- perl -I $PERL5LIB $ZEBRAQUEUE -f $KOHA_CONF 
      ;;
    restart)
      echo "Restarting the Zebraqueue Daemon"
      daemon --name=$NAME --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --verbose=1 --respawn --delay=30 --user=$USER.$GROUP --restart -- perl -I $PERL5LIB $ZEBRAQUEUE -f $KOHA_CONF 
      ;;
    *)
      echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
      exit 1
      ;;
esac
