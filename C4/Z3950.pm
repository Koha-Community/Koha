#!/usr/bin/perl

# $Id$

package C4::Z3950; 

# Routines for handling Z39.50 lookups

# Koha library project  www.koha.org

# Licensed under the GPL

use strict;

# standard or CPAN modules used
use DBI;

# Koha modules used
use C4::Database;
use C4::Input;
use C4::Biblio;

#------------------

require Exporter;

use warnings;
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
	$dbh,
	$srvid,		# server id number 
	$default,
    )=@_;
    # return
    my $longname;
    #----

    requireDBI($dbh,"z3950servername");

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
	$query,		# value to look up
	$type,		# type of value ("isbn", "lccn", etc).
	$requestid,
	@z3950list,	# list of z3950 servers to query
    )=@_;

    my (
	$sth,
	@serverlist,
	$server,
	$failed,
    );
    
    requireDBI($dbh,"addz3950queue");

	# list of servers: entry can be a fully qualified URL-type entry
        #   or simply just a server ID number.

        $sth=$dbh->prepare("select host,port,db,userid,password 
	  from z3950servers 
	  where id=? ");
        foreach $server (@z3950list) {
	    if ($server =~ /:/ ) {
		push @serverlist, $server;
	    } else {
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

	# Don't allow reinsertion of the same request number.
	$sth=$dbh->prepare("select identifier from z3950queue 
		where identifier=?");
	$sth->execute($requestid);
	unless ($sth->rows) {
	    $sth=$dbh->prepare("insert into z3950queue 
		(term,type,servers, identifier) 
		values (?, ?, ?, ?)");
	    $sth->execute($query, $type, $serverlist, $requestid);
	}
} # sub addz3950queue

#--------------------------------------
# $Log$
# Revision 1.1.2.1  2002/06/26 07:26:41  amillar
# New module for Z39.50 searching
#
