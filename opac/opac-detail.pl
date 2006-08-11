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

use strict;
require Exporter;
use CGI;
use C4::Auth;
use C4::Serials;    #uses getsubscriptionfrom biblionumber
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Biblio;
use C4::Search;
use C4::Amazon;
use C4::Review;

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

my $biblionumber = $query->param('bib');
$template->param( biblionumber => $biblionumber );

# change back when ive fixed request.pl
my @items = &ItemInfo( undef, $biblionumber, 'opac' );
my $dat = &bibdata($biblionumber);
my ( $authorcount,        $addauthor )      = &addauthor($biblionumber);
my ( $webbiblioitemcount, @webbiblioitems ) = &getwebbiblioitems($biblionumber);
my ( $websitecount,       @websites )       = &getwebsites($biblionumber);

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       =
  GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );
my @subs;
foreach my $subscription (@subscriptions) {
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};

    #get the three latest serials.
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, 3 );
    push @subs, \%cell;
}

$dat->{'count'} = @items;
my @author;
if ( $dat->{'author'} ) {
    my %authorpush;
    $authorpush{author} = $dat->{'author'};
    push @author, \%authorpush;
}
$dat->{'additional'} = $addauthor->[0]->{'author'};
if ( $dat->{'additional'} ) {
    my %authorpush;
    $authorpush{author} = $addauthor->[0]->{'author'};
    push @author, \%authorpush;
}
my @title;
foreach my $word ( split( " ", $dat->{'title'} ) ) {
    unless ( length($word) == 4 ) {
        $word =~ s/\%//g;
    }
    unless ( C4::Context->stopwords->{ uc($word) } or length($word) == 1 ) {
        my %titlepush;
        $titlepush{title} = $word;
        push @title, \%titlepush;
    }    #it's NOT a stopword => use it. Otherwise, ignore
}

for ( my $i = 1 ; $i < $authorcount ; $i++ ) {
    $dat->{'additional'} .= " ; " . $addauthor->[$i]->{'author'};

    my %authorpush;
    $authorpush{author} = $addauthor->[$i]->{'author'};
    push @author, \%authorpush;
}    # for

my $norequests = 1;
foreach my $itm (@items) {
    $norequests = 0
      unless ( ( $itm->{'wthdrawn'} )
        || ( $itm->{'itemlost'} )
        || ( $itm->{'notforloan'} )
        || ( $itm->{'itemnotforloan'} )
        || ( !$itm->{'itemnumber'} ) );
    $itm->{ $itm->{'publictype'} } = 1;
}

$template->param( norequests => $norequests );

## get notes and subjects from MARC record
my $marc    = C4::Context->preference("marc");
my @results = ( $dat, );
if ( C4::Boolean::true_p($marc) ) {
    my $dbh = C4::Context->dbh;
    my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber( $dbh, $biblionumber );
    my $marcflavour = C4::Context->preference("marcflavour");
    my $marcnotesarray = &getMARCnotes( $dbh, $bibid, $marcflavour );
    $results[0]->{MARCNOTES} = $marcnotesarray;
    my $marcsubjctsarray = &getMARCsubjects( $dbh, $bibid, $marcflavour );
    $results[0]->{MARCSUBJCTS} = $marcsubjctsarray;

    # 	$template->param(MARCNOTES => $marcnotesarray);
    # 	$template->param(MARCSUBJCTS => $marcsubjctsarray);
}

# get the number of reviews
my $reviewcount = numberofreviews($biblionumber);
$dat->{'reviews'} = $reviewcount;

my @results      = ( $dat, );
my $resultsarray = \@results;
my $itemsarray   = \@items;
my $webarray     = \@webbiblioitems;
my $sitearray    = \@websites;
my $titlewords   = \@title;
my $authorwords  = \@author;

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       =
  GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );
my @subs;
foreach my $subscription (@subscriptions) {
    warn "subsid :" . $subscription->{subscriptionid};
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};

    #get the three latest serials.
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, 3 );
    push @subs, \%cell;
}

$template->param(
    BIBLIO_RESULTS      => $resultsarray,
    ITEM_RESULTS        => $itemsarray,
    WEB_RESULTS         => $webarray,
    SITE_RESULTS        => $sitearray,
    subscriptionsnumber => $subscriptionsnumber,
    LibraryName         => C4::Context->preference("LibraryName"),
    suggestion          => C4::Context->preference("suggestion"),
    virtualshelves      => C4::Context->preference("virtualshelves"),
    titlewords          => $titlewords,
    authorwords         => $authorwords,
    reviewson           => C4::Context->preference("marc"),
);
## Amazon.com stuff
#not used unless preference set
if ( C4::Context->preference("AmazonContent") == 1 ) {
    use C4::Amazon;
    $dat->{'amazonisbn'} = $dat->{'isbn'};
    $dat->{'amazonisbn'} =~ s|-||g;

    $template->param( amazonisbn => $dat->{amazonisbn} );

    my $amazon_details = &get_amazon_details( $dat->{amazonisbn} );

    foreach my $result ( @{ $amazon_details->{Details} } ) {
        $template->param( item_description => $result->{ProductDescription} );
        $template->param( image            => $result->{ImageUrlMedium} );
        $template->param( list_price       => $result->{ListPrice} );
        $template->param( amazon_url       => $result->{url} );
    }

    my @products;
    my @reviews;
    for my $details ( @{ $amazon_details->{Details} } ) {
        next unless $details->{SimilarProducts};
        for my $product ( @{ $details->{SimilarProducts}->{Product} } ) {
            push @products, +{ Product => $product };
        }
        next unless $details->{Reviews};
        for my $product ( @{ $details->{Reviews}->{AvgCustomerRating} } ) {
            $template->param( rating => $product * 20 );
        }
        for my $reviews ( @{ $details->{Reviews}->{CustomerReview} } ) {
            push @reviews,
              +{
                Summary => $reviews->{Summary},
                Comment => $reviews->{Comment},
              };
        }
    }
    $template->param( SIMILAR_PRODUCTS => \@products );
    $template->param( REVIEWS          => \@reviews );
}
output_html_with_http_headers $query, $cookie, $template->output;
