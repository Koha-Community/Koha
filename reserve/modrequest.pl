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
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   
        template_name   => "about.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my @reserve_id = $query->param('reserve_id');
my @rank = $query->param('rank-request');
my @biblionumber = $query->param('biblionumber');
my @borrower = $query->param('borrowernumber');
my @branch = $query->param('pickup');
my @itemnumber = $query->param('itemnumber');
my @suspend_until=$query->param('suspend_until');
my $multi_hold = $query->param('multi_hold');
my $biblionumbers = $query->param('biblionumbers');
my $count=@rank;

my $CancelBiblioNumber = $query->param('CancelBiblioNumber');
my $CancelBorrowerNumber = $query->param('CancelBorrowerNumber');
my $CancelItemnumber = $query->param('CancelItemnumber');

# 2 possibilitys : cancel an item reservation, or modify or cancel the queded list

# 1) cancel an item reservation by function ModReserveCancelAll (in reserves.pm)
if ($CancelBorrowerNumber) {
    ModReserveCancelAll($CancelItemnumber, $CancelBorrowerNumber);
    $biblionumber[0] = $CancelBiblioNumber,
}

# 2) Cancel or modify the queue list of reserves (without item linked)
else {
    for (my $i=0;$i<$count;$i++){
        undef $itemnumber[$i] unless $itemnumber[$i] ne '';
        ModReserve({
            rank => $rank[$i],
            reserve_id => $reserve_id[$i],
            branchcode => $branch[$i],
            itemnumber => $itemnumber[$i],
            suspend_until => $suspend_until[$i]
        });
    }
}

my $from=$query->param('from');
$from ||= q{};
if ( $from eq 'borrower'){
    print $query->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrower[0]");
} elsif ( $from eq 'circ'){
    print $query->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrower[0]");
} else {
     my $url = "/cgi-bin/koha/reserve/request.pl?";
     if ($multi_hold) {
         $url .= "multi_hold=1&biblionumbers=$biblionumbers";
     } else {
         $url .= "biblionumber=$biblionumber[0]";
     }
     print $query->redirect($url);
}
