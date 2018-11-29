#!/bin/bash
#
# Copyright 2015 Theke Solutions, 2018 Koha-Suomi Oy
#
# This file is part of Koha.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

### BEGIN INIT INFO
# Provides:          koha-plack-daemon
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Plack server daemon for fast http-handling
### END INIT INFO

set -e

. /lib/lsb/init-functions

HELPER_FUNCTIONS="__PERL_MODULE_DIR__/debian/scripts/koha-functions.sh"

RUNDIR="/var/run/koha"
LOGDIR="__LOG_DIR__"
PIDFILE="$RUNDIR/plack.pid"
PLACKSOCKET="$RUNDIR/plack.sock"
PSGIFILE="__PERL_MODULE_DIR__/misc/plack/plack.psgi"
MODE="deployment" #development|deployment|test
LISTEN=":5000"

#User and group must be the same as for apache2, eg. www-data. This is to prevent nasty surprises with priviledge escalation.
#And so programs can communicate via the same unix-socket. You need to include Koha user in www-data group so that logging
#doesn't get complicated.
DAEMON_USER="www-data"
DAEMON_GROUP="www-data"

#Set Environment for koha-plack-daemon.sh
export KOHA_CONF="__KOHA_CONF_DIR__/koha-conf.xml"
export INTRANET_CGI_DIR="__INTRANET_CGI_DIR__"
export OPAC_CGI_DIR="__OPAC_CGI_DIR__/opac"
export PERL_MODULE_DIR="__PERL_MODULE_DIR__"
export PLACK_DEBUG #This is set if debug-parameter is given or if mode is development

#Make sure the pid-dir and log-dir exists + set owners and permissions
mkdir -p $RUNDIR $LOGDIR
chmod 770 $RUNDIR $LOGDIR
chown $DAEMON_USER:$DAEMON_GROUP $LOGDIR $RUNDIR

# include helper functions
if [ -f "$HELPER_FUNCTIONS" ]; then
    . "$HELPER_FUNCTIONS"
else
    echo "Error: $HELPER_FUNCTIONS not present." 1>&2
    exit 1
fi

usage()
{
    local scriptname=$(basename $0)

    cat <<EOF
$scriptname

This script lets you manage the plack daemon for your Koha instance.

Usage:
$scriptname start|stop|restart|reload [development|deployement|test] [debug] [debugger] [listen :8000]
$scriptname -h|--help

    start               Start the plack daemon for the specified instances
    stop                Stop the plack daemon for the specified instances
    restart             Restart the plack daemon for the specified instances
    reload              Reload the application without losing connections
    debug               Trigger PLACK_DEBUG -environment variable
    debugger            Start perl with the -d -flag
    deployment          Set the plack mode
    development         Set the plack mode
    test                Set the plack mode
    listen              Port or socket to listen on, defaults to $LISTEN
    --help|-h           Display this help message

ENVIRONMENT

    ## Configure remote debugging using the Camelcadedb-modules
    #  ip and port of the remote debugging server listening for DBGP-connections
    PERL5_DEBUG_HOST=192.168.100.1
    PERL5_DEBUG_PORT=54321
    # see. https://github.com/Camelcade/Perl5-IDEA/wiki/Perl-Debugger

EXAMPLE

bash -x /etc/init.d/koha-plack-daemon start development debug debugger listen :8000

EOF
}

start_plack()
{
    # Default to 10 workers/1000 requests for deployment if not otherwise configured in koha-conf.xml
    WORKERS=$(xmllint --xpath "yazgfs/config/plack_workers/text()" $KOHA_CONF 2> /dev/null || printf "10")
    REQUESTS=$(xmllint --xpath "yazgfs/config/plack_max_requests/text()" $KOHA_CONF 2> /dev/null || printf "1000")

    test "$DEBUGGER" == "1" && DEBUGGER_STR="/usr/bin/perl -d "

    STARMANOPTS="-M FindBin \
                 --user=$DAEMON_USER --group=$DAEMON_GROUP \
                 --listen $LISTEN \
                 -E $MODE \
                 $PSGIFILE "

    if [[ "$MODE" != "deployment" ]]; then
        STARMANOPTS="$STARMANOPTS --workers 1"
        $DEBUGGER_STR $STARMAN $STARMANOPTS
    fi

    if [[ "$MODE" == "deployment" ]]; then
        test "$MODE" == "deployment" && STARMANOPTS="$STARMANOPTS --daemonize \
                                                                  --pid $PIDFILE \
                                                                  --max-requests $REQUESTS \
                                                                  --workers $WORKERS \
                                                                  --access-log $LOGDIR/plack.log \
                                                                  --error-log $LOGDIR/plack-error.log"

        test -n "$PLACKSOCKET" && STARMANOPTS="$STARMANOPTS --listen $PLACKSOCKET "

        if ! is_plack_running; then
            log_daemon_msg "Starting Plack daemon"

            if $DEBUGGER_STR $STARMAN $STARMANOPTS; then
                log_end_msg 0
            else
                log_end_msg 1
            fi
        else
            log_daemon_msg "Error: Plack already running"
            log_end_msg 1
        fi
    fi
}

stop_plack()
{
    if is_plack_running; then

        log_daemon_msg "Stopping Plack daemon"

        if start-stop-daemon --pidfile $PIDFILE --stop; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Plack not running"
        log_end_msg 1
    fi
}

restart_plack()
{
    if is_plack_running; then

        log_daemon_msg "Restarting Plack daemon"

        if stop_plack && sleep 2 && start_plack; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: Plack not running"
        log_end_msg 1
    fi
}

#Starman says he supports hot-reload. Maybe others do, but I only love starman.
reload_starman()
{
    if is_plack_running; then

        log_daemon_msg "Hot-reloading starman daemon !!!"

        if start-stop-daemon --pidfile $PIDFILE --stop --signal HUP; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
    else
        log_daemon_msg "Error: starman not running"
        log_end_msg 1
    fi
}

check_env_and_warn()
{
    local apache_version_ok="no"
    local required_modules="headers proxy_http"
    local missing_modules=""

    if /usr/sbin/apache2ctl -v | grep -q "Server version: Apache/2.4"; then
        apache_version_ok="yes"
    fi

    for module in $required_modules; do
        if ! /usr/sbin/apachectl -M 2> /dev/null | grep -q $module; then
            missing_modules="$missing_modules$module "
        fi
    done

    if [ "$apache_version_ok" != "yes" ]; then
        warn "WARNING: koha-plack requires Apache 2.4.x and you don't have that."
    fi

    if [ "$missing_modules" != "" ]; then
        cat 1>&2 <<EOM
WARNING: koha-plack requires some Apache modules that you are missing.
You can install them with:

    sudo a2enmod $missing_modules

EOM

    fi
}

set_action()
{
    test -z "$op" && op=$1 || die "Error: only one action can be specified."
}

STARMAN=$(which starman)
op=""
quiet="no"

# Read command line parameters
while [ $# -gt 0 ]; do

    case "$1" in
        -h|--help)
            usage ; exit 0 ;;
        start)
            set_action "start"
            shift ;;
        stop)
            set_action "stop"
            shift ;;
        restart)
            set_action "restart"
            shift ;;
        reload)
            set_action "reload"
            shift ;;
        debug)
            export PLACK_DEBUG=1
            shift ;;
        debugger)
            DEBUGGER="1"
            shift ;;
        deployment)
            MODE="deployment"
            shift ;;
        development)
            MODE="development"
            export PLACK_DEBUG=1
            shift ;;
        test)
            MODE="test"
            shift ;;
        listen)
            LISTEN="$2"
            shift; shift; ;;
        -*)
            die "Error: invalid option switch ($1)" ;;
        *)
            # We expect the remaining stuff are the instance names
            break ;;
    esac

done

test -z $PERL5LIB && PERL5LIB="$INTRANET_CGI_DIR"
export PERL5LIB

check_env_and_warn

case $op in
    "start")
        start_plack
        ;;
    "stop")
        stop_plack
        ;;
    "restart")
        restart_plack
        ;;
    "reload")
        reload_starman
        ;;
    "enable")
        enable_plack
        ;;
    "disable")
        disable_plack
        ;;
    *)
        usage
        ;;
esac

exit 0
