#!/bin/sh

# $Id$

# Script to start Koha background Z39.50 search daemon

# Part of the Koha Library Mgmt System -  www.koha.org
# Licensed under the GPL

#----------------------------
# Do NOT run this script directly from system startup-- this should not run as root
#    Call  z3950-daemon-launch.sh  instead

#----------------------------

KohaZ3950Dir=/usr/local/www/koha/htdocs/cgi-bin/koha/acqui.simple
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

KohaZ3950Script=$KohaZ3950Dir/processz3950queue
if [ ! -x $KohaZ3950Script ]
then
	echo ERROR: Cannot find Koha Z39.50 daemon script $KohaZ3950Script
	exit 1
fi

PERL5LIB=$KohaModuleDir
export PERL5LIB

exec $KohaZ3950Script $LogDir >>$LOGFILE 2>&1

#-------------------
# $Log$
# Revision 1.1.2.3  2002/06/28 17:45:39  tonnesen
# z3950queue now listens for a -HUP signal before processing the queue.  Z3950.pm
# sends the -HUP signal when queries are added to the queue.
#
# Revision 1.1.2.2  2002/06/26 16:25:51  amillar
# Make directory variable name more explanatory
#
