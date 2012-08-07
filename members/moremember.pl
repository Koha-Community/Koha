#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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
#use warnings; FIXME - Bug 2505
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
use C4::Overdues qw/CheckBorrowerDebarred/;
use C4::Form::MessagingPreferences;
use List::MoreUtils qw/uniq/;
use C4::Members::Attributes qw(GetBorrowerAttributes);

#use Smart::Comments;
#use Data::Dumper;
use DateTime;
use Koha::DateUtils;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}

my $dbh = C4::Context->dbh;

my $input = CGI->new;
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
my $quickslip = 0;

my $flagsrequired;
if ($print eq "page") {
    $template_name = "members/moremember-print.tmpl";
    $flagsrequired = { borrowers => 1 };
} elsif ($print eq "slip") {
    $template_name = "members/moremember-receipt.tmpl";
    # circ staff who process checkouts but can't edit
    # patrons still need to be able to print receipts
    $flagsrequired =  { circulate => "circulate_remaining_permissions" };
} elsif ($print eq "qslip") {
    $template_name = "members/moremember-receipt.tmpl";
    $quickslip = 1;
    $flagsrequired =  { circulate => "circulate_remaining_permissions" };
} elsif ($print eq "brief") {
    $template_name = "members/moremember-brief.tmpl";
    $flagsrequired = { borrowers => 1 };
} else {
    $template_name = "members/moremember.tmpl";
    $flagsrequired = { borrowers => 1 };
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => $template_name,
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => $flagsrequired,
        debug           => 1,
    }
);
my $borrowernumber = $input->param('borrowernumber');

#start the page and read in includes
my $data           = GetMember( 'borrowernumber' => $borrowernumber );
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

for (qw(gonenoaddress lost borrowernotes)) {
	 $data->{$_} and $template->param(flagged => 1) and last;
}

my $debar = CheckBorrowerDebarred($borrowernumber);
if ($debar) {
    $template->param( 'userdebarred' => 1, 'flagged' => 1 );
    if ( $debar ne "9999-12-31" ) {
        $template->param( 'userdebarreddate' => C4::Dates::format_date($debar) );
        $template->param( 'debarredcomment'  => $data->{debarredcomment} );
    }
}

$data->{'ethnicity'} = fixEthnicity( $data->{'ethnicity'} );
$data->{ "sex_".$data->{'sex'}."_p" } = 1;

my $catcode;
if ( $category_type eq 'C') {
   my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
   my $cnt = scalar(@$catcodes);

   $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
   $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
}


if ( $data->{'ethnicity'} || $data->{'ethnotes'} ) {
    $template->param( printethnicityline => 1 );
}
if ( $category_type eq 'A' || $category_type eq 'I') {
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
    ( $template->param( adultborrower => 1 ) ) if ( $category_type eq 'A' || $category_type eq 'I' );
}
else {
    if ($data->{'guarantorid'}){
	    my ($guarantor) = GetMember( 'borrowernumber' =>$data->{'guarantorid'});
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
}else{
    $samebranch = 1;
}
my $branchdetail = GetBranchDetail( $data->{'branchcode'});
@{$data}{keys %$branchdetail} = values %$branchdetail; # merge in all branch columns

my ( $total, $accts, $numaccts) = GetMemberAccountRecords( $borrowernumber );
my $lib1 = &GetSortDetails( "Bsort1", $data->{'sort1'} );
my $lib2 = &GetSortDetails( "Bsort2", $data->{'sort2'} );
$template->param( lib1 => $lib1 ) if ($lib1);
$template->param( lib2 => $lib2 ) if ($lib2);

# Show OPAC privacy preference is system preference is set
if ( C4::Context->preference('OPACPrivacy') ) {
    $template->param( OPACPrivacy => 1);
    $template->param( "privacy".$data->{'privacy'} => 1);
}

# current issues
#
my @borrowernumbers = GetMemberRelatives($borrowernumber);
my $issue       = GetPendingIssues($borrowernumber);
my $relissue    = [];
if ( @borrowernumbers ) {
    $relissue    = GetPendingIssues(@borrowernumbers);
}
my $roaddetails = &GetRoadTypeDetails( $data->{'streettype'} );
my $today       = DateTime->now( time_zone => C4::Context->tz);
$today->truncate(to => 'day');
my @borrowers_with_issues;
my $overdues_exist = 0;
my $totalprice = 0;

my @issuedata = build_issue_data($issue);
my @relissuedata = build_issue_data($relissue);


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
        $getreserv{suspend} = $num_res->{'suspend'};
        $getreserv{suspend_until} = $num_res->{'suspend_until'};

        push( @reservloop, \%getreserv );
    }

    # return result to the template
    $template->param( reservloop => \@reservloop,
        countreserv => scalar @reservloop,
	 );
}

# current alert subscriptions
my $alerts = getalert($borrowernumber);
foreach (@$alerts) {
    $_->{ $_->{type} } = 1;
    $_->{relatedto} = findrelatedto( $_->{type}, $_->{externalid} );
}

my $candeleteuser;
my $userenv = C4::Context->userenv;
if($userenv->{flags} % 2 == 1){
    $candeleteuser = 1;
}elsif ( C4::Context->preference("IndependantBranches") ) {
    $candeleteuser = ( $data->{'branchcode'} eq $userenv->{branch} );
}else{
    if( C4::Auth::getuserflags( $userenv->{flags},$userenv->{number})->{borrowers} ) {
        $candeleteuser = 1;
    }else{
        $candeleteuser = 0;
    }
}

# check to see if patron's image exists in the database
# basically this gives us a template var to condition the display of
# patronimage related interface on
my ($picture, $dberror) = GetPatronImage($data->{'cardnumber'});
$template->param( picture => 1 ) if $picture;

my $branch=C4::Context->userenv->{'branch'};

$template->param(%$data);

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber);
    my @classes = uniq( map {$_->{class}} @$attributes );
    @classes = sort @classes;

    my @attributes_loop;
    for my $class (@classes) {
        my @items;
        for my $attr (@$attributes) {
            push @items, $attr if $attr->{class} eq $class
        }
        my $lib = GetAuthorisedValueByCode( 'PA_CLASS', $class ) || $class;
        push @attributes_loop, {
            class => $class,
            items => \@items,
            lib   => $lib,
        };
    }

    $template->param(
        ExtendedPatronAttributes => 1,
        attributes_loop => \@attributes_loop
    );

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
    $template->param(TalkingTechItivaPhone => C4::Context->preference("TalkingTechItivaPhoneNotification"));
}

# in template <TMPL_IF name="I"> => instutitional (A for Adult, C for children) 
$template->param( $data->{'categorycode'} => 1 ); 
$template->param(
    detailview => 1,
    AllowRenewalLimitOverride => C4::Context->preference("AllowRenewalLimitOverride"),
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    CANDELETEUSER    => $candeleteuser,
    roaddetails     => $roaddetails,
    borrowernumber  => $borrowernumber,
    othernames      => $data->{'othernames'},
    categoryname    => $data->{'description'},
    reregistration  => $reregistration,
    branch          => $branch,
    todaysdate      => C4::Dates->today(),
    totalprice      => sprintf("%.2f", $totalprice),
    totaldue        => sprintf("%.2f", $total),
    totaldue_raw    => $total,
    issueloop       => @issuedata,
    relissueloop    => @relissuedata,
    overdues_exist  => $overdues_exist,
    error           => $error,
    StaffMember     => ($category_type eq 'S'),
    is_child        => ($category_type eq 'C'),
#   reserveloop     => \@reservedata,
    dateformat      => C4::Context->preference("dateformat"),
    "dateformat_" . (C4::Context->preference("dateformat") || '') => 1,
    samebranch     => $samebranch,
    quickslip		  => $quickslip,
    activeBorrowerRelationship => (C4::Context->preference('borrowerRelationship') ne ''),
    AutoResumeSuspendedHolds => C4::Context->preference('AutoResumeSuspendedHolds'),
    SuspendHoldsIntranet => C4::Context->preference('SuspendHoldsIntranet'),
);
$template->param( $error => 1 ) if $error;

output_html_with_http_headers $input, $cookie, $template->output;

sub build_issue_data {
    my $issues = shift;

    my $localissue;

    foreach my $issue ( @{$issues} ) {

        # Getting borrower details
        my $memberdetails = GetMemberDetails( $issue->{borrowernumber} );
        $issue->{borrowername} =
          $memberdetails->{firstname} . ' ' . $memberdetails->{surname};
        $issue->{cardnumber} = $memberdetails->{cardnumber};
        my $issuedate;
        if ($issue->{issuedate} ) {
           $issuedate = $issue->{issuedate}->clone();
        }

        $issue->{date_due}  = output_pref( $issue->{date_due} );
        $issue->{issuedate} = output_pref( $issue->{issuedate} ) if defined $issue->{issuedate};
        my $biblionumber = $issue->{biblionumber};
        $issue->{issuingbranchname} = GetBranchName($issue->{branchcode});
        my %row          = %{$issue};
        $totalprice += $issue->{replacementprice};

        # item lost, damaged loops
        if ( $row{'itemlost'} ) {
            my $fw       = GetFrameworkCode( $issue->{biblionumber} );
            my $category = GetAuthValCode( 'items.itemlost', $fw );
            my $lostdbh  = C4::Context->dbh;
            my $sth      = $lostdbh->prepare(
"select lib from authorised_values where category=? and authorised_value =? "
            );
            $sth->execute( $category, $row{'itemlost'} );
            my $loststat = $sth->fetchrow;
            if ($loststat) {
                $row{'itemlost'} = $loststat;
            }
        }
        if ( $row{'damaged'} ) {
            my $fw         = GetFrameworkCode( $issue->{biblionumber} );
            my $category   = GetAuthValCode( 'items.damaged', $fw );
            my $damageddbh = C4::Context->dbh;
            my $sth        = $damageddbh->prepare(
"select lib from authorised_values where category=? and authorised_value =? "
            );
            $sth->execute( $category, $row{'damaged'} );
            my $damagedstat = $sth->fetchrow;
            if ($damagedstat) {
                $row{'itemdamaged'} = $damagedstat;
            }
        }

        # end lost, damaged
        if ( $issue->{overdue} ) {
            $overdues_exist = 1;
            $row{red} = 1;
        }
        if ($issuedate) {
            $issuedate->truncate( to => 'day' );
            if ( DateTime->compare( $issuedate, $today ) == 0 ) {
                $row{today} = 1;
            }
        }

        #find the charge for an item
        my ( $charge, $itemtype ) =
          GetIssuingCharges( $issue->{itemnumber}, $borrowernumber );

        my $itemtypeinfo = getitemtypeinfo($itemtype);
        $row{'itemtype_description'} = $itemtypeinfo->{description};
        $row{'itemtype_image'}       = $itemtypeinfo->{imageurl};

        $row{'charge'} = sprintf( "%.2f", $charge );

        my ( $renewokay, $renewerror ) =
          CanBookBeRenewed( $borrowernumber, $issue->{itemnumber},
            $override_limit );
        $row{'norenew'} = !$renewokay;
        $row{'can_confirm'} = ( !$renewokay && $renewerror ne 'on_reserve' );
        $row{"norenew_reason_$renewerror"} = 1 if $renewerror;
        $row{renew_failed}  = $renew_failed{ $issue->{itemnumber} };
        $row{return_failed} = $return_failed{ $issue->{barcode} };
        push( @{$localissue}, \%row );
    }
    return $localissue;
}
