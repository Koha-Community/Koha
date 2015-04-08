#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2007 Tamil s.a.r.l.
#
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

=head1 ysearch.pl


=cut

use Modern::Perl;
use CGI;
use C4::Context;
use C4::Charset;
use C4::Auth qw/check_cookie_auth/;
use JSON qw/ to_json /;

my $input = new CGI;
my $query = $input->param('term');
my $table = $input->param('table');
my $field = $input->param('field');

# Prevent from disclosing data
die() unless ($table eq "biblioitems"); 

binmode STDOUT, ":encoding(UTF-8)";
print $input->header( -type => 'text/plain', -charset => 'UTF-8' );

my ( $auth_status, $sessionID ) = check_cookie_auth( $input->cookie('CGISESSID'), { editcatalogue => '*' } );
if ( $auth_status ne "ok" ) {
    exit 0;
}

my $dbh = C4::Context->dbh;
my $sql = qq(SELECT distinct $field 
             FROM $table 
             WHERE $field LIKE ? OR $field LIKE ? or $field LIKE ?);
$sql .= qq( ORDER BY $field);
my $sth = $dbh->prepare($sql);
$sth->execute("$query%", "% $query%", "%-$query%");

my $a = [];
while ( my $rec = $sth->fetchrow_hashref ) {
    push @$a, { fieldvalue => nsb_clean($rec->{$field}) };
}

print to_json($a);
