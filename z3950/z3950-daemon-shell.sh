#!/bin/sh

# $Id$

# Script to start Koha background Z39.50 search daemon

# Part of the Koha Library Mgmt System -  www.koha.org
# Licensed under the GPL

#----------------------------
# Do NOT run this script directly from system startup-- this should not run as root
#    Call  z3950-daemon-launch.sh  instead

#----------------------------
. z3950-daemon-options

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
# Revision 1.3  2003/10/06 09:10:39  slef
# Removing config info from z3950*sh and using C4::Context in processz3950queue (Fixed bug 39)
#
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
# Revision 1.1.2.3  2002/06/28 17:45:39  tonnesen
# z3950queue now listens for a -HUP signal before processing the queue.  Z3950.pm
# sends the -HUP signal when queries are added to the queue.
#
# Revision 1.1.2.2  2002/06/26 16:25:51  amillar
# Make directory variable name more explanatory
#
