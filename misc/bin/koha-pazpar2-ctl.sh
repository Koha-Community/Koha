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
# Provides:          koha-pazpar-daemon
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: PazPar2 server daemon for Koha
### END INIT INFO

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
