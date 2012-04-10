package C4::Z3950;


# Routines for handling Z39.50 lookups

# Koha library project  www.koha-community.org

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505

# standard or CPAN modules used
use DBI;

# Koha modules used
use C4::Input;
use C4::Biblio;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(
		&getz3950servers
		&z3950servername
		&addz3950queue
		&checkz3950searchdone
	);
}

=head1 NAME

C4::Z3950 - Functions dealing with Z39.50 queries

=head1 SYNOPSIS

  use C4::Z3950;

=head1 DESCRIPTION

This module contains functions for looking up Z39.50 servers, and for
entering Z39.50 lookup requests.

=head1 FUNCTIONS

=over 2

=item getz3950servers

  @servers= &getz3950servers(checked);

Returns the list of declared z3950 servers

C<$checked> should always be true (1) => returns only active servers.
If 0 => returns all servers

=cut

sub getz3950servers {
	my ($checked) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	if ($checked) {
		$sth = $dbh->prepare("select * from z3950servers where checked=1");
	} else {
		$sth = $dbh->prepare("select * from z3950servers");
	}
	my @result;
	while ( my ($host, $port, $db, $userid, $password,$servername) = $sth->fetchrow ) {
		push @result, "$servername/$host\:$port/$db/$userid/$password";
	} # while
	return @result;
}

=item z3950servername

  $name = &z3950servername($dbh, $server_id, $default_name);

Looks up a Z39.50 server by ID number, and returns its full name. If
the server is not found, returns C<$default_name>.

C<$server_id> is the Z39.50 server ID to look up.

C<$dbh> is ignored.

=cut

#'

sub z3950servername {
	# inputs
	my ($srvid,		# server id number
		$default,)=@_;
	# return
	my $longname;
	#----

	my $dbh = C4::Context->dbh;

	my $sti=$dbh->prepare("select name from z3950servers where id=?");

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

=item addz3950queue

  $errmsg = &addz3950queue($query, $type, $request_id, @servers);

Adds a Z39.50 search query for the Z39.50 server to look up.

C<$query> is the term to search for.

C<$type> is the query type, e.g. C<isbn>, C<lccn>, etc.

C<$request_id> is a unique string that will identify this query.

C<@servers> is a list of servers to query (obviously, this can be
given either as an array, or as a list of scalars). Each element may
be either a Z39.50 server ID from the z3950server table of the Koha
database, the string C<DEFAULT> or C<CHECKED>, or a complete server
specification containing a colon.

C<DEFAULT> and C<CHECKED> are synonymous, and refer to those servers
in the z3950servers table whose 'checked' field is set and non-NULL.

Once the query has been submitted to the Z39.50 daemon,
C<&addz3950queue> sends a SIGHUP to the daemon to tell it to process
this new request.

C<&addz3950queue> returns an error message. If it was successful, the
error message is the empty string.

=cut

#'
sub addz3950queue {
	use strict;
	# input
	my (
		$query,		# value to look up
		$type,			# type of value ("isbn", "lccn", "title", "author", "keyword")
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

	# FIXME - Should be configurable, probably in /etc/koha.conf.
	my $pidfile='/var/log/koha/processz3950queue.pid';

	$error="";

	my $dbh = C4::Context->dbh;
	# list of servers: entry can be a fully qualified URL-type entry
	#   or simply just a server ID number.
	foreach $server (@z3950list) {
		if ($server =~ /:/ ) {
			push @serverlist, $server;
		} elsif ($server eq 'DEFAULT' || $server eq 'CHECKED' ) {
			$sth=$dbh->prepare("select host,port,db,userid,password ,name,syntax from z3950servers where checked <> 0 ");
			$sth->execute;
			while ( my ($host, $port, $db, $userid, $password,$servername,$syntax) = $sth->fetchrow ) {
				push @serverlist, "$servername/$host\:$port/$db/$userid/$password/$syntax";
			} # while
		} else {
			$sth=$dbh->prepare("select host,port,db,userid,password,syntax from z3950servers where id=? ");
			$sth->execute($server);
			my ($host, $port, $db, $userid, $password,$syntax) = $sth->fetchrow;
			push @serverlist, "$server/$host\:$port/$db/$userid/$password/$syntax";
		}
	}

	my $serverlist='';

	$serverlist = join("|", @serverlist);
# 	chop $serverlist;

	# FIXME - Is this test supposed to test whether @serverlist is
	# empty? If so, then a) there are better ways to do that in
	# Perl (e.g., "if (@serverlist eq ())"), and b) it doesn't
	# work anyway, since it checks whether $serverlist is composed
	# of one or more spaces, which is never the case, not even
	# when there are 0 or 1 elements in @serverlist.
	if ( $serverlist !~ /^ +$/ ) {
		# Don't allow reinsertion of the same request identifier.
		$sth=$dbh->prepare("select identifier from z3950queue
			where identifier=?");
		$sth->execute($requestid);
		if ( ! $sth->rows) {
			$sth=$dbh->prepare("insert into z3950queue (term,type,servers, identifier) values (?, ?, ?, ?)");
			$sth->execute($query, $type, $serverlist, $requestid);
			if ( -r $pidfile ) {
				# FIXME - Perl is good at opening files. No need to
				# spawn a separate 'cat' process.
				my $pid=`cat $pidfile`;
				chomp $pid;
				# Kill -HUP the Z39.50 daemon to tell it to process
				# this query.
				my $processcount=kill 1, $pid;
				if ($processcount==0) {
					$error.="Z39.50 search daemon error: no process signalled. ";
				}
			} else {
				# FIXME - Error-checking like this should go close
				# to the test.
				$error.="No Z39.50 search daemon running: no file $pidfile. ";
			} # if $pidfile
		} else {
			# FIXME - Error-checking like this should go close
			# to the test.
			$error.="Duplicate request ID $requestid. ";
		} # if rows
	} else {
		# FIXME - Error-checking like this should go close to the
		# test. I.e.,
		#	return "No Z39.50 search servers specified. "
		#		if @serverlist eq ();

		# server list is empty
		$error.="No Z39.50 search servers specified. ";
	} # if serverlist empty

	return $error;

} # sub addz3950queue

=item &checkz3950searchdone

  $numberpending= &	&checkz3950searchdone($random);

Returns the number of pending z3950 requests

C<$random> is the random z3950 query number.

=cut

sub checkz3950searchdone {
	my ($z3950random) = @_;
	my $dbh = C4::Context->dbh;
	# first, check that the deamon already created the requests...
	my $sth = $dbh->prepare("select count(*) from z3950queue,z3950results where z3950queue.id = z3950results.queryid and z3950queue.identifier=?");
	$sth->execute($z3950random);
	my ($result) = $sth->fetchrow;
	if ($result eq 0) { # search not yet begun => should be searches to do !
		return "??";
	}
	# second, count pending requests
	$sth = $dbh->prepare("select count(*) from z3950queue,z3950results where z3950queue.id = z3950results.queryid and z3950results.enddate is null and z3950queue.identifier=?");
	$sth->execute($z3950random);
	($result) = $sth->fetchrow;
	return $result;
}

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
