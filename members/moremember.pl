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

# $Id$

=head1 moremember.pl

 script to do a borrower enquiry/bring up borrower details etc
 Displays all the details about a borrower
 written 20/12/99 by chris@katipo.co.nz
 last modified 21/1/2000 by chris@katipo.co.nz
 modified 31/1/2001 by chris@katipo.co.nz
   to not allow items on request to be renewed

 needs html removed and to use the C4::Output more, but its tricky

=cut

use strict;
use CGI;
use Date::Manip;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Members;
use C4::Date;
use C4::Reserves;
use C4::Circulation;
use C4::Koha;
use C4::Letters;
use C4::Biblio;
use C4::Reserves;
use C4::Branch; # GetBranchName

my $dbh = C4::Context->dbh;

my $input = new CGI;
my $print = $input->param('print');
my $template_name;

if ( $print eq "page" ) {
    $template_name = "members/moremember-print.tmpl";
}
elsif ( $print eq "slip" ) {
    $template_name = "members/moremember-receipt.tmpl";
}
else {
    $template_name = "members/moremember.tmpl";
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => $template_name,
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);
my $borrowernumber = $input->param('borrowernumber');

#start the page and read in includes
my $data           = GetMember( $borrowernumber ,'borrowernumber');
my $reregistration = $input->param('reregistration');

if ( not defined $data ) {
    $template->param (
        unknowuser => 1
    );
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

# re-reregistration function to automatic calcul of date expiry
(
#     $data->{'dateexpiry'} = GetMembeReregistration(
 $data->{'dateexpiry'} = ExtendMemberSubscriptionTo(
        $data->{'categorycode'},
        $borrowernumber, $data->{'dateenrolled'}
    )
) if ( $reregistration eq 'y' );
my $borrowercategory = GetBorrowercategory( $data->{'categorycode'} );
my $category_type = $borrowercategory->{'category_type'};

# in template <TMPL_IF name="I"> => instutitional (A for Adult& C for children) 
$template->param( $data->{'categorycode'} => 1 ); 

$data->{'dateenrolled'} = format_date( $data->{'dateenrolled'} );
$data->{'dateexpiry'}   = format_date( $data->{'dateexpiry'} );
$data->{'dateofbirth'}  = format_date( $data->{'dateofbirth'} );
$data->{'IS_ADULT'}     = ( $data->{'categorycode'} ne 'I' );

if (   $data->{'debarred'}
    || $data->{'gonenoaddress'}
    || $data->{'lost'}
    || $data->{'borrowernotes'} )
{
    $template->param( flagged => 1 );
}

$data->{'ethnicity'} = fixEthnicity( $data->{'ethnicity'} );

$data->{ "sex_".$data->{'sex'}."_p" } = 1;

if ( $category_type eq 'C' and $data->{'guarantorid'} ne '0' ) {
    my $data2 = GetMember( $data->{'guarantorid'} ,'borrowernumber');
    $data->{'address'}   = $data2->{'address'};
    $data->{'city'}      = $data2->{'city'};
    $data->{'B_address'} = $data2->{'B_address'};
    $data->{'B_city'}    = $data2->{'B_city'};
    $data->{'phone'}     = $data2->{'phone'};
    $data->{'mobile'}    = $data2->{'mobile'};
    $data->{'zipcode'}   = $data2->{'zipcode'};
}

if ( $data->{'ethnicity'} || $data->{'ethnotes'} ) {
    $template->param( printethnicityline => 1 );
}
if ( $category_type eq 'A' ) {
    $template->param( isguarantee => 1 );

    # FIXME
    # It looks like the $i is only being returned to handle walking through
    # the array, which is probably better done as a foreach loop.
    #
    my ( $count, $guarantees ) = GetGuarantees( $data->{'borrowernumber'} );
    my @guaranteedata;
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        push(
            @guaranteedata,
            {
                borrowernumber => $guarantees->[$i]->{'borrowernumber'},
                cardnumber     => $guarantees->[$i]->{'cardnumber'},
                name           => $guarantees->[$i]->{'firstname'} . " "
                  . $guarantees->[$i]->{'surname'}
            }
        );
    }
    $template->param( guaranteeloop => \@guaranteedata );
    ( $template->param( adultborrower => 1 ) ) if ( $category_type eq 'A' );

}
else {
    if ($data->{'guarantorid'}){
      my ($guarantor) = GetMember( $data->{'guarantorid'},'biblionumber');
      $template->param( 
              guarantor => 1,
              guarantorborrowernumber => $guarantor->{'borrowernumber'},
              guarantorcardnumber     => $guarantor->{'cardnumber'},
              guarantorfirstname      => $guarantor->{'firstname'},
              guarantorsurname        => $guarantor->{'surname'}
          );
    }
}

#Independant branches management
my $unvalidlibrarian =
  (      ( C4::Context->preference("IndependantBranches") )
      && ( C4::Context->userenv->{flags} != 1 )
      && ( $data->{'branchcode'} ne C4::Context->userenv->{branch} ) );

my %bor;
$bor{'borrowernumber'} = $borrowernumber;

# Converts the branchcode to the branch name
my $samebranch;
if ( C4::Context->preference("IndependantBranches") ) {
    my $userenv = C4::Context->userenv;
    unless ( $userenv->{flags} == 1 ) {
        $samebranch = ( $data->{'branchcode'} eq $userenv->{branch} );
    }
    $samebranch = 1 if ( $userenv->{flags} == 1 );
}

$data->{'branchname'} =
  ( ( GetBranchDetail( $data->{'branchcode'} ) )->{'branchname'} );


my ( $total, $accts, $numaccts) = GetMemberAccountRecords( $borrowernumber );
my $lib1 = &GetSortDetails( "Bsort1", $data->{'sort1'} );
my $lib2 = &GetSortDetails( "Bsort2", $data->{'sort2'} );
( $template->param( lib1 => $lib1 ) ) if ($lib1);
( $template->param( lib2 => $lib2 ) ) if ($lib2);

# current issues
#
my ( $count, $issue ) = GetPendingIssues($borrowernumber);
my $roaddetails = &GetRoadTypeDetails( $data->{'streettype'} );
my $today       = ParseDate('today');
my @issuedata;
my $totalprice = 0;
my $toggle     = 0;
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my $datedue = ParseDate( $issue->[$i]{'date_due'} );
    $issue->[$i]{'date_due'} = format_date( $issue->[$i]{'date_due'} );
    my %row = %{ $issue->[$i] };
    $totalprice += $issue->[$i]{'replacementprice'};
    $row{'replacementprice'} = $issue->[$i]{'replacementprice'};
    if ( $datedue < $today ) {
        $row{'red'} = 1;    #print "<font color=red>";
    }
    $row{toggle} = $toggle++ % 2;

    #find the charge for an item
    my ( $charge, $itemtype ) =
      GetIssuingCharges( $issue->[$i]{'itemnumber'}, $borrowernumber );

    my $itemtypeinfo = getitemtypeinfo($itemtype);
    $row{'itemtype_description'} = $itemtypeinfo->{description};
    $row{'itemtype_image'}       = $itemtypeinfo->{imageurl};

    $row{'charge'} = sprintf( "%.2f", $charge );

    #check item is not reserved
    my ( $restype, $reserves ) = CheckReserves( $issue->[$i]{'itemnumber'} );
    if ($restype) {
        $row{'norenew'} = 1;
    }
    else {
        $row{'norenew'} = 0;
    }
    push( @issuedata, \%row );
}

##################################################################################
# BUILD HTML
# show all reserves of this borrower, and the position of the reservation ....
if ($borrowernumber) {

    # new op dev
    # now we show the status of the borrower's reservations
    my @borrowerreserv = GetReservesFromBorrowernumber($borrowernumber );
    my @reservloop;
    foreach my $num_res (@borrowerreserv) {
        eval{
            scalar @$num_res;
        };
        if($@){
            next;
        }
    
        my %getreserv;
        
        my $getiteminfo  = GetBiblioFromItemNumber( $num_res->{'itemnumber'} );
        my $itemtypeinfo = getitemtypeinfo( $getiteminfo->{'itemtype'} );
        my ( $transfertwhen, $transfertfrom, $transfertto ) =
            GetTransfers( $num_res->{'itemnumber'} );

        $getreserv{waiting}       = 0;
        $getreserv{transfered}    = 0;
        $getreserv{nottransfered} = 0;

        $getreserv{reservedate}    = format_date( $num_res->{'reservedate'} );
        $getreserv{biblionumber}   = $getiteminfo->{'biblionumber'};
        $getreserv{title}          = $getiteminfo->{'title'};
        $getreserv{itemtype}       = $itemtypeinfo->{'description'};
        $getreserv{author}         = $getiteminfo->{'author'};
        $getreserv{barcodereserv}  = $getiteminfo->{'barcode'};
        $getreserv{itemcallnumber} = $getiteminfo->{'itemcallnumber'};

        # 		check if we have a waitin status for reservations
        if ( $num_res->{'found'} eq 'W' ) {
            $getreserv{color}   = 'reserved';
            $getreserv{waiting} = 1;
        }

        # 		check transfers with the itemnumber foud in th reservation loop
        if ($transfertwhen) {
            $getreserv{color}      = 'transfered';
            $getreserv{transfered} = 1;
            $getreserv{datesent}   = format_date($transfertwhen);
            $getreserv{frombranch} = GetBranchName($transfertfrom);
        }

        if ( ( $getiteminfo->{'holdingbranch'} ne $num_res->{'branchcode'} )
            and not $transfertwhen )
        {
            $getreserv{nottransfered}   = 1;
            $getreserv{nottransferedby} =
                GetBranchName( $getiteminfo->{'holdingbranch'} );
        }

# 		if we don't have a reserv on item, we put the biblio infos and the waiting position
        if ( $getiteminfo->{'title'} eq '' ) {
            my $getbibinfo = GetBiblioItemData( $num_res->{'biblionumber'} );
            my $getbibtype = getitemtypeinfo( $getbibinfo->{'itemtype'} );
            $getreserv{color}           = 'inwait';
            $getreserv{title}           = $getbibinfo->{'title'};
            $getreserv{waitingposition} = $num_res->{'priority'};
            $getreserv{nottransfered}   = 0;
            $getreserv{itemtype}        = $getbibtype->{'description'};
            $getreserv{author}          = $getbibinfo->{'author'};
            $getreserv{itemcallnumber}  = '----------';
            $getreserv{biblionumber}  = $num_res->{'biblionumber'};	
        }

        push( @reservloop, \%getreserv );
    }

    # return result to the template
    $template->param( reservloop => \@reservloop );

}

# current alert subscriptions
my $alerts = getalert($borrowernumber);
foreach (@$alerts) {
    $_->{ $_->{type} } = 1;
    $_->{relatedto} = findrelatedto( $_->{type}, $_->{externalid} );
}
my $picture;
my $htdocs = C4::Context->config('intrahtdocs');
$picture = "/borrowerimages/" . $borrowernumber . ".jpg";
if ( -e $htdocs . "$picture" ) {
    $template->param( picture => $picture );
}
my $branch=C4::Context->userenv->{'branch'};

$template->param($data);

$template->param(
    roaddetails      => $roaddetails,
    borrowernumber   => $borrowernumber,
    reregistration   => $reregistration,
    branch	     => $branch,	
    totalprice       => sprintf( "%.2f", $totalprice ),
    totaldue         => sprintf( "%.2f", $total ),
    issueloop        => \@issuedata,
    unvalidlibrarian => $unvalidlibrarian,
    
    # 		 reserveloop     => \@reservedata,
);

output_html_with_http_headers $input, $cookie, $template->output;
