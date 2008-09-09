#!/usr/bin/perl

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
require Exporter;
use CGI;
use C4::Auth;
use C4::Dates qw/format_date/;
use C4::Koha;
use C4::Serials;    #uses getsubscriptionfrom biblionumber
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Circulation;
use C4::Branch;
use C4::Reserves;
use C4::Members;
use C4::Serials;
use C4::XISBN qw(get_xisbns get_biblionumber_from_isbn get_biblio_from_xisbn);
use C4::Amazon;

# use Smart::Comments;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/detail.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

my $biblionumber = $query->param('biblionumber');
my $fw = GetFrameworkCode($biblionumber);

## get notes and subjects from MARC record
my $marcflavour      = C4::Context->preference("marcflavour");
my $record           = GetMarcBiblio($biblionumber);

unless (defined($record)) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
	exit;
}

my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );
my $marcseriesarray  = GetMarcSeries($record,$marcflavour);
my $marcurlsarray    = GetMarcUrls    ($record,$marcflavour);
my $subtitle         = C4::Biblio::get_koha_field_from_marc('bibliosubtitle', 'subtitle', $record, '');

# Get Branches, Itemtypes and Locations
my $branches = GetBranches();
my $itemtypes = GetItemTypes();

# FIXME: move this to a pm, check waiting status for holds
my $dbh = C4::Context->dbh;

# change back when ive fixed request.pl
my @items = &GetItemsInfo( $biblionumber, 'intra' );
my $dat = &GetBiblioData($biblionumber);

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       = GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );
my @subs;
$dat->{'serial'}=1 if $subscriptionsnumber;
foreach my $subscription (@subscriptions) {
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};
	$cell{branchcode}        = $subscription->{branchcode};
	$cell{hasalert}          = $subscription->{hasalert};
    #get the three latest serials.
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, 3 );
    push @subs, \%cell;
}
$dat->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtypes->{ $dat->{itemtype} }{imageurl} );
$dat->{'count'} = scalar @items;
my $shelflocations = GetKohaAuthorisedValues('items.location', $fw);
my $collections    = GetKohaAuthorisedValues('items.ccode'   , $fw);
my (@itemloop, %itemfields);
my $norequests = 1;
foreach my $item (@items) {

    # can place holds defaults to yes
    $norequests = 0 unless ( ( $item->{'notforloan'} > 0 ) || ( $item->{'itemnotforloan'} > 0 ) );

    # format some item fields for display
    $item->{ $item->{'publictype'} } = 1;
    $item->{imageurl} = getitemtypeimagelocation( 'intranet', $itemtypes->{ $item->{itype} }{imageurl} );
	foreach (qw(datedue datelastseen onloan)) {
		$item->{$_} = format_date($item->{$_});
	}
    # item damaged, lost, withdrawn loops
    $item->{itemlostloop}= GetAuthorisedValues(GetAuthValCode('items.itemlost',$fw),$item->{itemlost}) if GetAuthValCode('items.itemlost',$fw);
    if ($item->{damaged}) {
        $item->{itemdamagedloop}= GetAuthorisedValues(GetAuthValCode('items.damaged',$fw),$item->{damaged}) if GetAuthValCode('items.damaged',$fw);
    }
    #get shelf location and collection code description if they are authorised value.
	my $shelfcode= $item->{'location'};
	$item->{'location'} = $shelflocations->{$shelfcode} if(defined($shelflocations) && exists($shelflocations->{$shelfcode})); 
	my $ccode= $item->{'ccode'};
	$item->{'ccode'} = $collections->{$ccode} if(defined($collections) && exists($collections->{$ccode})); 
	foreach (qw(ccode enumchron copynumber)) {
		$itemfields{$_} = 1 if($item->{$_});
	}

    # checking for holds
    my ($reservedate,$reservedfor,$expectedAt) = GetReservesFromItemnumber($item->{itemnumber});
    my $ItemBorrowerReserveInfo = GetMemberDetails( $reservedfor, 0);

    if ( defined $reservedate ) {
        $item->{backgroundcolor} = 'reserved';
        $item->{reservedate}     = format_date($reservedate);
        $item->{ReservedForBorrowernumber}     = $reservedfor;
        $item->{ReservedForSurname}     = $ItemBorrowerReserveInfo->{'surname'};
        $item->{ReservedForFirstname}   = $ItemBorrowerReserveInfo->{'firstname'};
        $item->{ExpectedAtLibrary}     = $branches->{$expectedAt}{branchname};
    }

	# Check the transit status
    my ( $transfertwhen, $transfertfrom, $transfertto ) = GetTransfers($item->{itemnumber});
    if ( $transfertwhen ne '' ) {
        $item->{transfertwhen} = format_date($transfertwhen);
        $item->{transfertfrom} = $branches->{$transfertfrom}{branchname};
        $item->{transfertto}   = $branches->{$transfertto}{branchname};
        $item->{nocancel} = 1;
    }

    # FIXME: move this to a pm, check waiting status for holds
    my $sth2 = $dbh->prepare("SELECT * FROM reserves WHERE borrowernumber=? AND itemnumber=? AND found='W'");
    $sth2->execute($item->{ReservedForBorrowernumber},$item->{itemnumber});
    while (my $wait_hashref = $sth2->fetchrow_hashref) {
        $item->{waitingdate} = format_date($wait_hashref->{waitingdate});
    }

    push @itemloop, $item;
}

$template->param( norequests => $norequests );
$template->param(
	MARCNOTES   => $marcnotesarray,
	MARCSUBJCTS => $marcsubjctsarray,
	MARCAUTHORS => $marcauthorsarray,
	MARCSERIES  => $marcseriesarray,
	MARCURLS => $marcurlsarray,
	subtitle    => $subtitle,
	itemdata_ccode      => $itemfields{ccode},
	itemdata_enumchron  => $itemfields{enumchron},
	itemdata_copynumber => $itemfields{copynumber},
	volinfo				=> $itemfields{enumchron} || $dat->{'serial'} ,
);

my @results = ( $dat, );
foreach ( keys %{$dat} ) {
    $template->param( "$_" => $dat->{$_} . "" );
}

$template->param(
    itemloop        => \@itemloop,
    biblionumber        => $biblionumber,
    detailview => 1,
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
    subscriptiontitle   => $dat->{title},
);

# $debug and $template->param(debug_display => 1);

# XISBN Stuff
my $xisbn=$dat->{'isbn'};
$xisbn =~ /(\d*[X]*)/;
$template->param(amazonisbn => $1);		# FIXME: so it is OK if the ISBN = 'XXXXX' ?
if (C4::Context->preference("FRBRizeEditions")==1) {
    eval {
        $template->param(
            xisbn => $xisbn,
            XISBNS => get_xisbns($xisbn)
        );
    };
    if ($@) { warn "XISBN Failed $@"; }
}
if ( C4::Context->preference("AmazonContent") == 1 ) {
    my $similar_products_exist;
    my $amazon_details = &get_amazon_details( $xisbn );
    my $item_attributes = \%{$amazon_details->{Items}->{Item}->{ItemAttributes}};
    my $customer_reviews = \@{$amazon_details->{Items}->{Item}->{CustomerReviews}->{Review}};
    my @similar_products;
    for my $similar_product (@{$amazon_details->{Items}->{Item}->{SimilarProducts}->{SimilarProduct}}) {
        # do we have any of these isbns in our collection?
        my $similar_biblionumbers = get_biblionumber_from_isbn($similar_product->{ASIN});
        # verify that there is at least one similar item
		if (scalar(@$similar_biblionumbers)){            
			$similar_products_exist++ if ($similar_biblionumbers && $similar_biblionumbers->[0]);
            push @similar_products, +{ similar_biblionumbers => $similar_biblionumbers, title => $similar_product->{Title}, ASIN => $similar_product->{ASIN}  };
        }
    }
    my $editorial_reviews = \@{$amazon_details->{Items}->{Item}->{EditorialReviews}->{EditorialReview}};
    my $average_rating = $amazon_details->{Items}->{Item}->{CustomerReviews}->{AverageRating};
    $template->param( AmazonSimilarItems => $similar_products_exist );
    $template->param( amazon_average_rating => $average_rating * 20);
    $template->param( AMAZON_CUSTOMER_REVIEWS    => $customer_reviews );
    $template->param( AMAZON_SIMILAR_PRODUCTS => \@similar_products );
    $template->param( AMAZON_EDITORIAL_REVIEWS    => $editorial_reviews );
}
output_html_with_http_headers $query, $cookie, $template->output;
