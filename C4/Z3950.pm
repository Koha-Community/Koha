#!/usr/bin/perl

# $Id$

package C4::Z3950; 

# Routines for handling Z39.50 lookups

# Koha library project  www.koha.org

# Licensed under the GPL


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

# standard or CPAN modules used
use DBI;

# Koha modules used
use C4::Database;
use C4::Input;
use C4::Biblio;

#------------------

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	 &z3950servername 
	 &addz3950queue 
);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);

# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();

# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;
#------------------------------------------------


sub z3950servername {
    # inputs
    my (
	$dbh,		# FIXME - Unused argument
	$srvid,		# server id number 
	$default,
    )=@_;
    # return
    my $longname;
    #----

    $dbh = C4::Context->dbh;

	# FIXME - Fix indentation
	my $sti=$dbh->prepare("select name 
		from z3950servers 
		where id=?");
	$sti->execute($srvid);
	if ( ! $sti->err ) {
	    ($longname)=$sti->fetchrow;
	}
	if (! $longname) {
	    $longname="$default";
	}
	return $longname;
} # sub z3950servername

#---------------------------------------
sub addz3950queue {
    use strict;
    # input
    my (
	$dbh,		# DBI handle
			# FIXME - Unused argument
	$query,		# value to look up
	$type,		# type of value ("isbn", "lccn", etc).
	$requestid,	# Unique value to prevent duplicate searches from multiple HTML form submits
	@z3950list,	# list of z3950 servers to query
    )=@_;
    # Returns:
    my $error;

    my (
	$sth,
	@serverlist,
	$server,
	$failed,
	$servername,
    );

    my $pidfile='/var/log/koha/processz3950queue.pid';
    
    $error="";

    $dbh = C4::Context->dbh;

	# FIXME - Fix indentation

	# list of servers: entry can be a fully qualified URL-type entry
        #   or simply just a server ID number.

        foreach $server (@z3950list) {
	    if ($server =~ /:/ ) {
		push @serverlist, $server;
	    } elsif ($server eq 'DEFAULT' || $server eq 'CHECKED' ) {
                $sth=$dbh->prepare("select host,port,db,userid,password ,name
	          from z3950servers 
	          where checked <> 0 ");
		$sth->execute;
		while ( my ($host, $port, $db, $userid, $password,$servername) 
			= $sth->fetchrow ) {
		    push @serverlist, "$servername/$host\:$port/$db/$userid/$password";
		} # while
	    } else {
                $sth=$dbh->prepare("select host,port,db,userid,password
	          from z3950servers 
	          where id=? ");
		$sth->execute($server);
		my ($host, $port, $db, $userid, $password) = $sth->fetchrow;
		push @serverlist, "$server/$host\:$port/$db/$userid/$password";
	    }
	}

	my $serverlist='';
	foreach (@serverlist) {
	    $serverlist.="$_ ";
    	} # foreach
	chop $serverlist;

	if ( $serverlist !~ /^ +$/ ) {
	    # Don't allow reinsertion of the same request identifier.
	    $sth=$dbh->prepare("select identifier from z3950queue 
		where identifier=?");
	    $sth->execute($requestid);
	    if ( ! $sth->rows) {
	        $sth=$dbh->prepare("insert into z3950queue 
		    (term,type,servers, identifier) 
		    values (?, ?, ?, ?)");
	        $sth->execute($query, $type, $serverlist, $requestid);
		if ( -r $pidfile ) { 
	            my $pid=`cat $pidfile`;
	            chomp $pid;
	            my $processcount=kill 1, $pid;
	            if ($processcount==0) {
		        $error.="Z39.50 search daemon error: no process signalled. ";
	            }
		} else {
		    $error.="No Z39.50 search daemon running: no file $pidfile. ";
		} # if $pidfile
	    } else {
	        $error.="Duplicate request ID $requestid. ";
	    } # if rows
	} else {
	    # server list is empty
	    $error.="No Z39.50 search servers specified. ";
	} # if serverlist empty
	
	return $error;

} # sub addz3950queue

#--------------------------------------
# $Log$
# Revision 1.4  2002/10/11 12:35:35  arensb
# Replaced &requireDBI with C4::Context->dbh
#
# Revision 1.3  2002/08/14 18:12:52  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.2  2002/07/02 20:31:33  tonnesen
# module added from rel-1-2 branch
#
# Revision 1.1.2.5  2002/06/29 17:33:47  amillar
# Allow DEFAULT as input to addz3950search.
# Check for existence of pid file (cat crashed otherwise).
# Return error messages in addz3950search.
#
# Revision 1.1.2.4  2002/06/28 18:07:27  tonnesen
# marcimport.pl will print an error message if it can not signal the
# processz3950queue program.  The message contains instructions for starting the
# daemon.
#
# Revision 1.1.2.3  2002/06/28 17:45:39  tonnesen
# z3950queue now listens for a -HUP signal before processing the queue.  Z3950.pm
# sends the -HUP signal when queries are added to the queue.
#
# Revision 1.1.2.2  2002/06/26 20:54:31  tonnesen
# use warnings breaks on perl 5.005...
#
# Revision 1.1.2.1  2002/06/26 07:26:41  amillar
# New module for Z39.50 searching
#
