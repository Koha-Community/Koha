#!/bin/sh

# $Id$

# Script to start Koha background Z39.50 search daemon

# Part of the Koha Library Mgmt System -  www.koha.org
# Licensed under the GPL

#----------------------------
# Call this script during system startup, such as from rc.local

# Bugs/To Do:
#   Needs SysV-type start/stop options

#----------------------------
# User ID to run the daemon as.  Don't use "root"
RunAsUser=apache

KohaZ3950Dir=/usr/local/www/koha/htdocs/cgi-bin/koha/acqui.simple
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
# Revision 1.1  2002/11/22 10:15:22  tipaul
# moving z3950 related scripts to specific dir
#
# Revision 1.3  2002/07/02 22:08:50  tonnesen
# merging changes from rel-1-2
#
# Revision 1.1.2.3  2002/06/26 19:56:57  tonnesen
# Bug fix.  Single quotes were causing $KohaZ3950Shell variable to not get
# expanded
#
# Revision 1.1.2.2  2002/06/26 16:25:51  amillar
# Make directory variable name more explanatory
#
