#!/bin/sh

# $Id$

# Script to start Koha background Z39.50 search daemon

# Part of the Koha Library Mgmt System -  www.koha.org
# Licensed under the GPL

#----------------------------
# Call this script during system startup, such as from rc.local

# Bugs/To Do:
#   Needs SysV-type start/stop options


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



#----------------------------
# User ID to run the daemon as.  Don't use "root"
RunAsUser=$httpduser

KohaZ3950Dir=$intranetdir/scripts/z3950daemon
export KohaZ3950Dir

#----------------------------
if [ ! -d $KohaZ3950Dir ]
then
	echo ERROR: Cannot find Koha directory $KohaZ3950Dir
	exit 1
fi

KohaZ3950Shell=$KohaZ3950Dir/z3950-daemon-shell.sh

if [ ! -x $KohaZ3950Shell ]
then
	echo ERROR: Cannot find Koha Z39.50 daemon launcher $KohaZ3950Shell
	exit 1
fi

su -s /bin/sh -c $KohaZ3950Shell - $RunAsUser &

exit

#--------------
# $Log$
# Revision 1.1.2.4  2002/07/25 17:34:02  tonnesen
# shell scripts now parse the config file to get working directories and apache
# userid
#
# Revision 1.1.2.3  2002/06/26 19:56:57  tonnesen
# Bug fix.  Single quotes were causing $KohaZ3950Shell variable to not get
# expanded
#
# Revision 1.1.2.2  2002/06/26 16:25:51  amillar
# Make directory variable name more explanatory
#
