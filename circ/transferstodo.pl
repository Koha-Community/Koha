#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
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

use strict;
use C4::Context;
use C4::Output;
use CGI;
use C4::Branch; # GetBranches
use C4::Auth;
use C4::Dates qw/format_date/;
use C4::Circulation;
use C4::Reserves;
use C4::Members;
use Date::Calc qw(
  Today
  Add_Delta_Days
  Date_to_Days
);
use C4::Koha;
use C4::Biblio;
use C4::Items;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/transferstodo.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 1 },
        debug           => 1,
    }
);

# set the userenv branch
my $default = C4::Context->userenv->{'branch'};

my $item = $input->param('itemnumber');
my $fbr  = $input->param('fbr');
my $tbr  = $input->param('tbr');

# If we have a return of the form dotransfer, we launch the subroutine dotransfer
if ($item) {
    C4::Circulation::Circ2::ModItemTransfer( $item, $fbr, $tbr );
}

# get the all the branches for reference
my $branches = GetBranches();

my @branchesloop;
foreach my $br ( keys %$branches ) {
    my @reservloop;
    my %branchloop;
    my @getreserves =
      GetReservesToBranch( $branches->{$br}->{'branchcode'} );
    if (@getreserves) {
        $branchloop{'branchname'} = $branches->{$br}->{'branchname'};
        $branchloop{'branchcode'} = $branches->{$br}->{'branchcode'};
        foreach my $num (@getreserves) {
            my %getreserv;
            my $gettitle     = GetBiblioFromItemNumber( $num->{'itemnumber'} );
#             use Data::Dumper;
#             warn Dumper($gettitle);
            my $itemtypeinfo = getitemtypeinfo( $gettitle->{'itemtype'} );
            if ( $gettitle->{'holdingbranch'} eq $default ) {
                my $getborrower =
                  GetMemberDetails( $num->{'borrowernumber'} );
                $getreserv{'reservedate'} =
                  format_date( $num->{'reservedate'} );
                my ( $reserve_year, $reserve_month, $reserve_day ) = split /-/,
                  $num->{'reservedate'};
                ( $reserve_year, $reserve_month, $reserve_day ) =
                  Add_Delta_Days( $reserve_year, $reserve_month, $reserve_day,
                    C4::Context->preference('ReservesMaxPickUpDelay'));
                my $calcDate =
                  Date_to_Days( $reserve_year, $reserve_month, $reserve_day );
                my $today   = Date_to_Days(&Today);
                my $warning = ( $today > $calcDate );

                if ( $warning > 0 ) {
                    $getreserv{'messcompa'} = 1;
                }
                $getreserv{'title'}          = $gettitle->{'title'};
                $getreserv{'biblionumber'}   = $gettitle->{'biblionumber'};
                $getreserv{'itemnumber'}     = $gettitle->{'itemnumber'};
                $getreserv{'barcode'}        = $gettitle->{'barcode'};
                $getreserv{'itemtype'}       = $itemtypeinfo->{'description'};
                $getreserv{'holdingbranch'}  = $gettitle->{'holdingbranch'};
                $getreserv{'itemcallnumber'} = $gettitle->{'itemcallnumber'};
                $getreserv{'borrowernum'}    = $getborrower->{'borrowernumber'};
                $getreserv{'borrowername'}   = $getborrower->{'surname'};
                $getreserv{'borrowerfirstname'} = $getborrower->{'firstname'};
                $getreserv{'borrowermail'} = $getborrower->{'emailaddress'};
                $getreserv{'borrowerphone'} = $getborrower->{'phone'};
                push( @reservloop, \%getreserv );
            }
        }

      # 		If we have a return of reservloop we put it in the branchloop sequence
        if (@reservloop) {
            $branchloop{'reserv'} = \@reservloop;
        }
        # 		else, we unset the value of the branchcode .
        else {
            $branchloop{'branchcode'} = 0;
        }
    }
    push( @branchesloop, \%branchloop ) if %branchloop;
}

$template->param(
    branchesloop => \@branchesloop,
    show_date    => format_date(C4::Dates->today('iso')),
	dateformat    => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $input, $cookie, $template->output;
