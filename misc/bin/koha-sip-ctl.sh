#!/bin/bash
### BEGIN INIT INFO
# Provides:          koha-index-daemon
# Required-Start:    $syslog $remote_fs
# Required-Stop:     $syslog $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: SIP2 server daemon for Koha sipping
### END INIT INFO

quotes="\x{22}\x{27}"

ACTION=$1
SIPDEVICE=$2
test -z $SIPDEVICE && SIPDEVICE="ALL"
ACTIVATE_TCPDUMP=$3

USER=koha
GROUP=koha
#presuming the Koha rsyslog configurations to be in a fixed file.
#Need this to make sure the rsyslog has write permissions for the file.
KOHA_RSYSLOG_CONFIG="/etc/rsyslog.d/koha.conf"

SIPCONFIGDIR="__KOHA_CONF_DIR__/SIPconfig/"
LOGBASEDIR="__LOG_DIR__"
LOGDIR="$LOGBASEDIR/sip2/"
RUNDIR="/var/run/koha/sip2/"
LOCKDIR="/var/lock/koha/sip2/"
PERL_MODULE_DIR="__PERL_MODULE_DIR__"




# Check the prequisites, we need libxml, xmllint, and ncat from nmap
depsfail() {
  # Some of the needed software is missing
  echo "You need libxml2, xmllint and ncat from nmap package."
  echo "You also might need libxml2-utils for xmllint"
}

export xmllint="$(which xmllint)"
test -z $xmllint && depsfail && exit 1




##  0  ## Show how to use this carp!
function help_usage {
    echo "$0 -service"
    echo "Starts and stops Koha SIP server worker configurations"
    echo ""
    echo "USAGE:"
    echo "service $0 start|stop|restart <configName> [<tcpdump>]"
    echo ""
    echo "Param1 start, stop, restart daemon"
    echo "Param2 configuration name. Finds all *.xml-files from $SIPCONFIGDIR."
    echo "    Each config file is a clone of SIPconfig.xml containing specific"
    echo "    configuration for parallel SIP Servers."
    echo "    Param2 is the name of the config without the trailing filetype."
    echo "    OR ALL which targets all configuration files."
    echo "Param3 if defined, enables tcpdump:ing the RAW connection packets."
    echo ""
}

##  I  ## Find out the configuration files to start servers for.
function findConfigurationFile {
    SIPDEVICE=$1
    SIPCONFIGDIR=$2
    SIPCONFIGFILES=$(ls $SIPCONFIGDIR)

    SIPDEVICES=$(ls $SIPCONFIGDIR | grep -Po '^.*?(?=\.xml)')
    if [ "$SIPDEVICE" == "ALL" ] || [ -z "$SIPDEVICE" ]; then
        SIPDEVICES=$(ls $SIPCONFIGDIR | grep -Po '^.*?(?=\.xml)')
    elif [ "$SIPDEVICE" == "list" ]; then
        echo "----------------------------------------------------"
        echo "Unknown SIP configuration '$2'"
        echo "Valid configuration files present in $SIPCONFIGDIR:"
        echo "$SIPDEVICES"
        echo "----------------------------------------------------"
        help_usage
        exit 1
    elif [ $SIPDEVICE ]; then
        for SIPDEV in ${SIPDEVICES[@]}
        do
            if [ "$SIPDEVICE" == "$SIPDEV" ] ; then
                SIPDEVICES=$SIPDEV
                break
            fi
        done
    fi
}

function findSyslogFile {
  SIPCONFIG=$1

  # Get log facilities
  config=$($xmllint --xpath '//*[local-name()="server-params"]' $SIPCONFIG)
  logFile=$(       echo $config | $xmllint --xpath '//@log_file' - |
                    grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" )
  syslogIdent=$(   echo $config | $xmllint --xpath '//@syslog_ident' - |
                    grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" )
  syslogFacility=$(echo $config | $xmllint --xpath '//@syslog_facility' - |
                    grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" )
  SYSLOG_FILE=$(grep -P "$syslogFacility" $KOHA_RSYSLOG_CONFIG | grep -Po '/.+$')
}

##  II  ## Do the daemonizing magic
function operateSIPserverDaemon {
    ACTION=$1
    SIPDEVICE=$2
    SIPCONFIG="$SIPCONFIGDIR/$SIPDEVICE.xml"

    NAME=koha-sip-$SIPDEVICE-daemon
    ERRLOG=$LOGDIR/$SIPDEVICE.err
    touch $ERRLOG
    chown $USER:$GROUP $ERRLOG
    STDOUT=$LOGDIR/$SIPDEVICE.std
    touch $STDOUT
    chown $USER:$GROUP $STDOUT
    OUTPUT=$LOGDIR/$SIPDEVICE.out
    touch $OUTPUT
    chown $USER:$GROUP $OUTPUT
    LOG4PERL=$LOGBASEDIR/sip2.log
    touch $LOG4PERL
    chown $USER:$GROUP $LOG4PERL

    #Make sure rsyslog has write permission to the given file/folder
    findSyslogFile $SIPCONFIG #initializes SYSLOG_FILE
    if [ ! -e "$SYSLOG_FILE" ]; then
        touch $SYSLOG_FILE
    fi
    chown syslog:adm $SYSLOG_FILE


    . /etc/environment
    export KOHA_CONF PERL5LIB

    DAEMON_CALL="daemon --delay=30 --name=$NAME --pidfiles=$RUNDIR --user=$USER --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --respawn --command=perl "
    DAEMON_CMD_PARAMS=" -- -I$PERL_MODULE_DIR/C4/SIP/ -MILS $PERL_MODULE_DIR/C4/SIP/SIPServer.pm $SIPCONFIG"

    case "$ACTION" in
    start)
      echo "Starting SIP2 Server for $SIPDEVICE"

      # create run and lock and log directories if needed;
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
        if [[ $EUID -eq 0 ]]; then
            chown -R $USER:$GROUP $LOCKDIR
        fi
      fi
      if [[ ! -d $LOGDIR ]]; then
        umask 022
        mkdir -p $LOGDIR
        if [[ $EUID -eq 0 ]]; then
            chown -R $USER:$GROUP $LOGDIR
        fi
      fi

      $DAEMON_CALL $DAEMON_CMD_PARAMS

      ;;
    stop)
      echo "Stopping SIP2 Server for $SIPDEVICE"
      $DAEMON_CALL --stop $DAEMON_CMD_PARAMS
      ;;
    restart)
      echo "Restarting the SIP2 Server for $SIPDEVICE"
      $DAEMON_CALL --restart $DAEMON_CMD_PARAMS
      ;;
    *)
      echo "---------------------------------------------"
      echo "Usage: /etc/init.d/$NAME {start|stop|restart}"
      echo "---------------------------------------------"
      help_usage
      exit 1
      ;;
    esac
}

function operateTcpdumpDaemon {
    ACTION=$1
    SIPDEVICE=$2
    SIPCONFIG="$SIPCONFIGDIR/$SIPDEVICE.xml"

    NAME=koha-sip-$SIPDEVICE-tcpdump-daemon
    ERRLOG=$LOGDIR/$SIPDEVICE-tcpdump.err
    STDOUT=$LOGDIR/$SIPDEVICE-tcpdump.std
    OUTPUT=$LOGDIR/$SIPDEVICE-tcpdump.out

    SIPCONFIG_SERVICE_PORT=`xmlstarlet sel -N "x=http://openncip.org/acs-config/1.0/" -t -c '/x:acsconfig/x:listeners/x:service[@transport="RAW"]' $SIPCONFIG | xmlstarlet sel -N "x=http://openncip.org/acs-config/1.0/" -t -v "/x:service/@port"`
    SIP_PORT=`echo $SIPCONFIG_SERVICE_PORT | grep -Po '(?<=:)\d+(?=\/)'`

    DAEMON_CALL="daemon --delay=30 --name=$NAME --pidfiles=$RUNDIR --errlog=$ERRLOG --stdout=$STDOUT --output=$OUTPUT --respawn --command=/usr/sbin/tcpdump "
    DAEMON_CMD_PARAMS=" -- -i any -A port $SIP_PORT"

    case "$ACTION" in
    start)
      echo "Starting SIP2 Server tcpdump for $SIPDEVICE"

      # run and lock and log directories are created by the SIP server daemonizer

      $DAEMON_CALL $DAEMON_CMD_PARAMS
      ;;
    stop)
      echo "Stopping SIP2 Server tcpdump for $SIPDEVICE"
      $DAEMON_CALL --stop $DAEMON_CMD_PARAMS
      ;;
    restart)
      echo "Restarting the SIP2 Server tcpdump for $SIPDEVICE"
      $DAEMON_CALL --restart $DAEMON_CMD_PARAMS
      ;;
    *)
      echo "Bad \$ACTION for operateTcpdumpDaemon()"
      help_usage
      exit 1
      ;;
    esac


}

findConfigurationFile $SIPDEVICE $SIPCONFIGDIR
for SIPDEVICE in $SIPDEVICES; do

    operateSIPserverDaemon $ACTION $SIPDEVICE

    if [ -n "$ACTIVATE_TCPDUMP" ]; then #$ACTIVATE_TCPDUMP is defined
        operateTcpdumpDaemon $ACTION $SIPDEVICE
    fi
done
