#!/bin/sh

# Script to start Koha background Z39.50 search daemon

# Part of the Koha Library Mgmt System -  www.koha.org
# Licensed under the GPL

#----------------------------
# Do NOT run this script directly from system startup-
#    Call  z3950-daemon-launch.sh  instead

#----------------------------

KohaDir=/usr/local/www/koha/htdocs/cgi-bin/koha/acqui.simple
KohaModuleDir=/usr/local/koha/modules
LogDir=/var/log/koha

#----------------------------
LOGFILE=$LogDir/z3950-daemon-`date +%Y%m%d-%H%M`.log

touch $LOGFILE
if [ ! -w $LOGFILE ]
then
	echo ERROR: Cannot write to log file $LOGFILE
	exit 1
fi

KohaZ3950Script=$KohaDir/processz3950queue
if [ ! -x $KohaZ3950Script ]
then
	echo ERROR: Cannot find Koha Z39.50 daemon script $KohaZ3950Script
	exit 1
fi

PERL5LIB=$KohaModuleDir
export PERL5LIB

exec $KohaDir/processz3950queue >>$LOGFILE 2>&1
