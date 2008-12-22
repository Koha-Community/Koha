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
use CGI;
use C4::Context;
use C4::Output;
use C4::Branch;
use C4::Auth;
use C4::Dates qw/format_date/;
use C4::Biblio;
use C4::Circulation;
use C4::Members;
use Date::Calc qw(
  Today
  Add_Delta_Days
  Date_to_Days
);

use C4::Koha;
use C4::Reserves;

my $input = new CGI;

my $theme = $input->param('theme');    # only used if allowthemeoverride is set
my $itemnumber = $input->param('itemnumber');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/transferstoreceive.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

# set the userenv branch
my $default = C4::Context->userenv->{'branch'};

# get the all the branches for reference
my $branches = GetBranches();
my @branchesloop;
foreach my $br ( keys %$branches ) {
    my @transferloop;
    my %branchloop;
    my @gettransfers =
      GetTransfersFromTo( $branches->{$br}->{'branchcode'}, $default );

    if (@gettransfers) {
        $branchloop{'branchname'} = $branches->{$br}->{'branchname'};
        $branchloop{'branchcode'} = $branches->{$br}->{'branchcode'};
        foreach my $num (@gettransfers) {
            my %getransf;

            my ( $sent_year, $sent_month, $sent_day ) = split "-",
              $num->{'datesent'};
            $sent_day = ( split " ", $sent_day )[0];
            ( $sent_year, $sent_month, $sent_day ) =
              Add_Delta_Days( $sent_year, $sent_month, $sent_day,
                C4::Context->preference('TransfersMaxDaysWarning'));
            my $calcDate = Date_to_Days( $sent_year, $sent_month, $sent_day );
            my $today    = Date_to_Days(&Today);
            my $warning  = ( $today > $calcDate );

            if ( $warning > 0 ) {
                $getransf{'messcompa'} = 1;
            }
            my $gettitle     = GetBiblioFromItemNumber( $num->{'itemnumber'} );
            my $itemtypeinfo = getitemtypeinfo( $gettitle->{'itemtype'} );

            $getransf{'datetransfer'} = format_date( $num->{'datesent'} );
            $getransf{'itemtype'} = $itemtypeinfo->{'description'};
			foreach (qw(title biblionumber itemnumber barcode homebranch holdingbranch itemcallnumber)) {
            	$getransf{$_} = $gettitle->{$_};
			}

            # 				we check if we have a reserv for this transfer
            my @checkreserv = GetReservesFromItemnumber($num->{'itemnumber'} );
            if ( $checkreserv[0] ) {
                my $getborrower =
                  GetMemberDetails( $checkreserv[1] );
                $getransf{'borrowernum'}  = $getborrower->{'borrowernumber'};
                $getransf{'borrowername'} = $getborrower->{'surname'};
                $getransf{'borrowerfirstname'} = $getborrower->{'firstname'};
                if ( $getborrower->{'emailaddress'} ) {
                    $getransf{'borrowermail'} = $getborrower->{'emailaddress'};
                }
                $getransf{'borrowerphone'} = $getborrower->{'phone'};

            }
            push( @transferloop, \%getransf );
        }

      # 		If we have a return of reservloop we put it in the branchloop sequence
        $branchloop{'reserv'} = \@transferloop;
    }
    push( @branchesloop, \%branchloop ) if %branchloop;
}

$template->param(
    branchesloop => \@branchesloop,
    show_date    => format_date(C4::Dates->today('iso')),
	dateformat    => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $input, $cookie, $template->output;

