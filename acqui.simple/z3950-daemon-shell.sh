#!/bin/sh

# $Id$

# Script to start Koha background Z39.50 search daemon

# Part of the Koha Library Mgmt System -  www.koha.org
# Licensed under the GPL

#----------------------------
# Do NOT run this script directly from system startup-- this should not run as root
#    Call  z3950-daemon-launch.sh  instead

#----------------------------


# Parse /etc/koha.conf
for line in `cat /etc/koha.conf` ; do
    OIFS=$IFS
    IFS='='
    set -- $line
    if [ $1 = 'intranetdir' ] ; then
	intranetdir=$2
    fi
    if [ $1 = 'httpduser' ] ; then
	httpduser=$2
    fi
    if [ $1 = 'kohalogdir' ] ; then
	kohalogdir=$2
    fi
    IFS=$OIFS
done





KohaZ3950Dir=$intranetdir/scripts/z3950daemon
KohaModuleDir=$intranetdir/modules
LogDir=$kohalogdir

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
# Revision 1.1.2.4  2002/07/25 17:34:02  tonnesen
# shell scripts now parse the config file to get working directories and apache
# userid
#
# Revision 1.1.2.3  2002/06/28 17:45:39  tonnesen
# z3950queue now listens for a -HUP signal before processing the queue.  Z3950.pm
# sends the -HUP signal when queries are added to the queue.
#
# Revision 1.1.2.2  2002/06/26 16:25:51  amillar
# Make directory variable name more explanatory
#
