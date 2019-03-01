#!/bin/sh
### BEGIN INIT INFO
# Provides:          koha-sip-daemon
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: SIP2 server daemon for Koha sipping
### END INIT INFO

. /etc/environment

# Export these here in just case, so that systemd doesn't trip on them.
# They should actually be exported in /etc/environment.
export KOHA_PATH
export KOHA_CONF
export PERL5LIB

SIPCONFIGDIR="__KOHA_CONF_DIR__/SIPconfig"

LOGBASEDIR="__LOG_DIR__"
LOGDIR="$LOGBASEDIR/sip2"
RUNDIR="/var/run/koha/sip2"

DAEMON_USER=__KOHA_USER__-sip
DAEMON_GROUP=__KOHA_GROUP__-sip

##  0  ## Show how to use this carp!
help_usage() {
    echo "$0 -service"
    echo "Starts and stops Koha SIP server worker configurations"
    echo
    echo "USAGE:"
    echo "service $0 start|stop|restart <configName> [--tcpdump]"
    echo
    echo "Param1 start, stop, restart daemon"
    echo "Param2 configuration name. Finds all *.xml-files from $SIPCONFIGDIR."
    echo "    Each config file is a clone of SIPconfig.xml containing specific"
    echo "    configuration for parallel SIP Servers."
    echo "    Param2 is the name of the config without the trailing filetype."
    echo "    OR ALL which targets all configuration files."
    echo "Param3 if defined, enables tcpdump:ing the RAW connection packets."
    echo
    exit 1
}

##  I  ## Find out the configuration files to start servers for.
findConfigurations() {
    if [ "$1" = "ALL" ] || [ -z "$1" ]; then
        ls $SIPCONFIGDIR/* 2> /dev/null
    else
        ls $SIPCONFIGDIR/$1.xml 2> /dev/null
    fi
}


##  II  ## Do the daemonizing magic
operateSIPserverDaemon() {
    DAEMON_ACTION="--$1"
    [ "$DAEMON_ACTION" = "--start" ] && unset DAEMON_ACTION

    SIPCONFIG=$2
    SIPDEVICE=${SIPCONFIG%.xml}
    SIPDEVICE=${SIPDEVICE##*/}

    NAME=koha-sip-$SIPDEVICE-daemon

    OUTPUT=$LOGDIR/$SIPDEVICE.log

    touch $OUTPUT
    chown $DAEMON_USER:root $OUTPUT
    chmod 600 $OUTPUT

    LOGBANG="--errlog=$OUTPUT --dbglog=$OUTPUT --output=$OUTPUT"

    daemon --delay=30 --name=$NAME --pidfiles=$RUNDIR --user=$DAEMON_USER $LOGBANG --respawn --command=perl $DAEMON_ACTION -- -I$KOHA_PATH/C4/SIP/ -MILS $KOHA_PATH/C4/SIP/SIPServer.pm $SIPCONFIG
}

operateTcpdumpDaemon() {
    DAEMON_ACTION="--$1"
    [ "$DAEMON_ACTION" = "--start" ] && unset DAEMON_ACTION

    SIPCONFIG=$2
    SIPDEVICE=${SIPCONFIG%.xml}
    SIPDEVICE=${SIPDEVICE##*/}

    NAME=koha-sip-$SIPDEVICE-tcpdump-daemon

    OUTPUT=$LOGDIR/$SIPDEVICE-tcpdump.out
    LOGBANG="--errlog=$OUTPUT --dbglog=$OUTPUT --output=$OUTPUT"

    SIPCONFIG_SERVICE_PORT=`xmlstarlet sel -N "x=http://openncip.org/acs-config/1.0/" -t -c '/x:acsconfig/x:listeners/x:service[@transport="RAW"]' $SIPCONFIG | xmlstarlet sel -N "x=http://openncip.org/acs-config/1.0/" -t -v "/x:service/@port"`
    SIP_PORT=`echo $SIPCONFIG_SERVICE_PORT | grep -Po '(?<=:)\d+(?=\/)'`

    echo "SIP2 tcpdump $SIPDEVICE $ACTION"

    daemon --delay=30 --name=$NAME --pidfiles=$RUNDIR $LOGBANG --respawn --command=/usr/sbin/tcpdump $DAEMON_ACTION -- -i any -A port $SIP_PORT
}

# Parse arguments
[ $# -gt 3 ] || [ $# -eq 0 ] && help_usage

ACTION=$1
shift

for ARGS in $@; do
    if [ "$1" = "--tcpdump" ]; then
        TCPDUMP=$1
    else
        CONFIGS=$1
    fi
    shift
done

# Create the required dirs
mkdir -p $RUNDIR $LOGDIR
chmod 711 $RUNDIR $LOGDIR
chown $DAEMON_USER:root $RUNDIR $LOGDIR

# Allowed parameters are start stop and restart
case $ACTION in start | stop | restart )
    for SIPCONFIG in $(findConfigurations $CONFIGS); do
        operateSIPserverDaemon $ACTION $SIPCONFIG
        [ "$TCPDUMP" = "--tcpdump" ] && TcpdumpDaemon $ACTION $SIPCONFIG
    done
    ;;
* )
    help_usage
esac

exit 0
