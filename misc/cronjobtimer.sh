#!/bin/bash

## SYNOPSIS ##
# This script takes another script and measures it's runtime, appending it to the same log that the script's stderr and stdout go.
# First argument is the script name, relative to this scripts location.
# All arguments are passed directly to the first argument script.
#
# This script also locks the given script to prevent cronjobs from going to a repeating loop.
#

logdirectory=$(grep -Po '(?<=<logdir>).*?(?=</logdir>)' $KOHA_CONF)/
logfile=$1".log"
cronjobdir=$(dirname "$logfile")
logpath=$logdirectory$logfile
croncommand=$KOHA_PATH"/misc/$@"
lockfile=$KOHA_PATH"/misc/$1.lock"
disableCronjobsFlag=$KOHA_PATH"/misc/cronjobs/disableCronjobs.flag"

if [ ! -d "$logdirectory/$cronjobdir" ]; then
        #Make sure that the cronjob folders exists
        mkdir -p "$logdirectory/$cronjobdir"
fi


starttime=$(date +%s)
startMsg='Start: '$(date --date="@$starttime" "+%Y-%m-%d %H:%M:%S")
printf "$startMsg\n" >> $logpath

#Check if cronjobs are disabled by the preproduction to production migration process
if [ -e $disableCronjobsFlag ]; then
	echo "Disabled by disableCronjobsFlag" >> $logpath
        exit 0;
fi

#Lock the cronjob we are running!
if [ -e $lockfile ]; then
	echo "Lockfile present" >> $logpath
	exit 0;
fi
touch $lockfile


starttime=$(date +%s)


$croncommand 2&>> $logpath


endtime=$(date +%s)
runtime=$((endtime - starttime))
timelog='End: '$(date --date="@$endtime" "+%Y-%m-%d %H:%M:%S")"\n"'Runtime: '$(($runtime/60/60))':'$(($runtime/60%60))':'$(($runtime%60))

printf "$timelog\n" >> $logpath

rm $lockfile
