#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2007 Tamil s.a.r.l.
# Parts copyright 2010-2012 Athens County Public Libraries
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

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::Members;
use C4::Auth qw/check_cookie_auth/;

my $input   = new CGI;
my $query   = $input->param('term');

binmode STDOUT, ":encoding(UTF-8)";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');

my ($auth_status, $sessionID) = check_cookie_auth($input->cookie('CGISESSID'), { circulate => '*' });
if ($auth_status ne "ok") {
    exit 0;
}

my $dbh = C4::Context->dbh;
my $sql = q(
    SELECT borrowernumber, surname, firstname, cardnumber, address, city, zipcode, country
    FROM borrowers
    WHERE ( surname LIKE ?
        OR firstname LIKE ?
        OR cardnumber LIKE ? )
);
if (   C4::Context->preference("IndependentBranches")
    && C4::Context->userenv
    && !C4::Context->IsSuperLibrarian()
    && C4::Context->userenv->{'branch'} )
{
    $sql .= " AND borrowers.branchcode ="
      . $dbh->quote( C4::Context->userenv->{'branch'} );
}

$sql    .= q( ORDER BY surname, firstname LIMIT 10);
my $sth = $dbh->prepare( $sql );
$sth->execute("$query%", "$query%", "$query%");

print "[";
my $i = 0;
while ( my $rec = $sth->fetchrow_hashref ) {
    if($i > 0){ print ","; }
    print "{\"borrowernumber\":\"" . $rec->{borrowernumber} . "\",\"" .
          "surname\":\"".$rec->{surname} . "\",\"" .
          "firstname\":\"".$rec->{firstname} . "\",\"" .
          "cardnumber\":\"".$rec->{cardnumber} . "\",\"" .
          "address\":\"".$rec->{address} . "\",\"" .
          "city\":\"".$rec->{city} . "\",\"" .
          "zipcode\":\"".$rec->{zipcode} . "\",\"" .
          "country\":\"".$rec->{country} . "\"" .
          "}";
    $i++;
}
print "]";
