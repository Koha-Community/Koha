package C4::Z3950;

# $Id$

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

# Koha modules used
use C4::Context;
use C4::Input;
use C4::Biblio;

#------------------

require Exporter;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

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



1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

#--------------------------------------
##No more deamon to start. Z3950 now handled by ZOOM asynch mode-TG
# $Log$
# Revision 1.12  2006/09/01 22:16:00  tgarip1957
# New XML API
# Event & Net::Z3950 dependency removed
# HTML::Template::Pro dependency added
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
