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
use C4::XISBN qw(get_xisbns get_biblionumber_from_isbn get_biblio_from_xisbn);
use C4::External::Amazon;
use C4::External::Syndetics qw(get_syndetics_index get_syndetics_summary get_syndetics_toc get_syndetics_excerpt get_syndetics_reviews get_syndetics_anotes );
use C4::Review;
use C4::Serials;
use C4::Members;
use C4::XSLT;

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
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $biblionumber = $query->param('biblionumber') || $query->param('bib');
my $record       = GetMarcBiblio($biblionumber);
$template->param( biblionumber => $biblionumber );
# XSLT processing of some stuff
if (C4::Context->preference("XSLTDetailsDisplay") ) {
    my $newxmlrecord = XSLTParse4Display($biblionumber, $record, C4::Context->config('opachtdocs')."/prog/en/xslt/MARC21slim2OPACDetail.xsl");
    $template->param('XSLTBloc' => $newxmlrecord);
}

# change back when ive fixed request.pl
my @all_items = &GetItemsInfo( $biblionumber, 'opac' );
my @items;
@items = @all_items unless C4::Context->preference('hidelostitems');

if (C4::Context->preference('hidelostitems')) {
    # Hide host items
    for my $itm (@all_items) {
        push @items, $itm unless $itm->{itemlost};
    }
}
my $dat = &GetBiblioData($biblionumber);

if (!$dat) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}
my $itemtypes = GetItemTypes();
# imageurl:
my $itemtype = $dat->{'itemtype'};
if ( $itemtype ) {
    $dat->{'imageurl'}    = getitemtypeimagelocation( 'opac', $itemtypes->{$itemtype}->{'imageurl'} );
    $dat->{'description'} = $itemtypes->{$itemtype}->{'description'};
}
my $shelflocations =GetKohaAuthorisedValues('items.location',$dat->{'frameworkcode'});
my $collections =  GetKohaAuthorisedValues('items.ccode',$dat->{'frameworkcode'} );

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

$dat->{'count'} = scalar(@items);

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

    $itm->{ $itm->{'publictype'} } = 1;
    $itm->{datedue}      = format_date($itm->{datedue});
    $itm->{datelastseen} = format_date($itm->{datelastseen});

    #get collection code description, too
	my $ccode= $itm->{'ccode'};
	$itm->{'ccode'} = $collections->{$ccode} if(defined($collections) && exists($collections->{$ccode}));
    $itm->{'location_description'} = $shelflocations->{$itm->{'location'} };
    $itm->{'imageurl'}    = getitemtypeimagelocation( 'opac', $itemtypes->{ $itm->{itype} }->{'imageurl'} );
    $itm->{'description'} = $itemtypes->{$itemtype}->{'description'};
    foreach (qw(ccode enumchron copynumber itemnotes)) {
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

    
     my ( $transfertwhen, $transfertfrom, $transfertto ) = GetTransfers($itm->{itemnumber});
     if ( $transfertwhen ne '' ) {
        $itm->{transfertwhen} = format_date($transfertwhen);
        $itm->{transfertfrom} = $branches->{$transfertfrom}{branchname};
        $itm->{transfertto}   = $branches->{$transfertto}{branchname};
     }
}

## get notes and subjects from MARC record
my $dbh              = C4::Context->dbh;
my $marcflavour      = C4::Context->preference("marcflavour");
my $marcnotesarray   = GetMarcNotes   ($record,$marcflavour);
my $marcauthorsarray = GetMarcAuthors ($record,$marcflavour);
my $marcsubjctsarray = GetMarcSubjects($record,$marcflavour);
my $marcseriesarray  = GetMarcSeries  ($record,$marcflavour);
my $marcurlsarray    = GetMarcUrls    ($record,$marcflavour);
my $subtitle         = C4::Biblio::get_koha_field_from_marc('bibliosubtitle', 'subtitle', $record, '');

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
                     itemdata_copynumber     => $itemfields{copynumber},
                     itemdata_itemnotes          => $itemfields{itemnotes},
                     authorised_value_images => $biblio_authorised_value_images,
                     subtitle                => $subtitle,
    );

foreach ( keys %{$dat} ) {
    $template->param( "$_" => $dat->{$_} . "" );
}

# COinS format FIXME: for books Only
my $coins_format;
my $fmt = substr $record->leader(), 6,2;
my $fmts;
$fmts->{'am'} = 'book';
$coins_format = $fmts->{$fmt};
$template->param(
	ocoins_format => $coins_format,
);

my $reviews = getreviews( $biblionumber, 1 );
my $loggedincommenter;
foreach ( @$reviews ) {
    my $borrowerData   = GetMember($_->{borrowernumber},'borrowernumber');
    # setting some borrower info into this hash
    $_->{title}     = $borrowerData->{'title'};
    $_->{surname}   = $borrowerData->{'surname'};
    $_->{firstname} = $borrowerData->{'firstname'};
    $_->{userid}    = $borrowerData->{'userid'};
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

sub isbn_cleanup ($) {
	my $isbn=shift;
    ($isbn) = $isbn =~ /([\d-]*[X]*)/;
    $isbn =~ s/-//g;
	if (
		$isbn =~ /\b(\d{13})\b/ or
		$isbn =~ /\b(\d{10})\b/ or 
		$isbn =~ /\b(\d{9}X)\b/i
	) {
		return $1;
	}
	return undef;
}

# XISBN Stuff
my $xisbn=$dat->{'isbn'};
(my $aisbn) = $xisbn =~ /([\d-]*[X]*)/;
$aisbn =~ s/-//g;
$template->param(amazonisbn => $aisbn);		# FIXME: so it is OK if the ISBN = 'XXXXX' ?
my ($clean,$clean2);
# these might be overkill, but they are better than the regexp above.
if ($clean = isbn_cleanup($xisbn)){
	$template->param(clean_isbn => $clean);
}

if (C4::Context->preference("OPACFRBRizeEditions")==1) {
    eval {
        $template->param(
            xisbn => $xisbn,
            XISBNS => get_xisbns($xisbn)
        );
    };
    if ($@) { warn "XISBN Failed $@"; }
}
# Amazon.com Stuff
if ( C4::Context->preference("OPACAmazonContent") == 1 ) {
    my $similar_products_exist;
    my $amazon_details = &get_amazon_details( $xisbn, $record, $marcflavour );
    my $item_attributes = \%{$amazon_details->{Items}->{Item}->{ItemAttributes}};
    my $customer_reviews = \@{$amazon_details->{Items}->{Item}->{CustomerReviews}->{Review}};
    for my $one_review (@$customer_reviews) {
        $one_review->{Date} = format_date($one_review->{Date});
    }
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
    $template->param( OPACAmazonSimilarItems => $similar_products_exist );
    $template->param( amazon_average_rating => $average_rating * 20);
    $template->param( AMAZON_CUSTOMER_REVIEWS    => $customer_reviews );
    $template->param( AMAZON_SIMILAR_PRODUCTS => \@similar_products );
    $template->param( AMAZON_EDITORIAL_REVIEWS    => $editorial_reviews );
}

my $syndetics_elements;
if ( C4::Context->preference("SyndeticsEnabled") ) {
	eval {
    $syndetics_elements = &get_syndetics_index($xisbn);
	for my $element (values %$syndetics_elements) {
		$template->param("Syndetics$element"."Exists" => 1 );
		#warn "Exists: "."Syndetics$element"."Exists";
	}
    };
    warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
        && C4::Context->preference("SyndeticsSummary")
        && $syndetics_elements->{'SUMMARY'} =~ /SUMMARY/) {
	eval {
	my $syndetics_summary = &get_syndetics_summary($xisbn);
	$template->param( SYNDETICS_SUMMARY => $syndetics_summary );
	};
	warn $@ if $@;

}

if ( C4::Context->preference("SyndeticsEnabled")
        && C4::Context->preference("SyndeticsTOC")
        && $syndetics_elements->{'TOC'} =~ /TOC/) {
	eval {
    my $syndetics_toc = &get_syndetics_toc($xisbn);
    $template->param( SYNDETICS_TOC => $syndetics_toc );
	};
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsExcerpt")
    && $syndetics_elements->{'DBCHAPTER'} =~ /DBCHAPTER/ ) {
    eval {
    my $syndetics_excerpt = &get_syndetics_excerpt($xisbn);
    $template->param( SYNDETICS_EXCERPT => $syndetics_excerpt );
    };
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsReviews")) {
    eval {
    my $syndetics_reviews = &get_syndetics_reviews($xisbn,$syndetics_elements);
    $template->param( SYNDETICS_REVIEWS => $syndetics_reviews );
    };
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsAuthorNotes")
	&& $syndetics_elements->{'ANOTES'} =~ /ANOTES/ ) {
    eval {
    my $syndetics_anotes = &get_syndetics_anotes($xisbn);
    $template->param( SYNDETICS_ANOTES => $syndetics_anotes );
    };
    warn $@ if $@;
}

# Shelf Browser Stuff
if (C4::Context->preference("OPACShelfBrowser")) {
    # pick the first itemnumber unless one was selected by the user
    my $starting_itemnumber = $query->param('shelfbrowse_itemnumber'); # || $items[0]->{itemnumber};
    $template->param( OpenOPACShelfBrowser => 1) if $starting_itemnumber;
    # find the right cn_sort value for this item
    my ($starting_cn_sort, $starting_homebranch, $starting_location);
    my $sth_get_cn_sort = $dbh->prepare("SELECT cn_sort,homebranch,location from items where itemnumber=?");
    $sth_get_cn_sort->execute($starting_itemnumber);
    while (my $result = $sth_get_cn_sort->fetchrow_hashref()) {
        $starting_cn_sort = $result->{'cn_sort'};
        $starting_homebranch->{code} = $result->{'homebranch'};
        $starting_homebranch->{description} = $branches->{$result->{'homebranch'}}{branchname};
        $starting_location->{code} = $result->{'location'};
        $starting_location->{description} = GetAuthorisedValueDesc('','',   $result->{'location'} ,'','','LOC');
    
    }
    
    ## List of Previous Items
    # order by cn_sort, which should include everything we need for ordering purposes (though not
    # for limits, those need to be handled separately
    my $sth_shelfbrowse_previous = $dbh->prepare("
        SELECT *
        FROM items
        WHERE
            ((cn_sort = ? AND itemnumber < ?) OR cn_sort < ?) AND
            homebranch = ? AND location = ?
        ORDER BY cn_sort DESC, itemnumber LIMIT 3
        ");
    $sth_shelfbrowse_previous->execute($starting_cn_sort, $starting_itemnumber, $starting_cn_sort, $starting_homebranch->{code}, $starting_location->{code});
    my @previous_items;
    while (my $this_item = $sth_shelfbrowse_previous->fetchrow_hashref()) {
        my $sth_get_biblio = $dbh->prepare("SELECT biblio.*,biblioitems.isbn AS isbn FROM biblio LEFT JOIN biblioitems ON biblio.biblionumber=biblioitems.biblionumber WHERE biblio.biblionumber=?");
        $sth_get_biblio->execute($this_item->{biblionumber});
        while (my $this_biblio = $sth_get_biblio->fetchrow_hashref()) {
            $this_item->{'title'} = $this_biblio->{'title'};
            if ($clean2 = isbn_cleanup($this_biblio->{'isbn'})) {
                $this_item->{'isbn'} = $clean2;
            } else { 
                $this_item->{'isbn'} = $this_biblio->{'isbn'};
            }
        }
        unshift @previous_items, $this_item;
    }
    
    ## List of Next Items; this also intentionally catches the current item
    my $sth_shelfbrowse_next = $dbh->prepare("
        SELECT *
        FROM items
        WHERE
            ((cn_sort = ? AND itemnumber >= ?) OR cn_sort > ?) AND
            homebranch = ? AND location = ?
        ORDER BY cn_sort, itemnumber LIMIT 3
        ");
    $sth_shelfbrowse_next->execute($starting_cn_sort, $starting_itemnumber, $starting_cn_sort, $starting_homebranch->{code}, $starting_location->{code});
    my @next_items;
    while (my $this_item = $sth_shelfbrowse_next->fetchrow_hashref()) {
        my $sth_get_biblio = $dbh->prepare("SELECT biblio.*,biblioitems.isbn AS isbn FROM biblio LEFT JOIN biblioitems ON biblio.biblionumber=biblioitems.biblionumber WHERE biblio.biblionumber=?");
        $sth_get_biblio->execute($this_item->{biblionumber});
        while (my $this_biblio = $sth_get_biblio->fetchrow_hashref()) {
            $this_item->{'title'} = $this_biblio->{'title'};
            if ($clean2 = isbn_cleanup($this_biblio->{'isbn'})) {
                $this_item->{'isbn'} = $clean2;
            } else { 
                $this_item->{'isbn'} = $this_biblio->{'isbn'};
            }
        }
        push @next_items, $this_item;
    }
    
    # alas, these won't auto-vivify, see http://www.perlmonks.org/?node_id=508481
    my $shelfbrowser_next_itemnumber = $next_items[-1]->{itemnumber} if @next_items;
    my $shelfbrowser_next_biblionumber = $next_items[-1]->{biblionumber} if @next_items;
    
    $template->param(
        starting_homebranch => $starting_homebranch->{description},
        starting_location => $starting_location->{description},
        starting_itemnumber => $starting_itemnumber,
        shelfbrowser_prev_itemnumber => (@previous_items ? $previous_items[0]->{itemnumber} : 0),
        shelfbrowser_next_itemnumber => $shelfbrowser_next_itemnumber,
        shelfbrowser_prev_biblionumber => (@previous_items ? $previous_items[0]->{biblionumber} : 0),
        shelfbrowser_next_biblionumber => $shelfbrowser_next_biblionumber,
        PREVIOUS_SHELF_BROWSE => \@previous_items,
        NEXT_SHELF_BROWSE => \@next_items,
    );
}

if (C4::Context->preference("BakerTaylorEnabled")) {
	$template->param(
		BakerTaylorEnabled  => 1,
		BakerTaylorImageURL => &image_url(),
		BakerTaylorLinkURL  => &link_url(),
		BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
	);
	my ($bt_user, $bt_pass);
	if ($clean and
		$bt_user = C4::Context->preference('BakerTaylorUsername') and
		$bt_pass = C4::Context->preference('BakerTaylorPassword')    )
	{
		$template->param(
		BakerTaylorContentURL   =>
		sprintf("http://contentcafe2.btol.com/ContentCafeClient/ContentCafe.aspx?UserID=%s&Password=%s&ItemKey=%s&Options=Y",
				$bt_user,$bt_pass,$clean)
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

output_html_with_http_headers $query, $cookie, $template->output;
