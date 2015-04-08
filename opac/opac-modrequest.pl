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

my $reserve_id = $query->param('reserve_id');

if ($reserve_id && $borrowernumber) {
    CancelReserve({ reserve_id => $reserve_id }) if CanReserveBeCanceledFromOpac($reserve_id, $borrowernumber);
}

print $query->redirect("/cgi-bin/koha/opac-user.pl#opac-user-holds");
