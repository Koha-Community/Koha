#!/bin/sh

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

KohaDir=/usr/local/www/koha/htdocs/cgi-bin/koha/acqui.simple
export KohaDir

#----------------------------
if [ ! -d $KohaDir ]
then
	echo ERROR: Cannot find Koha directory $KohaDir
	exit 1
fi

KohaZ3950Shell=$KohaDir/z3950-daemon-shell.sh

if [ ! -x $KohaZ3950Shell ]
then
	echo ERROR: Cannot find Koha Z39.50 daemon launcher $KohaZ3950Shell
	exit 1
fi

su -s /bin/sh -c '$KohaZ3950Shell &' - $RunAsUser &
