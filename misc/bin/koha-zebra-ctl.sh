#!/bin/bash

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

### BEGIN INIT INFO
# Provides:          koha-zebra-daemon
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Zebra server daemon for Koha indexing
### END INIT INFO

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
        mkdir -p $LOCKDIR/rebuild
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
