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
use C4::Input;
use C4::Biblio;

#------------------

require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::Z3950 - Functions dealing with Z39.50 queries

=head1 SYNOPSIS

  use C4::Z3950;

=head1 DESCRIPTION

This module contains functions for looking up Z39.50 servers, and for
entering Z39.50 lookup requests.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
	&getz3950servers
	&z3950servername
	&addz3950queue
	&checkz3950searchdone
);

#------------------------------------------------
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
				warn "PID : $pid";
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

Koha Developement team <info@koha.org>

=cut

#--------------------------------------
# Revision 1.14  2007/03/09 14:31:47  tipaul
# rel_3_0 moved to HEAD
#
# Revision 1.10.10.1  2006/12/22 15:09:54  toins
# removing C4::Database;
#
# Revision 1.10  2003/10/01 15:08:14  tipaul
# fix fog bug #622 : processz3950queue fails
#
# Revision 1.9  2003/04/29 16:50:51  tipaul
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
# Revision 1.8  2003/04/29 08:09:45  tipaul
# z3950 support is coming...
# * adding a syntax column in z3950 table = this column will say wether the z3950 must be called with PerferedRecordsyntax => USMARC or PerferedRecordsyntax => UNIMARC. I tried some french UNIMARC z3950 servers, and some only send USMARC, some only UNIMARC, some can answer with both.
# Note this is a 1st draft. More to follow (today ? I hope).
#
# Revision 1.7  2003/02/19 01:01:06  wolfpac444
# Removed the unecessary $dbh argument from being passed.
# Resolved a few minor FIXMEs.
#
# Revision 1.6  2002/10/13 08:30:53  arensb
# Deleted unused variables.
# Removed trailing whitespace.
#
# Revision 1.5  2002/10/13 06:13:23  arensb
# Removed bogus #! line (this isn't a script!)
# Removed unused global variables.
# Added POD.
# Added some explanatory comments.
# Added some FIXME comments.
#
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
