#!/bin/sh

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
# Provides:          koha-index-daemon-$DBNAME
# Required-Start:    $local_fs $syslog
# Required-Stop:     $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     false
# Short-Description: Start/stop koha-index-daemon for $DBNAME
### END INIT INFO

. /lib/lsb/init-functions

USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
DBNAME=__DB_NAME__
NAME=koha-index-daemon-$DBNAME
LOGDIR=__LOG_DIR__
PERL5LIB=__PERL_MODULE_DIR__
KOHA_CONF=__KOHA_CONF_DIR__/koha-conf.xml
ERRLOG=$LOGDIR/koha-index-daemon.err
STDOUT=$LOGDIR/koha-index-daemon.log
OUTPUT=$LOGDIR/koha-index-daemon-output.log

export KOHA_CONF
export PERL5LIB

INDEXDAEMON="koha-index-daemon"
INDEXDAEMON_OPTS="--timeout 30 --conf $KOHA_CONF \
                  --directory /var/tmp/koha-index-daemon-$DBNAME"

DAEMONOPTS="--name=$NAME \
            --errlog=$ERRLOG \
            --stdout=$STDOUT \
            --output=$OUTPUT \
            --verbose=1 --respawn --delay=30"

USER="--user=$USER.$GROUP"


case "$1" in
    start)
      log_daemon_msg "Starting Koha indexing daemon ($DBNAME)"
      if daemon $DAEMONOPTS $USER -- $INDEXDAEMON $INDEXDAEMON_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    stop)
      log_daemon_msg "Stopping Koha indexing daemon ($DBNAME)"
      if daemon $DAEMONOPTS $USER --stop -- $INDEXDAEMON $INDEXDAEMON_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    restart)
      log_daemon_msg "Restarting the Koha indexing daemon ($DBNAME)"
      if daemon $DAEMONOPTS $USER --restart -- $INDEXDAEMON $INDEXDAEMON_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    *)
      log_success_msg "Usage: /etc/init.d/$NAME {start|stop|restart}"
      exit 1
      ;;
esac
