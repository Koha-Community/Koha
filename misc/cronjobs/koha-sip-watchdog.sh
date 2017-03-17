#!/bin/bash
# koha-sip-watchdog V160504 - Written by Pasi Korkalo/OUTI-Libraries
# (C) OUTI-libraries, Koha-Suomi Oy
# License: GPL-3 or newer
#
# Check that configured koha SIP-servers are responding and restart if necessary

IFS="
"
quotes="\x{22}\x{27}"
rsyslogDateRegexp="^\w+ \d+ \d+:\d+:\d+"
rsyslogKohaConf="/etc/rsyslog.d/koha.conf"
errorsFound=""

trysip() {
  ip="$1"
  port="$2"
  user="$3"
  pass="$4"
  branch="$5"
  # Send 93 message to SIP-server
  test -z "$1" || test -z "$2" && return 1
  SIP_RV=$( echo "9300CN$user|CO$pass|CP$branch|" | $nc -w 5 "$ip" "$port" ) #5 second timeout
  SIP_RV=$(echo "$SIP_RV" | grep -Po '\d+')
  return 0
}

checkrunning() {
  sipname="$1"
  # Find out if the SIP-server is running (listed in process list)
  pgrep -f "SIPServer.pm.*$sipname.xml" > /dev/null 2>&1 && return 0
  return 1
}

timestamp() {
  # Just print date/time for logging
  date "+%d.%m.%Y %H:%M:%S"
}

depsfail() {
  # Some of the needed software is missing
  echo "You need libxml2, xmllint and nc from nmap package."
  echo "You also might need libxml2-utils for xmllint"
}

getSysLogFile() {
  facility="$1"
  logFile=$(grep -P "$facility" $rsyslogKohaConf | grep -Po '/.+$')
}

checkLog() {
  # Check if the given log configuration is correct and works as intended
  # Find the last 9300 response log message from this sip server user, extract the timestamp and compare.
  sipname="$1"
  sipuser="$2"
  logFile="$3"
  logIdent="$4"
  logFacility="$5"

  if [ $logFile == "Sys::Syslog" ]; then
    getSysLogFile $logFacility
  fi

  latestLogDate=$(tail -n 1000 $logFile | grep -P '9300' | grep -Po "^.+(?=$logIdent)" | grep -Po "$rsyslogDateRegexp" | tail -n 1 ) #Extract date portio of the log entry
  if [ -z $latestLogDate ]; then
    latestLogDate="1970-01-01"
  fi
  logTimestamp=$(date --date="$latestLogDate" +%s)
  logStaleness=$(( $(date +%s) - $logTimestamp ))
  if [ $(($logStaleness > 5)) == 1 ]; then #The logged timestamp and current timestamp are more than 5 seconds apart
    echo "$(timestamp) $sipname.$sipuser Logging is broken. Last entry from $logStaleness seconds away"
    errorsFound=1
  else
    bashXSilentMsg="\n-----------------------Logging for SIP server $sipname works :3---------------------\n"
  fi

}

restart() {
  sipname="$1"
  serveruser="$2"

  if test "$1" = "--forcerestart"; then
    # If the restart is forced, we will do stop/start instead of just restart, this
    # will start the server even if it was not running

    sudo /etc/init.d/koha-sip-daemon stop "$sipname" > /dev/null 2>&1
    for waitpid in $(seq 5); do checkrunning "$sipname" && sleep 1 || break; done

    if checkrunning $sipname; then
      echo "$(timestamp) $sipname.$serveruser refused to die."
      continue
    fi

    sudo /etc/init.d/koha-sip-daemon start "$sipname" > /dev/null 2>&1
    for waitpid in $(seq 5); do checkrunning "$sipname" && break || sleep 1; done

    echo -n "$(timestamp) $sipname.$serveruser restart "
    checkrunning $sipname && echo "OK." || echo "failed."

  else
    if checkrunning $sipname; then #server is running
      # Without forcerestart we will just do a normal restart
      sudo /etc/init.d/koha-sip-daemon restart "$sipname" > /dev/null 2>&1
    else
      #daemon doesnt respond well to restart if the daemon wasn't running in the first place
      sudo /etc/init.d/koha-sip-daemon start "$sipname" > /dev/null 2>&1
    fi

    echo -n "$(timestamp) $sipname.$serveruser restart "
    checkrunning $sipname && echo "OK." || echo "failed."

  fi
}

watchdog() {
  # Watchdog does the main aliveness checks against the given server configuration parameters
  sipname="$1"
  serverip="$2"
  serverport="$3"
  serveruser="$4"
  serverpass="$5"
  serverbrnc="$6"

  trysip "$serverip" "$serverport" "$serveruser" "$serverpass" "$serverbrnc"
  #exports $SIP_RV

  # Did the server respond with 94, it's ok if the login itself fails, the important
  # thing is that we received a reply
  if test "$SIP_RV" == "940"; then

    echo "$(timestamp) $sipname.$serveruser ($serverip:$serverport) - credentials misconfigured." # Credentials are misconfigured
    errorsFound=1

  elif test "$SIP_RV" == "941"; then

    echo "$(timestamp) $sipname.$serveruser ($serverip:$serverport) - OK." # It's all good, the server said 941

  elif test -z "$SIP_RV"; then
    # The server did not respond in time, so restart it
    echo "$(timestamp) $sipname.$serveruser ($serverip:$serverport) - not responding, restarting..."
    errorsFound=1
    restart "$sipname" "$serveruser"
  else
    # The server responded in unexpected fashion
    echo "$(timestamp) $sipname.$serveruser ($serverip:$serverport) - unexpected response $SIP_RV"
    errorsFound=1
  fi
}

# Check the prequisites, we need libxml, xmllint, and ncat from nmap
export xmllint="$(which xmllint)"
test -z $xmllint && depsfail && exit 1

export nc="$(which nc)"
test -z $nc && depsfail && exit 1

# Check that we have the required permissions for the koha-sip-daemon initscript
if ! sudo -l /etc/init.d/koha-sip-daemon > /dev/null 2>&1; then
  echo "You will need to be able to restart koha-sip-daemon as sudo root."
  echo "Add $(id -un) to sudoers (sudo visudo) like this:\n"
  echo "$(id -un) ALL=(ALL) NOPASSWD: /etc/init.d/koha-sip-daemon"
  exit 1
fi

# Loop through all SIP-configurations, check and restart when necessary
for sipserver in $(ls ${KOHA_CONF%/koha-conf.xml}/SIPconfig/*.xml); do

  # Get SIP-name from the xml filename
  sipname=${sipserver##*/}
  sipname=${sipname%.xml}

#DEBUG: test only on a specific server
#if test "$sipname" != "SIPconfig"
#then
#  continue
#fi

  echo "$(timestamp) Checking $sipname"

  # Get ip/port information from SIP-config
  config=$($xmllint --xpath '//*[@port]/@port' $sipserver)

  serverip=${config#*\"}
  serverip=${serverip%:*}
  serverport=${config#*:}
  serverport=${serverport%/*} #Crazy sh-fu :) <3

  # Get log facilities
  config=$($xmllint --xpath '//*[local-name()="server-params"]' $sipserver)
  logFile=$(       echo $config | $xmllint --xpath '//@log_file' - |
                    grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" )
  syslogIdent=$(   echo $config | $xmllint --xpath '//@syslog_ident' - |
                    grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" )
  syslogFacility=$(echo $config | $xmllint --xpath '//@syslog_facility' - |
                    grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" )

  # Get username and password
  config=$($xmllint --xpath '//*[local-name()="accounts"]' $sipserver)
  serveruser=($(echo $config | $xmllint --xpath '//@id' -          | grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" ))
  serverpass=($(echo $config | $xmllint --xpath '//@password' -    | grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" ))
  serverbrnc=($(echo $config | $xmllint --xpath '//@institution' - | grep -Po "[$quotes].+?[$quotes]" | grep -Po "[^$quotes]+" ))

  arraySize=$((${#serveruser[@]} - 1))
  for i in `seq 0 $arraySize`
  do
    silentBashXMsg="\n----------------NEW WATCHDOG LOOP-------------------\n"
    watchdog "$sipname" "$serverip" "$serverport" "${serveruser[$i]}" "${serverpass[$i]}" "${serverbrnc[$i]}"
    checkLog "$sipname" "${serveruser[$i]}" "$logFile" "$syslogIdent" "$syslogFacility"
  done

done

#Exit with error code if errors found
test -z errorsFound && exit 0

#All went fine and dandy!
exit 1
