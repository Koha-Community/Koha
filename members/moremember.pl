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
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Members::Attributes;
use C4::Members::AttributeTypes;
use C4::Dates;
use C4::Reserves;
use C4::Circulation;
use C4::Koha;
use C4::Letters;
use C4::Biblio;
use C4::Reserves;
use C4::Branch; # GetBranchName
use C4::Form::MessagingPreferences;

#use Smart::Comments;
#use Data::Dumper;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}

my $dbh = C4::Context->dbh;

my $input = new CGI;
$debug or $debug = $input->param('debug') || 0;
my $print = $input->param('print');
my $override_limit = $input->param("override_limit") || 0;
my @failedrenews = $input->param('failedrenew');
my @failedreturns = $input->param('failedreturn');
my $error = $input->param('error');
my %renew_failed;
for my $renew (@failedrenews) { $renew_failed{$renew} = 1; }
my %return_failed;
for my $failedret (@failedreturns) { $return_failed{$failedret} = 1; }

my $template_name;

if    ($print eq "page") { $template_name = "members/moremember-print.tmpl";   }
elsif ($print eq "slip") { $template_name = "members/moremember-receipt.tmpl"; }
else {                     $template_name = "members/moremember.tmpl";         }

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
    $template->param (unknowuser => 1);
	output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

# re-reregistration function to automatic calcul of date expiry
if ( $reregistration eq 'y' ) {
	$data->{'dateexpiry'} = ExtendMemberSubscriptionTo( $borrowernumber );
}

my $category_type = $data->{'category_type'};

### $category_type

# in template <TMPL_IF name="I"> => instutitional (A for Adult& C for children) 
$template->param( $data->{'categorycode'} => 1 ); 

$debug and printf STDERR "dates (enrolled,expiry,birthdate) raw: (%s, %s, %s)\n", map {$data->{$_}} qw(dateenrolled dateexpiry dateofbirth);
foreach (qw(dateenrolled dateexpiry dateofbirth)) {
		my $userdate = $data->{$_};
		unless ($userdate) {
			$debug and warn sprintf "Empty \$data{%12s}", $_;
			$data->{$_} = '';
			next;
		}
		$userdate = C4::Dates->new($userdate,'iso')->output('syspref');
		$data->{$_} = $userdate || '';
		$template->param( $_ => $userdate );
}
$data->{'IS_ADULT'} = ( $data->{'categorycode'} ne 'I' );

for (qw(debarred gonenoaddress lost borrowernotes)) {
	 $data->{$_} and $template->param(flagged => 1) and last;
}

$data->{'ethnicity'} = fixEthnicity( $data->{'ethnicity'} );
$data->{ "sex_".$data->{'sex'}."_p" } = 1;

my $catcode;
if ( $category_type eq 'C') {
	if ($data->{'guarantorid'} ne '0' ) {
    	my $data2 = GetMember( $data->{'guarantorid'} ,'borrowernumber');
    	foreach (qw(address city B_address B_city phone mobile zipcode)) {
    	    $data->{$_} = $data2->{$_};
    	}
   }
   my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
   my $cnt = scalar(@$catcodes);

   $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
   $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
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
        push(@guaranteedata,
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
		$template->param(guarantor => 1);
		foreach (qw(borrowernumber cardnumber firstname surname)) {        
			  $template->param("guarantor$_" => $guarantor->{$_});
        }
    }
	if ($category_type eq 'C'){
		$template->param('C' => 1);
	}
}

my %bor;
$bor{'borrowernumber'} = $borrowernumber;

# Converts the branchcode to the branch name
my $samebranch;
if ( C4::Context->preference("IndependantBranches") ) {
    my $userenv = C4::Context->userenv;
    unless ( $userenv->{flags} % 2 == 1 ) {
        $samebranch = ( $data->{'branchcode'} eq $userenv->{branch} );
    }
    $samebranch = 1 if ( $userenv->{flags} % 2 == 1 );
}
my $branchdetail = GetBranchDetail( $data->{'branchcode'});
$data->{'branchname'} = $branchdetail->{branchname};


my ( $total, $accts, $numaccts) = GetMemberAccountRecords( $borrowernumber );
my $lib1 = &GetSortDetails( "Bsort1", $data->{'sort1'} );
my $lib2 = &GetSortDetails( "Bsort2", $data->{'sort2'} );
$template->param( lib1 => $lib1 ) if ($lib1);
$template->param( lib2 => $lib2 ) if ($lib2);

# current issues
#
my $issue = GetPendingIssues($borrowernumber);
my $count = scalar(@$issue);
my $roaddetails = &GetRoadTypeDetails( $data->{'streettype'} );
my $today       = POSIX::strftime("%Y-%m-%d", localtime);	# iso format
my @issuedata;
my $overdues_exist = 0;
my $totalprice = 0;
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my $datedue = $issue->[$i]{'date_due'};
    $issue->[$i]{'date_due'}  = C4::Dates->new($issue->[$i]{'date_due'}, 'iso')->output('syspref');
    $issue->[$i]{'issuedate'} = C4::Dates->new($issue->[$i]{'issuedate'},'iso')->output('syspref');
    my %row = %{ $issue->[$i] };
    $totalprice += $issue->[$i]{'replacementprice'};
    $row{'replacementprice'} = $issue->[$i]{'replacementprice'};
    if ( $datedue lt $today ) {
        $overdues_exist = 1;
        $row{'red'} = 1;
	}

    #find the charge for an item
    my ( $charge, $itemtype ) =
      GetIssuingCharges( $issue->[$i]{'itemnumber'}, $borrowernumber );

    my $itemtypeinfo = getitemtypeinfo($itemtype);
    $row{'itemtype_description'} = $itemtypeinfo->{description};
    $row{'itemtype_image'}       = $itemtypeinfo->{imageurl};

    $row{'charge'} = sprintf( "%.2f", $charge );

	my ( $renewokay,$renewerror ) = CanBookBeRenewed( $borrowernumber, $issue->[$i]{'itemnumber'}, $override_limit );
	$row{'norenew'} = !$renewokay;
	$row{'can_confirm'} = ( !$renewokay && $renewerror ne 'on_reserve' );
	$row{"norenew_reason_$renewerror"} = 1 if $renewerror;
	$row{'renew_failed'}  = $renew_failed{ $issue->[$i]{'itemnumber'} };
	$row{'return_failed'} = $return_failed{$issue->[$i]{'barcode'}};   
    push( @issuedata, \%row );
}

### ###############################################################################
# BUILD HTML
# show all reserves of this borrower, and the position of the reservation ....
if ($borrowernumber) {

    # new op dev
    # now we show the status of the borrower's reservations
    my @borrowerreserv = GetReservesFromBorrowernumber($borrowernumber );
    my @reservloop;
    foreach my $num_res (@borrowerreserv) {
        my %getreserv;
        my $getiteminfo  = GetBiblioFromItemNumber( $num_res->{'itemnumber'} );
        my $itemtypeinfo = getitemtypeinfo( $getiteminfo->{'itemtype'} );
        my ( $transfertwhen, $transfertfrom, $transfertto ) =
            GetTransfers( $num_res->{'itemnumber'} );

        foreach (qw(waiting transfered nottransfered)) {
            $getreserv{$_} = 0;
        }
        $getreserv{reservedate}  = C4::Dates->new($num_res->{'reservedate'},'iso')->output('syspref');
        foreach (qw(biblionumber title author itemcallnumber )) {
            $getreserv{$_} = $getiteminfo->{$_};
        }
        $getreserv{barcodereserv}  = $getiteminfo->{'barcode'};
        $getreserv{itemtype}  = $itemtypeinfo->{'description'};

        # 		check if we have a waitin status for reservations
        if ( $num_res->{'found'} eq 'W' ) {
            $getreserv{color}   = 'reserved';
            $getreserv{waiting} = 1;
        }

        # 		check transfers with the itemnumber foud in th reservation loop
        if ($transfertwhen) {
            $getreserv{color}      = 'transfered';
            $getreserv{transfered} = 1;
            $getreserv{datesent}   = C4::Dates->new($transfertwhen, 'iso')->output('syspref') or die "Cannot get new($transfertwhen, 'iso') from C4::Dates";
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
            my $getbibinfo = GetBiblioData( $num_res->{'biblionumber'} );
            my $getbibtype = getitemtypeinfo( $getbibinfo->{'itemtype'} );
            $getreserv{color}           = 'inwait';
            $getreserv{title}           = $getbibinfo->{'title'};
            $getreserv{nottransfered}   = 0;
            $getreserv{itemtype}        = $getbibtype->{'description'};
            $getreserv{author}          = $getbibinfo->{'author'};
            $getreserv{biblionumber}  = $num_res->{'biblionumber'};	
        }
        $getreserv{waitingposition} = $num_res->{'priority'};

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

# check to see if patron's image exists in the database
# basically this gives us a template var to condition the display of
# patronimage related interface on
my ($picture, $dberror) = GetPatronImage($data->{'cardnumber'});
$template->param( picture => 1 ) if $picture;

my $branch=C4::Context->userenv->{'branch'};

$template->param($data);

if (C4::Context->preference('ExtendedPatronAttributes')) {
    $template->param(ExtendedPatronAttributes => 1);
    $template->param(patron_attributes => C4::Members::Attributes::GetBorrowerAttributes($borrowernumber));
    my @types = C4::Members::AttributeTypes::GetAttributeTypes();
    if (scalar(@types) == 0) {
        $template->param(no_patron_attribute_types => 1);
    }
}

if (C4::Context->preference('EnhancedMessagingPreferences')) {
    C4::Form::MessagingPreferences::set_form_values({ borrowernumber => $borrowernumber }, $template);
    $template->param(messaging_form_inactive => 1);
    $template->param(SMSSendDriver => C4::Context->preference("SMSSendDriver"));
    $template->param(SMSnumber     => defined $data->{'smsalertnumber'} ? $data->{'smsalertnumber'} : $data->{'mobile'});
}

$template->param(
    detailview => 1,
    AllowRenewalLimitOverride => C4::Context->preference("AllowRenewalLimitOverride"),
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    roaddetails     => $roaddetails,
    borrowernumber  => $borrowernumber,
    categoryname    => $data->{'description'},
    reregistration  => $reregistration,
    branch          => $branch,
    totalprice      => sprintf("%.2f", $totalprice),
    totaldue        => sprintf("%.2f", $total),
    totaldue_raw    => $total,
    issueloop       => \@issuedata,
    overdues_exist  => $overdues_exist,
    error           => $error,
    $error          => 1,
    StaffMember     => ($category_type eq 'S'),
    is_child        => ($category_type eq 'C'),
#   reserveloop     => \@reservedata,
    dateformat      => C4::Context->preference("dateformat"),
    "dateformat_" . (C4::Context->preference("dateformat") || '') => 1,
);

output_html_with_http_headers $input, $cookie, $template->output;
