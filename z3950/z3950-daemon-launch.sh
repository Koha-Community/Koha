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

KohaZ3950Dir=/home/paul/koha.dev/koha/z3950
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
# Revision 1.2  2003/04/29 16:48:25  tipaul
# really proud of this commit :-)
# z3950 search and import seems to works fine.
# Let me explain how :
# * a "search z3950" button is added in the addbiblio template.
# * when clicked, a popup appears and z3950/search.pl is called
# * z3950/search.pl calls addz3950search in the DB
# * the z3950 daemon retrieve the records and stores them in z3950results AND in marc_breeding table.
# * as long as there as searches pending, the popup auto refresh every 2 seconds, and says how many searches are pending.
# * when the user clicks on a z3950 result => the parent popup is called with the requested biblio, and auto-filled
#
# Note :
# * character encoding support : (It's a nightmare...) In the z3950servers table, a "encoding" column has been added. You can put "UNIMARC" or "USMARC" in this column. Depending on this, the char_decode in C4::Biblio.pm replaces marc-char-encode by an iso 8859-1 encoding. Note that in the breeding import this value has been added too, for a better support.
# * the marc_breeding and z3950* tables have been modified : they have an encoding column and the random z3950 number is stored too for convenience => it's the key I use to list only requested biblios in the popup.
#
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
