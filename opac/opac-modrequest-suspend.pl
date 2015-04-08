#!/usr/bin/perl

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
use C4::Output;
use C4::Reserves;
use C4::Auth;
my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-account.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

my $suspend       = $query->param('suspend');
my $suspend_until = $query->param('suspend_until') || undef;
my $reserve_id    = $query->param('reserve_id');

if ($reserve_id) {
    ToggleSuspend( $reserve_id, $suspend_until ) if CanReserveBeCanceledFromOpac($reserve_id, $borrowernumber);
}
else {
    SuspendAll(
        borrowernumber => $borrowernumber,
        suspend        => $suspend,
        suspend_until  => $suspend_until,
    );
}

print $query->redirect("/cgi-bin/koha/opac-user.pl#opac-user-holds");
