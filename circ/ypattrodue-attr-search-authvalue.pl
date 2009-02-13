#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

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
use warnings;
use CGI;
use C4::Context;
use C4::Auth qw/check_cookie_auth/;
use C4::Debug;

my $input    = new CGI;
my $query    = $input->param('query');
my $attrcode = $input->path_info || '';
$attrcode =~ s|^/||;

my ( $auth_status, $sessionID ) = check_cookie_auth( $input->cookie('CGISESSID'), { circulate => '*' } );
exit 0 if $auth_status ne "ok";

binmode STDOUT, ":utf8";
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
while ( my $rec = $sth->fetchrow_hashref ) {
    print STDERR ">> attrcode=$attrcode match '$query' ==> $rec->{description} ($rec->{authorised_value})\n" if $debug;
    print "$rec->{description}\t$rec->{authorised_value}\n";
}

