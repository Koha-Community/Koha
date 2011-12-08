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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 ysearch.pl


=cut

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::Members;
use C4::Auth qw/check_cookie_auth/;

my $input   = new CGI;
my $query   = $input->param('query');

binmode STDOUT, ":encoding(UTF-8)";
print $input->header(-type => 'text/plain', -charset => 'UTF-8');

my ($auth_status, $sessionID) = check_cookie_auth($input->cookie('CGISESSID'), { circulate => '*' });
if ($auth_status ne "ok") {
    exit 0;
}

print map $_->{surname} . ", " . $_->{firstname} . "\t" .
          $_->{cardnumber} . "\t" .
          $_->{address} . "\t" .
          $_->{city} . "\t" .
          $_->{zipcode} . "\t" .
          $_->{country} .
          "\n",
          @{ Search($query, [qw(surname firstname cardnumber)], [10], [qw(surname firstname cardnumber address city zipcode country)]) };
