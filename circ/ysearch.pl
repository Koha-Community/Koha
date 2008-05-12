#!/usr/bin/perl

# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# Copyright 2007 Tamil s.a.r.l.
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

=head1 ysearch.pl


=cut

use strict;
use CGI;
use C4::Context;
use C4::Auth qw/check_cookie_auth/;

my $input   = new CGI;
my $query   = $input->param('query');

print $input->header(-type => 'text/plain', -charset => 'UTF-8');

my ($auth_status, $sessionID) = check_cookie_auth($input->cookie('CGISESSID'), { circulate => '*' });
if ($auth_status ne "ok") {
    exit 0;
}

my $dbh = C4::Context->dbh;
my $sql = qq(SELECT surname, firstname, cardnumber, address, city, zipcode 
             FROM borrowers 
             WHERE surname LIKE ?
             OR firstname LIKE ?
             ORDER BY surname, firstname);
            #"OR cardnumber LIKE '" . $query . "%' " . 
my $sth = $dbh->prepare( $sql );
$sth->execute("$query%", "$query%");
while ( my $rec = $sth->fetchrow_hashref ) {
    print $rec->{surname} . ", " . $rec->{firstname} . "\t" .
          $rec->{cardnumber} . "\t" .
          $rec->{address} . "\t" .
          $rec->{city} . "\t" .
          $rec->{zip} .
          "\n";
}
