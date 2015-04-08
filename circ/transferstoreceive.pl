#!/usr/bin/perl


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
use C4::Context;
use C4::Output;
use C4::Branch;     # GetBranches
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
my $itemnumber = $input->param('itemnumber');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/transferstoreceive.tt",
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
my $latetransfers;
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
			my $diff = $today - $calcDate;

            if ($today > $calcDate) {
				$latetransfers = 1;
                $getransf{'messcompa'} = 1;
				$getransf{'diff'} = $diff;
            }
            my $gettitle     = GetBiblioFromItemNumber( $num->{'itemnumber'} );
            my $itemtypeinfo = getitemtypeinfo( (C4::Context->preference('item-level_itypes')) ? $gettitle->{'itype'} : $gettitle->{'itemtype'} );

            $getransf{'datetransfer'} = $num->{'datesent'};
            $getransf{'itemtype'} = $itemtypeinfo ->{'description'};
			foreach (qw(title author biblionumber itemnumber barcode homebranch holdingbranch itemcallnumber)) {
            	$getransf{$_} = $gettitle->{$_};
			}

            my $record = GetMarcBiblio($gettitle->{'biblionumber'});
            $getransf{'subtitle'} = GetRecordValue('subtitle', $record, GetFrameworkCode($gettitle->{'biblionumber'}));

            # we check if we have a reserv for this transfer
            my @checkreserv = GetReservesFromItemnumber($num->{'itemnumber'});
            if ( $checkreserv[0] ) {
                my $getborrower = GetMemberDetails( $checkreserv[1] );
                $getransf{'borrowernum'}       = $getborrower->{'borrowernumber'};
                $getransf{'borrowername'}      = $getborrower->{'surname'};
                $getransf{'borrowerfirstname'} = $getborrower->{'firstname'};
                $getransf{'borrowermail'}      = $getborrower->{'emailaddress'} if $getborrower->{'emailaddress'};
                $getransf{'borrowerphone'}     = $getborrower->{'phone'};
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
	TransfersMaxDaysWarning => C4::Context->preference('TransfersMaxDaysWarning'),
	latetransfers => $latetransfers ? 1 : 0,
);

output_html_with_http_headers $input, $cookie, $template->output;

