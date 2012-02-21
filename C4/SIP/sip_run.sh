#!/bin/bash
# 
# A sample script for starting SIP.  
# You probably want to specify new log destinations.
#
# Takes 3 optional arguments:
# ~ SIPconfig.xml file to use
# ~ file for STDOUT, default ~/sip.out
# ~ file for STDERR, default ~/sip.err
#
# The STDOUT and STDERR files are only for the SIPServer process itself.
# Actual SIP communication and transaction logs are handled by Syslog.
#
# Examples:
#   sip_run.sh /path/to/SIPconfig.xml
#   sip_run.sh ~/my_sip/SIPconfig.xml sip_out.log sip_err.log


for x in HOME PERL5LIB KOHA_CONF ; do
	echo $x=${!x}
	if [ -z ${!x} ] ; then 
		echo ERROR: $x not defined;
		exit 1;
	fi;
done;
unset x;
cd $PERL5LIB/C4/SIP;
echo;
echo Running from `pwd`;

sipconfig=${1:-`pwd`/SIPconfig.xml};
outfile=${2:-$HOME/sip.out};
errfile=${3:-$HOME/sip.err};

echo "Calling (backgrounded):";
echo "perl -I./ ./SIPServer.pm $sipconfig >>$outfile 2>>$errfile";
perl -I./ ./SIPServer.pm $sipconfig >>$outfile 2>>$errfile &
