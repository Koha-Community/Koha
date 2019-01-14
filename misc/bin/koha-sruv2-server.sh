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
# Provides:          koha-sruv2-server-$DBNAME
# Required-Start:    $local_fs $syslog
# Required-Stop:     $local_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Interactive:     false
# Short-Description: Start/stop koha-sruv2-server for $DBNAME
### END INIT INFO

. /lib/lsb/init-functions

USER=__KOHA_USER__
GROUP=__KOHA_GROUP__
DBNAME=__DB_NAME__
NAME=koha-sruv2-server-$DBNAME
LOGDIR=__LOG_DIR__
PERL5LIB=__PERL_MODULE_DIR__
KOHA_CONFDIR=__KOHA_CONF_DIR__
KOHA_CONF=$KOHA_CONFDIR/koha-conf.xml
SRU_CONFDIR=$KOHA_CONFDIR/z3950
ERRLOG=$LOGDIR/koha-sru-server.err
STDOUT=$LOGDIR/koha-sru-server.log
OUTPUT=$LOGDIR/koha-sru-server-output.log

export KOHA_CONF
export PERL5LIB

SRUSERVER="/usr/bin/perl $PERL5LIB/misc/z3950_responder.pl"
SRUSERVER_OPTS="-c $SRU_CONFDIR -v request,session,fatal,warn,server"

DAEMONOPTS="--name=$NAME \
            --errlog=$ERRLOG \
            --stdout=$STDOUT \
            --output=$OUTPUT \
            --verbose=1 --respawn --delay=30"

USER="--user=$USER.$GROUP"


case "$1" in
    start)
      log_daemon_msg "Starting Koha SRU server ($DBNAME)"
      if daemon $DAEMONOPTS $USER -- $SRUSERVER $SRUSERVER_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    stop)
      log_daemon_msg "Stopping Koha SRU server ($DBNAME)"
      if daemon $DAEMONOPTS $USER --stop -- $SRUSERVER $SRUSERVER_OPTS; then
        log_end_msg 0
      else
        log_end_msg 1
      fi
      ;;
    restart)
      log_daemon_msg "Restarting the Koha SRU server ($DBNAME)"
      if daemon $DAEMONOPTS $USER --restart -- $SRUSERVER $SRUSERVER_OPTS; then
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
