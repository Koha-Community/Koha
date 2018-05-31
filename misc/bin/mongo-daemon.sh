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
# Provides:          mongo-daemon
# Required-Start:    $local_fs $syslog
# Required-Stop:     $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     false
# Short-Description: Start/stop mongo-daemon
### END INIT INFO

. /lib/lsb/init-functions

USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
DBNAME=__DB_NAME__
NAME=mongo-daemon
LOGDIR=__LOG_DIR__
PERL5LIB=__PERL_MODULE_DIR__
KOHA_CONF=__KOHA_CONF_DIR__/koha-conf.xml
ERRLOG=$LOGDIR/mongo-daemon.err
STDOUT=$LOGDIR/mongo-daemon.log
OUTPUT=$LOGDIR/mongo-daemon-output.log

export KOHA_CONF
export PERL5LIB

MONGODAEMON="$PERL5LIB/misc/logs_to_mongo.pl"
MONGODAEMON_OPTS="$2 $3"

DAEMONOPTS="--name=$NAME \
            --errlog=$ERRLOG \
            --stdout=$STDOUT \
            --output=$OUTPUT \
            --verbose=1 --respawn --delay=30"

USER="--user=$USER.$GROUP"


case "$1" in
    start)
      log_daemon_msg "Starting Mongo daemon"
      if daemon $DAEMONOPTS $USER -- $MONGODAEMON $MONGODAEMON_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    stop)
      log_daemon_msg "Stopping Mongo daemon"
      if daemon $DAEMONOPTS $USER --stop -- $MONGODAEMON $MONGODAEMON_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    restart)
      log_daemon_msg "Restarting Mongo daemon"
      if daemon $DAEMONOPTS $USER --restart -- $MONGODAEMON $MONGODAEMON_OPTS; then
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
