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


use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Branch;
use C4::Koha;
use C4::Serials;    #uses getsubscriptionfrom biblionumber
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Circulation;
use C4::Tags qw(get_tags);
use C4::Dates qw/format_date/;
use C4::XISBN qw(get_xisbns get_biblionumber_from_isbn);
use C4::External::Amazon;
use C4::External::Syndetics qw(get_syndetics_index get_syndetics_summary get_syndetics_toc get_syndetics_excerpt get_syndetics_reviews get_syndetics_anotes );
use C4::Review;
use C4::Members;
use C4::VirtualShelves;
use C4::XSLT;
use C4::ShelfBrowser;
use C4::Charset;
use MARC::Record;
use MARC::Field;
use List::MoreUtils qw/any none/;

BEGIN {
	if (C4::Context->preference('BakerTaylorEnabled')) {
		require C4::External::BakerTaylor;
		import C4::External::BakerTaylor qw(&image_url &link_url);
	}
}

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-detail.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        flagsrequired   => { borrow => 1 },
    }
);

my $biblionumber = $query->param('biblionumber') || $query->param('bib');

$template->param( 'AllowOnShelfHolds' => C4::Context->preference('AllowOnShelfHolds') );
$template->param( 'ItemsIssued' => CountItemsIssued( $biblionumber ) );

my $record       = GetMarcBiblio($biblionumber);
if ( ! $record ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}
$template->param( biblionumber => $biblionumber );

SetUTF8Flag($record);

# XSLT processing of some stuff
if (C4::Context->preference("OPACXSLTDetailsDisplay") ) {
    $template->param( 'XSLTBloc' => XSLTParse4Display($biblionumber, $record, 'Detail', 'opac') );
}

$template->param('OPACShowCheckoutName' => C4::Context->preference("OPACShowCheckoutName") ); 
# change back when ive fixed request.pl
my @all_items = GetItemsInfo( $biblionumber );
my @items;

# Getting items to be hidden
my @hiddenitems = GetHiddenItemnumbers(@all_items);

# Are there items to hide?
my $hideitems = 1 if C4::Context->preference('hidelostitems') or scalar(@hiddenitems) > 0;

# Hide items
if ($hideitems) {
    for my $itm (@all_items) {
	if  ( C4::Context->preference('hidelostitems') ) {
	    push @items, $itm unless $itm->{itemlost} or any { $itm->{'itemnumber'} eq $_ } @hiddenitems;
	} else {
	    push @items, $itm unless any { $itm->{'itemnumber'} eq $_ } @hiddenitems;
    }
}
} else {
    # Or not
    @items = @all_items;
}

my $dat = &GetBiblioData($biblionumber);

my $itemtypes = GetItemTypes();
# imageurl:
my $itemtype = $dat->{'itemtype'};
if ( $itemtype ) {
    $dat->{'imageurl'}    = getitemtypeimagelocation( 'opac', $itemtypes->{$itemtype}->{'imageurl'} );
    $dat->{'description'} = $itemtypes->{$itemtype}->{'description'};
}
my $shelflocations =GetKohaAuthorisedValues('items.location',$dat->{'frameworkcode'}, 'opac');
my $collections =  GetKohaAuthorisedValues('items.ccode',$dat->{'frameworkcode'}, 'opac');

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       = GetSubscriptions( undef, undef, $biblionumber );

my @subs;
$dat->{'serial'}=1 if $subscriptionsnumber;
foreach my $subscription (@subscriptions) {
    my $serials_to_display;
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};
    $cell{missinglist}       = $subscription->{missinglist};
    $cell{opacnote}          = $subscription->{opacnote};
    $cell{histstartdate}     = format_date($subscription->{histstartdate});
    $cell{histenddate}       = format_date($subscription->{histenddate});
    $cell{branchcode}        = $subscription->{branchcode};
    $cell{branchname}        = GetBranchName($subscription->{branchcode});
    $cell{hasalert}          = $subscription->{hasalert};
    #get the three latest serials.
    $serials_to_display = $subscription->{opacdisplaycount};
    $serials_to_display = C4::Context->preference('OPACSerialIssueDisplayCount') unless $serials_to_display;
	$cell{opacdisplaycount} = $serials_to_display;
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, $serials_to_display );
    push @subs, \%cell;
}

$dat->{'count'} = scalar(@items);

# If there is a lot of items, and the user has not decided
# to view them all yet, we first warn him
# TODO: The limit of 50 could be a syspref
my $viewallitems = $query->param('viewallitems');
if ($dat->{'count'} >= 50 && !$viewallitems) {
    $template->param('lotsofitems' => 1);
}

my $biblio_authorised_value_images = C4::Items::get_authorised_value_images( C4::Biblio::get_biblio_authorised_values( $biblionumber, $record ) );

my $norequests = 1;
my $branches = GetBranches();
my %itemfields;
for my $itm (@items) {
    $norequests = 0
       if ( (not $itm->{'wthdrawn'} )
         && (not $itm->{'itemlost'} )
         && ($itm->{'itemnotforloan'}<0 || not $itm->{'itemnotforloan'} )
		 && (not $itemtypes->{$itm->{'itype'}}->{notforloan} )
         && ($itm->{'itemnumber'} ) );

    if ( defined $itm->{'publictype'} ) {
        # I can't actually find any case in which this is defined. --amoore 2008-12-09
        $itm->{ $itm->{'publictype'} } = 1;
    }
    $itm->{datedue}      = format_date($itm->{datedue});
    $itm->{datelastseen} = format_date($itm->{datelastseen});

    # get collection code description, too
    if ( my $ccode = $itm->{'ccode'} ) {
        $itm->{'ccode'} = $collections->{$ccode} if ( defined($collections) && exists( $collections->{$ccode} ) );
    }
    if ( defined $itm->{'location'} ) {
        $itm->{'location_description'} = $shelflocations->{ $itm->{'location'} };
    }
    if (exists $itm->{itype} && defined($itm->{itype}) && exists $itemtypes->{ $itm->{itype} }) {
        $itm->{'imageurl'}    = getitemtypeimagelocation( 'opac', $itemtypes->{ $itm->{itype} }->{'imageurl'} );
        $itm->{'description'} = $itemtypes->{ $itm->{itype} }->{'description'};
    }
    foreach (qw(ccode enumchron copynumber itemnotes uri)) {
        $itemfields{$_} = 1 if ($itm->{$_});
    }

     # walk through the item-level authorised values and populate some images
     my $item_authorised_value_images = C4::Items::get_authorised_value_images( C4::Items::get_item_authorised_values( $itm->{'itemnumber'} ) );
     # warn( Data::Dumper->Dump( [ $item_authorised_value_images ], [ 'item_authorised_value_images' ] ) );

     if ( $itm->{'itemlost'} ) {
         my $lostimageinfo = List::Util::first { $_->{'category'} eq 'LOST' } @$item_authorised_value_images;
         $itm->{'lostimageurl'}   = $lostimageinfo->{ 'imageurl' };
         $itm->{'lostimagelabel'} = $lostimageinfo->{ 'label' };
     }

     if( $itm->{'count_reserves'}){
          if( $itm->{'count_reserves'} eq "Waiting"){ $itm->{'waiting'} = 1; }
          if( $itm->{'count_reserves'} eq "Reserved"){ $itm->{'onhold'} = 1; }
     }
    
     my ( $transfertwhen, $transfertfrom, $transfertto ) = GetTransfers($itm->{itemnumber});
     if ( defined( $transfertwhen ) && $transfertwhen ne '' ) {
        $itm->{transfertwhen} = format_date($transfertwhen);
        $itm->{transfertfrom} = $branches->{$transfertfrom}{branchname};
        $itm->{transfertto}   = $branches->{$transfertto}{branchname};
     }
}

## get notes and subjects from MARC record
my $dbh              = C4::Context->dbh;
my $marcflavour      = C4::Context->preference("marcflavour");
my $marcnotesarray   = GetMarcNotes   ($record,$marcflavour);
my $marcisbnsarray   = GetMarcISBN    ($record,$marcflavour);
my $marcauthorsarray = GetMarcAuthors ($record,$marcflavour);
my $marcsubjctsarray = GetMarcSubjects($record,$marcflavour);
my $marcseriesarray  = GetMarcSeries  ($record,$marcflavour);
my $marcurlsarray    = GetMarcUrls    ($record,$marcflavour);
my $subtitle         = GetRecordValue('subtitle', $record, GetFrameworkCode($biblionumber));

    $template->param(
                     MARCNOTES               => $marcnotesarray,
                     MARCSUBJCTS             => $marcsubjctsarray,
                     MARCAUTHORS             => $marcauthorsarray,
                     MARCSERIES              => $marcseriesarray,
                     MARCURLS                => $marcurlsarray,
                     norequests              => $norequests,
                     RequestOnOpac           => C4::Context->preference("RequestOnOpac"),
                     itemdata_ccode          => $itemfields{ccode},
                     itemdata_enumchron      => $itemfields{enumchron},
                     itemdata_uri            => $itemfields{uri},
                     itemdata_copynumber     => $itemfields{copynumber},
                     itemdata_itemnotes          => $itemfields{itemnotes},
                     authorised_value_images => $biblio_authorised_value_images,
                     subtitle                => $subtitle,
    );

if (C4::Context->preference("AlternateHoldingsField") && scalar @items == 0) {
    my $fieldspec = C4::Context->preference("AlternateHoldingsField");
    my $subfields = substr $fieldspec, 3;
    my $holdingsep = C4::Context->preference("AlternateHoldingsSeparator") || ' ';
    my @alternateholdingsinfo = ();
    my @holdingsfields = $record->field(substr $fieldspec, 0, 3);

    for my $field (@holdingsfields) {
        my %holding = ( holding => '' );
        my $havesubfield = 0;
        for my $subfield ($field->subfields()) {
            if ((index $subfields, $$subfield[0]) >= 0) {
                $holding{'holding'} .= $holdingsep if (length $holding{'holding'} > 0);
                $holding{'holding'} .= $$subfield[1];
                $havesubfield++;
            }
        }
        if ($havesubfield) {
            push(@alternateholdingsinfo, \%holding);
        }
    }

    $template->param(
        ALTERNATEHOLDINGS   => \@alternateholdingsinfo,
        );
}

foreach ( keys %{$dat} ) {
    $template->param( "$_" => defined $dat->{$_} ? $dat->{$_} : '' );
}

# some useful variables for enhanced content;
# in each case, we're grabbing the first value we find in
# the record and normalizing it
my $upc = GetNormalizedUPC($record,$marcflavour);
my $ean = GetNormalizedEAN($record,$marcflavour);
my $oclc = GetNormalizedOCLCNumber($record,$marcflavour);
my $isbn = GetNormalizedISBN(undef,$record,$marcflavour);
my $content_identifier_exists;
if ( $isbn or $ean or $oclc or $upc ) {
    $content_identifier_exists = 1;
}
$template->param(
	normalized_upc => $upc,
	normalized_ean => $ean,
	normalized_oclc => $oclc,
	normalized_isbn => $isbn,
	content_identifier_exists =>  $content_identifier_exists,
);

# COinS format FIXME: for books Only
$template->param(
    ocoins => GetCOinSBiblio($biblionumber),
);

my $libravatar_enabled = 0;
eval 'use Libravatar::URL';
if (!$@ and C4::Context->preference('ShowReviewer') and C4::Context->preference('ShowReviewerPhoto')) {
    $libravatar_enabled = 1;
}

my $reviews = getreviews( $biblionumber, 1 );
my $loggedincommenter;
foreach ( @$reviews ) {
    my $borrowerData   = GetMember('borrowernumber' => $_->{borrowernumber});
    # setting some borrower info into this hash
    $_->{title}     = $borrowerData->{'title'};
    $_->{surname}   = $borrowerData->{'surname'};
    $_->{firstname} = $borrowerData->{'firstname'};
    if ($libravatar_enabled and $borrowerData->{'email'}) {
        $_->{avatarurl} = libravatar_url(email => $borrowerData->{'email'}, https => $ENV{HTTPS});
    }
    $_->{userid}    = $borrowerData->{'userid'};
    $_->{cardnumber}    = $borrowerData->{'cardnumber'};
    $_->{datereviewed} = format_date($_->{datereviewed});
    if ($borrowerData->{'borrowernumber'} eq $borrowernumber) {
		$_->{your_comment} = 1;
		$loggedincommenter = 1;
	}
}


if(C4::Context->preference("ISBD")) {
	$template->param(ISBD => 1);
}

$template->param(
    ITEM_RESULTS        => \@items,
    subscriptionsnumber => $subscriptionsnumber,
    biblionumber        => $biblionumber,
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
    reviews             => $reviews,
    loggedincommenter   => $loggedincommenter
);

# Lists

if (C4::Context->preference("virtualshelves") ) {
   $template->param( 'GetShelves' => GetBibliosShelves( $biblionumber ) );
}


# XISBN Stuff
if (C4::Context->preference("OPACFRBRizeEditions")==1) {
    eval {
        $template->param(
            XISBNS => get_xisbns($isbn)
        );
    };
    if ($@) { warn "XISBN Failed $@"; }
}

# Serial Collection
my @sc_fields = $record->field(955);
my @serialcollections = ();

foreach my $sc_field (@sc_fields) {
    my %row_data;

    $row_data{text}    = $sc_field->subfield('r');
    $row_data{branch}  = $sc_field->subfield('9');

    if ($row_data{text} && $row_data{branch}) { 
	push (@serialcollections, \%row_data);
    }
}

if (scalar(@serialcollections) > 0) {
    $template->param(
	serialcollection  => 1,
	serialcollections => \@serialcollections);
}

# Amazon.com Stuff
if ( C4::Context->preference("OPACAmazonEnabled") ) {
    $template->param( AmazonTld => get_amazon_tld() );
    my $amazon_reviews  = C4::Context->preference("OPACAmazonReviews");
    my $amazon_similars = C4::Context->preference("OPACAmazonSimilarItems");
    my @services;
    if ( $amazon_reviews ) {
        push( @services, 'EditorialReview', 'Reviews' );
    }
    if ( $amazon_similars ) {
        push( @services, 'Similarities' );
    }
    my $amazon_details = &get_amazon_details( $isbn, $record, $marcflavour, \@services );
    my $similar_products_exist;
    if ( $amazon_reviews ) {
        my $item = $amazon_details->{Items}->{Item}->[0];
        my $customer_reviews = \@{ $item->{CustomerReviews}->{Review} };
        for my $one_review ( @$customer_reviews ) {
            $one_review->{Date} = format_date($one_review->{Date});
        }
        my $editorial_reviews = \@{ $item->{EditorialReviews}->{EditorialReview} };
        my $average_rating = $item->{CustomerReviews}->{AverageRating} || 0;
        $template->param( amazon_average_rating    => $average_rating * 20);
        $template->param( AMAZON_CUSTOMER_REVIEWS  => $customer_reviews );
        $template->param( AMAZON_EDITORIAL_REVIEWS => $editorial_reviews );
    }
    if ( $amazon_similars ) {
        my $item = $amazon_details->{Items}->{Item}->[0];
        my @similar_products;
        for my $similar_product (@{ $item->{SimilarProducts}->{SimilarProduct} }) {
            # do we have any of these isbns in our collection?
            my $similar_biblionumbers = get_biblionumber_from_isbn($similar_product->{ASIN});
            # verify that there is at least one similar item
            if (scalar(@$similar_biblionumbers)){
                $similar_products_exist++ if ($similar_biblionumbers && $similar_biblionumbers->[0]);
                push @similar_products, +{ similar_biblionumbers => $similar_biblionumbers, title => $similar_product->{Title}, ASIN => $similar_product->{ASIN}  };
            }
        }
        $template->param( OPACAmazonSimilarItems => $similar_products_exist );
        $template->param( AMAZON_SIMILAR_PRODUCTS => \@similar_products );
    }
}

my $syndetics_elements;

if ( C4::Context->preference("SyndeticsEnabled") ) {
    $template->param("SyndeticsEnabled" => 1);
    $template->param("SyndeticsClientCode" => C4::Context->preference("SyndeticsClientCode"));
	eval {
	    $syndetics_elements = &get_syndetics_index($isbn,$upc,$oclc);
	    for my $element (values %$syndetics_elements) {
		$template->param("Syndetics$element"."Exists" => 1 );
		#warn "Exists: "."Syndetics$element"."Exists";
	}
    };
    warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
        && C4::Context->preference("SyndeticsSummary")
        && ( exists($syndetics_elements->{'SUMMARY'}) || exists($syndetics_elements->{'AVSUMMARY'}) ) ) {
	eval {
	    my $syndetics_summary = &get_syndetics_summary($isbn,$upc,$oclc, $syndetics_elements);
	    $template->param( SYNDETICS_SUMMARY => $syndetics_summary );
	};
	warn $@ if $@;

}

if ( C4::Context->preference("SyndeticsEnabled")
        && C4::Context->preference("SyndeticsTOC")
        && exists($syndetics_elements->{'TOC'}) ) {
	eval {
    my $syndetics_toc = &get_syndetics_toc($isbn,$upc,$oclc);
    $template->param( SYNDETICS_TOC => $syndetics_toc );
	};
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsExcerpt")
    && exists($syndetics_elements->{'DBCHAPTER'}) ) {
    eval {
    my $syndetics_excerpt = &get_syndetics_excerpt($isbn,$upc,$oclc);
    $template->param( SYNDETICS_EXCERPT => $syndetics_excerpt );
    };
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsReviews")) {
    eval {
    my $syndetics_reviews = &get_syndetics_reviews($isbn,$upc,$oclc,$syndetics_elements);
    $template->param( SYNDETICS_REVIEWS => $syndetics_reviews );
    };
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsAuthorNotes")
	&& exists($syndetics_elements->{'ANOTES'}) ) {
    eval {
    my $syndetics_anotes = &get_syndetics_anotes($isbn,$upc,$oclc);
    $template->param( SYNDETICS_ANOTES => $syndetics_anotes );
    };
    warn $@ if $@;
}

# LibraryThingForLibraries ID Code and Tabbed View Option
if( C4::Context->preference('LibraryThingForLibrariesEnabled') ) 
{ 
$template->param(LibraryThingForLibrariesID =>
C4::Context->preference('LibraryThingForLibrariesID') ); 
$template->param(LibraryThingForLibrariesTabbedView =>
C4::Context->preference('LibraryThingForLibrariesTabbedView') );
} 

# Novelist Select
if( C4::Context->preference('NovelistSelectEnabled') ) 
{ 
$template->param(NovelistSelectProfile => C4::Context->preference('NovelistSelectProfile') ); 
$template->param(NovelistSelectPassword => C4::Context->preference('NovelistSelectPassword') ); 
$template->param(NovelistSelectView => C4::Context->preference('NovelistSelectView') ); 
} 


# Babelthèque
if ( C4::Context->preference("Babeltheque") ) {
    $template->param( 
        Babeltheque => 1,
    );
}

# Shelf Browser Stuff
if (C4::Context->preference("OPACShelfBrowser")) {
    # pick the first itemnumber unless one was selected by the user
    my $starting_itemnumber = $query->param('shelfbrowse_itemnumber'); # || $items[0]->{itemnumber};
    if (defined($starting_itemnumber)) {
        $template->param( OpenOPACShelfBrowser => 1) if $starting_itemnumber;
        my $nearby = GetNearbyItems($starting_itemnumber,3);

        $template->param(
            starting_homebranch => $nearby->{starting_homebranch}->{description},
            starting_location => $nearby->{starting_location}->{description},
            starting_ccode => $nearby->{starting_ccode}->{description},
            starting_itemnumber => $nearby->{starting_itemnumber},
            shelfbrowser_prev_itemnumber => $nearby->{prev_itemnumber},
            shelfbrowser_next_itemnumber => $nearby->{next_itemnumber},
            shelfbrowser_prev_biblionumber => $nearby->{prev_biblionumber},
            shelfbrowser_next_biblionumber => $nearby->{next_biblionumber},
            PREVIOUS_SHELF_BROWSE => $nearby->{prev},
            NEXT_SHELF_BROWSE => $nearby->{next},
        );
    }
}

if (C4::Context->preference("BakerTaylorEnabled")) {
	$template->param(
		BakerTaylorEnabled  => 1,
		BakerTaylorImageURL => &image_url(),
		BakerTaylorLinkURL  => &link_url(),
		BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
	);
	my ($bt_user, $bt_pass);
	if ($isbn and
		$bt_user = C4::Context->preference('BakerTaylorUsername') and
		$bt_pass = C4::Context->preference('BakerTaylorPassword')    )
	{
		$template->param(
		BakerTaylorContentURL   =>
		sprintf("http://contentcafe2.btol.com/ContentCafeClient/ContentCafe.aspx?UserID=%s&Password=%s&ItemKey=%s&Options=Y",
				$bt_user,$bt_pass,$isbn)
		);
	}
}

my $tag_quantity;
if (C4::Context->preference('TagsEnabled') and $tag_quantity = C4::Context->preference('TagsShowOnDetail')) {
	$template->param(
		TagsEnabled => 1,
		TagsShowOnDetail => $tag_quantity,
		TagsInputOnDetail => C4::Context->preference('TagsInputOnDetail')
	);
	$template->param(TagLoop => get_tags({biblionumber=>$biblionumber, approved=>1,
								'sort'=>'-weight', limit=>$tag_quantity}));
}

if (C4::Context->preference("OPACURLOpenInNewWindow")) {
    # These values are going to be read by Javascript, at least in the case
    # of the google covers
    $template->param(covernewwindow => 'true');
} else {
    $template->param(covernewwindow => 'false');
}

#Search for title in links
my $marccontrolnumber   = GetMarcControlnumber   ($record, $marcflavour);

if (my $search_for_title = C4::Context->preference('OPACSearchForTitleIn')){
    $dat->{author} ? $search_for_title =~ s/{AUTHOR}/$dat->{author}/g : $search_for_title =~ s/{AUTHOR}//g;
    $dat->{title} =~ s/\/+$//; # remove trailing slash
    $dat->{title} =~ s/\s+$//; # remove trailing space
    $dat->{title} ? $search_for_title =~ s/{TITLE}/$dat->{title}/g : $search_for_title =~ s/{TITLE}//g;
    $isbn ? $search_for_title =~ s/{ISBN}/$isbn/g : $search_for_title =~ s/{ISBN}//g;
    $marccontrolnumber ? $search_for_title =~ s/{CONTROLNUMBER}/$marccontrolnumber/g : $search_for_title =~ s/{CONTROLNUMBER}//g;
    $search_for_title =~ s/{BIBLIONUMBER}/$biblionumber/g;
 $template->param('OPACSearchForTitleIn' => $search_for_title);
}

# We try to select the best default tab to show, according to what
# the user wants, and what's available for display
my $opac_serial_default = C4::Context->preference('opacSerialDefaultTab');
my $defaulttab = 
    $opac_serial_default eq 'subscriptions' && $subscriptionsnumber
        ? 'subscriptions' :
    $opac_serial_default eq 'serialcollection' && @serialcollections > 0
        ? 'serialcollection' :
    $opac_serial_default eq 'holdings' && $dat->{'count'} > 0
        ? 'holdings' :
    $subscriptionsnumber
        ? 'subscriptions' :
    @serialcollections > 0 
        ? 'serialcollection' : 'subscription';
$template->param('defaulttab' => $defaulttab);

output_html_with_http_headers $query, $cookie, $template->output;
