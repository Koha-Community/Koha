#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Parts copyright 2012 Athens County Public Libraries
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Auth qw/check_cookie_auth/;
use C4::Debug;

my $input    = new CGI;
my $query    = $input->param('term');
my $attrcode = $input->path_info || '';
$attrcode =~ s|^/||;

my ( $auth_status, $sessionID ) = check_cookie_auth( $input->cookie('CGISESSID'), { circulate => '*' } );
exit 0 if $auth_status ne "ok";

binmode STDOUT, ":encoding(UTF-8)";
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );

print STDERR ">> CALLING $0 (attrcode=$attrcode, query=$query)\n" if $debug;

my $dbh = C4::Context->dbh;
my $sql = qq(SELECT authorised_value, lib description
		FROM borrower_attribute_types b, authorised_values v
		WHERE b.code=?
			AND b.authorised_value_category = v.category
			AND v.lib like ?);
my $sth = $dbh->prepare($sql);
$sth->execute( $attrcode, "$query%" );

print "[";
my $i = 0;
while ( my $rec = $sth->fetchrow_hashref ) {
    print STDERR ">> attrcode=$attrcode match '$query' ==> $rec->{description} ($rec->{authorised_value})\n" if $debug;
    print "{\"description\":\"" . $rec->{description} . "\",\"" .
    "authorised_value\":\"" . $rec->{authorised_value} . "\"" .
    "}";
    $i++;
}
print "]";