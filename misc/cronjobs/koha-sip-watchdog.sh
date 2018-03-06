#!/bin/sh 
# koha-sip-watchdog V160504 - Written by Pasi Korkalo/OUTI-Libraries
# Check that configured koha SIP-servers are responding and restart if necessary

response() {
  # Return the name of the response-file or kill the file. This is a bit ugly
  # but we need to use a file instad of a variable for response, because
  # the response will be coming from a subshell that is left running
  if test "$1" = "kill"; then
    shift
    rm -f $(echo "/tmp/$(echo "$@" | md5sum | cut -f 1 -d ' ')")
  else
    echo "/tmp/$(echo "$@" | md5sum | cut -f 1 -d ' ')"
  fi
}

trysip() {
  # Send 93 message to SIP-server
  test -z "$1" || test -z "$2" && return 1 
  echo "9300CNOUTI-watchdog|COWoof!Woof!|CPCPL|" | $ncat $@ | cut -c 1-2 > $(response $@)
  return 0
}

checkrunning() {
  # Find out if the SIP-server is running (listed in process list)
  pgrep -f "SIPServer.pm.*${1}.xml" > /dev/null 2>&1 && return 0 
  return 1
}

timestamp() { 
  # Just print date/time for logging
  date "+%d.%m.%Y %H:%M:%S"
}

depsfail() {
  # Some of the needed software is missing
  echo "You need libxml2, xmllint and ncat from nmap package."
}

# Check the prequisites, we need libxml, xmllint, and ncat from nmap
export xmllint="$(which xmllint)"
test -z $xmllint && depsfail && exit 1

export ncat="$(which ncat)"
test -z $ncat && depsfail && exit 1

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

  echo "$(timestamp) Checking $sipname"

  # Get ip/port information from SIP-config
  config=$($xmllint --xpath '//*[@port]/@port' $sipserver)

  serverip=${config#*\"}
  serverip=${serverip%:*}
  serverport=${config#*:}
  serverport=${serverport%/*}

  # Get rid of stale response-file just in case
  response kill $serverip $serverport
  
  # Start the "try" process in the background, store PID
  trysip $serverip $serverport &
  trypid=$!

  # Give the server max 10 seconds to respond, then kill the try PID (it seems to have hanged)
  for waitresponse in $(seq 10); do test -s "$(response $serverip $serverport)" && break || sleep 1; done
  kill $trypid 2> /dev/null
  
  # Did the server respond with 94, it's ok if the login itself fails, the important
  # thing is that we received a reply
  if test "$(cat $(response $serverip $serverport) 2> /dev/null)" = "94"; then

    echo "$(timestamp) $serverip $serverport OK." # It's all good, the server said 94

  else

    # The server did not respond in time, so restart it
    echo "$(timestamp) $sipname ($serverip:$serverport) not responding, restarting..."

      if test "$1" = "--forcerestart"; then
        # If the restart is forced, we will do stop/start instead of just restart, this
        # will start the server even if it was not running

        sudo /etc/init.d/koha-sip-daemon stop $sipname > /dev/null 2>&1
        for waitpid in $(seq 5); do checkrunning $sipname && sleep 1 || break; done

        if checkrunning $sipname; then
          echo "$(timestamp) $sipname refused to die."
          response kill $serverip $serverport
          continue
        fi
          
        sudo /etc/init.d/koha-sip-daemon start $sipname > /dev/null 2>&1
        for waitpid in $(seq 5); do checkrunning $sipname && break || sleep 1; done

        echo -n "$(timestamp) $sipname restart "
        checkrunning $sipname && echo "OK." || echo "failed."

      else
        # Without forcerestart we will just do a normal restart

        sudo /etc/init.d/koha-sip-daemon restart $sipname > /dev/null 2>&1

        echo -n "$(timestamp) $sipname restart "
        checkrunning $sipname && echo "OK." || echo "failed."

    fi
  
  fi 
  
  response kill $serverip $serverport

done
