#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use C4::Search;
use C4::Auth;
use C4::Bull; #uses getsubscriptionfrom biblionumber
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Biblio;
use C4::SearchMarc;
use C4::Amazon;
my $query=new CGI;
my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-detail.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     });

my $biblionumber=$query->param('bib');
$template->param(biblionumber => $biblionumber);


# change back when ive fixed request.pl
my @items                                 = &ItemInfo(undef, $biblionumber, 'opac');
my $dat                                   = &bibdata($biblionumber);
my ($authorcount, $addauthor)             = &addauthor($biblionumber);
my ($webbiblioitemcount, @webbiblioitems) = &getwebbiblioitems($biblionumber);
my ($websitecount, @websites)             = &getwebsites($biblionumber);
my $subscriptionsnumber = getsubscriptionfrombiblionumber($biblionumber);

my @title;
$dat->{'count'}=@items;
my @author;
if ($dat->{'author'}){
	my %authorpush; 
	$authorpush{author}=$dat->{'author'};
	push @author, \%authorpush
}
$dat->{'additional'}=$addauthor->[0]->{'author'};
if ($dat->{'additional'}){
	my %authorpush;
	$authorpush{author} =$addauthor->[0]->{'author'};
	push @author, \%authorpush
}

foreach my $word (split(" ", $dat->{'title'})){
        unless (length($word) == 4){
                $word =~s/\%//g
        }
        unless (C4::Context->stopwords->{uc($word)} or length($word)==1) {
        my %titlepush;
        $titlepush{title} =$word;
                push @title, \%titlepush;
        }#it's NOT a stopword => use it. Otherwise, ignore
}

for (my $i = 1; $i < $authorcount; $i++) {
        $dat->{'additional'} .= " ; " . $addauthor->[$i]->{'author'};
    
        my %authorpush;
        $authorpush{author}=$addauthor->[$i]->{'author'};
        push @author, \%authorpush
} # for

my $norequests = 1;
foreach my $itm (@items) {
    $norequests = 0 unless $itm->{'notforloan'};
    $itm->{$itm->{'publictype'}} = 1;
}

$template->param(norequests => $norequests);

  ## get notes and subjects from MARC record
my $marc = C4::Context->preference("marc");
my @results = ($dat,);
if (C4::Boolean::true_p($marc)) {
	my $dbh = C4::Context->dbh;
	my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);
	my $marcflavour = C4::Context->preference("marcflavour");
	my $marcnotesarray = &getMARCnotes($dbh,$bibid,$marcflavour);
	$results[0]->{MARCNOTES} = $marcnotesarray;
	my $marcsubjctsarray = &getMARCsubjects($dbh,$bibid,$marcflavour);
	$results[0]->{MARCSUBJCTS} = $marcsubjctsarray;
# 	$template->param(MARCNOTES => $marcnotesarray);
# 	$template->param(MARCSUBJCTS => $marcsubjctsarray);
}

my @results = ($dat,);






my $resultsarray=\@results;
my $itemsarray=\@items;
my $webarray=\@webbiblioitems;
my $sitearray=\@websites;
my $titlewords=\@title;
my $authorwords=\@author;


#coping with subscriptions
my $subscriptionsnumber = getsubscriptionfrombiblionumber($biblionumber);
my @subscriptions = getsubscriptions($dat->{title},$dat->{issn},$biblionumber);
my @subs;
foreach my $subscription (@subscriptions){
	warn "subsid :".$subscription->{subscriptionid};
	my %cell;
	$cell{subscriptionid}= $subscription->{subscriptionid};
	$cell{subscriptionnotes}= $subscription->{notes};
	#get the three latest serials.
	$cell{latestserials}=getlatestserials($subscription->{subscriptionid},3);
	push @subs, \%cell;
}

$template->param(BIBLIO_RESULTS => $resultsarray,
				ITEM_RESULTS => $itemsarray,
				WEB_RESULTS => $webarray,
				SITE_RESULTS => $sitearray,
				subscriptionsnumber => $subscriptionsnumber,
			     LibraryName => C4::Context->preference("LibraryName"),
				suggestion => C4::Context->preference("suggestion"),
				virtualshelves => C4::Context->preference("virtualshelves"),
        titlewords => $titlewords,
        authorwords => $authorwords,
);
  ## Amazon.com stuff
=head
my $isbn=$dat->{'isbn'};
my $amazon_details = &get_amazon_details($isbn);
foreach my $result (@{$amazon_details->{Details}}){
        $template->param(item_description => $result->{ProductDescription});
        $template->param(image => $result->{ImageUrlMedium});
        $template->param(list_price => $result->{ListPrice});
        $template->param(amazon_url => $result->{url});
                                }

my @products;
my @reviews;
for my $details( @{ $amazon_details->{ Details } } ) {
        next unless $details->{ SimilarProducts };
        for my $product ( @{ $details->{ SimilarProducts }->{ Product } } ) {
                push @products, +{ Product => $product };
        }
        next unless $details->{ Reviews };
        for my $product ( @{ $details->{ Reviews }->{ AvgCustomerRating } } ) {
                $template->param(rating => $product);
        }
        for my $reviews ( @{ $details->{ Reviews }->{ CustomerReview } } ) {
                push @reviews, +{ Summary => $reviews->{ Summary }, Comment => $reviews->{ Comment }, };
        }
}
$template->param( SIMILAR_PRODUCTS => \@products );
$template->param( REVIEWS => \@reviews );
  ## End of Amazon Stuff
=cut
output_html_with_http_headers $query, $cookie, $template->output;

