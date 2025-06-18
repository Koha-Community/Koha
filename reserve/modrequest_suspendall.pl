#!/usr/bin/perl

#script to modify reserves/requests
#written 2/1/00 by chris@katipo.oc.nz
#last update 27/1/2000 by chris@katipo.co.nz

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Output;
use C4::Reserves qw( SuspendAll );
use C4::Auth     qw( checkauth );

my $query = CGI->new;

checkauth( $query, 0, { reserveforothers => '*' }, 'intranet' );

my $op             = $query->param('op') || q{};
my $borrowernumber = $query->param('borrowernumber');
my $suspend        = $query->param('suspend');
my $suspend_until  = $query->param('suspend_until');

if ( $op eq 'cud-suspendall' || $op eq 'cud-unsuspendall' ) {
    SuspendAll( borrowernumber => $borrowernumber, suspend_until => $suspend_until, suspend => $suspend );
}

my $from = $query->param('from');
$from ||= q{};
if ( $from eq 'borrower' ) {
    print $query->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
} elsif ( $from eq 'circ' ) {
    print $query->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
} else {
    print $query->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
}
