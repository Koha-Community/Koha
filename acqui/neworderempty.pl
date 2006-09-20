#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

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


=head1 NAME

neworderempty.pl

=head1 DESCRIPTION
this script allows to create a new record to order it. This record shouldn't exist
on database.

=head1 CGI PARAMETERS

=over 4

=item booksellerid
the bookseller the librarian has to buy a new book.

=item title
the title of this new record.

=item author
the author of this new record.

=item copyright
the copyright of this new record.

=item ordnum
the number of this order.

=item biblio

=item basketno
the basket number for this new order.

=item suggestionid
if this order comes from a suggestion.

=item close

=back

=cut

use strict;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Bookfund;
use C4::Bookseller;
use C4::Acquisition;
use C4::Suggestions;
use C4::Biblio;
use C4::Search;
use C4::Koha;
use C4::Interface::CGI::Output;
use C4::Members;
use C4::Input;
use C4::Date;

my $input        = new CGI;
my $booksellerid = $input->param('booksellerid');
my $title        = $input->param('title');
my $author       = $input->param('author');
my $copyright    = $input->param('copyright');
my @booksellers  = GetBookSeller($booksellerid);
my $count        = scalar @booksellers;
my $ordnum       = $input->param('ordnum');
my $biblionumber       = $input->param('biblionumber');
my $basketno     = $input->param('basketno');
my $suggestionid = $input->param('suggestionid');
my $close        = $input->param('close');
my $data;
my $new;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/neworderempty.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);
my $me= C4::Context->userenv;
my $homebranch=$me->{'branch'} ;
my $branch;
my $bookfundid;
my $discount= $booksellers[0]->{'discount'};
my $gstrate=C4::Context->preference('gist')*100;
if ( $ordnum eq '' ) {    # create order
    $new = 'yes';
    if ( $biblionumber  ) {
	my $record=XMLgetbibliohash($dbh,$biblionumber);
          ###Error checking if a non existent biblionumber given manually
	if (!$record){
	print $input->redirect("/cgi-bin/koha/acqui/basket.pl?supplierid=$booksellerid");
	}
	 $data = XMLmarc2koha_onerecord($dbh,$record,"biblios");
    }elsif($suggestionid){
	$data = GetSuggestion($suggestionid);
    
   	 if ( $data->{'title'} eq '' ) {
        	$data->{'title'}         = $title;
       	 $data->{'author'}        = $author;
       	 $data->{'copyrightdate'} = $copyright;
    	}
   }### if biblionumber
 if ($basketno){
	 my $basket = GetBasket( $basketno);
	my @orders=GetOrders($basketno);
		if (@orders){
		$template->param(
    		purchaseordernumber     =>  $orders[0]->{purchaseordernumber}, );
		}
	$template->param(
    	creationdate     => format_date( $basket->{creationdate} ),
    	authorisedbyname => $basket->{authorisedbyname},);
  }else{
	my @datetoday = localtime();
	my $date = (1900+$datetoday[5])."-".($datetoday[4]+1)."-". $datetoday[3];
	$template->param(
    	creationdate     => format_date($date),
    	authorisedbyname => $loggedinuser,);
  }
}else {    #modify order
    $data   = GetSingleOrder($ordnum);
    $biblionumber = $data->{'biblionumber'};
    #get basketno and suppleirno. too!
    my $data2 = GetBasket( $data->{'basketno'} );
    $basketno     = $data->{'basketno'};
    $booksellerid = $data2->{'booksellerid'};
    $discount=$data->{'discount'};
       $gstrate=$data->{'gst'} ;
    $bookfundid =$data->{'bookfundid'};
 my $aqbookfund=GetBookFund($data->{'bookfundid'});
$branch=$aqbookfund->{branchcode};
$template->param(	
	purchaseordernumber     =>  $data->{purchaseordernumber},
    	creationdate     => format_date( $data2->{creationdate} ),
    	authorisedbyname => $data2->{authorisedbyname},);
	
}



# get currencies (for exchange rates calcs if needed)
my @rates = GetCurrencies();
my $count = scalar @rates;

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency} = $rates[$i]->{'currency'};
    $line{rate}     = $rates[$i]->{'rate'};
    push @loop_currency, \%line;
}





# build branches list
my $branches = GetBranches;
my @branchloop;
foreach my $thisbranch ( sort keys %$branches ) {
my $selected=1 if $thisbranch eq $branch;
     my %row = ( 
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
	selected=>$selected ,
    );
    push @branchloop, \%row;
}
$template->param( branchloop => \@branchloop );

# build bookfund list

my $count2;
my @bookfund;
my @select_bookfund;
my %select_bookfunds;
my $selbookfund;
@bookfund = GetBookFunds($homebranch);
$count2 = scalar @bookfund;

for ( my $i = 0 ; $i < $count2 ; $i++ ) {
    push @select_bookfund, $bookfund[$i]->{'bookfundid'};
    $select_bookfunds{ $bookfund[$i]->{'bookfundid'} } =
      $bookfund[$i]->{'bookfundname'};
	if ($bookfund[$i]->{'bookfundid'} eq $bookfundid){
	$selbookfund=1;
	}
}
my $CGIbookfund = CGI::scrolling_list(
    -name     => 'bookfundid',
    -values   => \@select_bookfund,
    -default  => $data->{'bookfundid'},
    -labels   => \%select_bookfunds,
    -size     => 1,
    -selected =>$selbookfund,
    -multiple => 0
);

my $bookfundname;

if ($close) {
    $bookfundid   = $data->{'bookfundid'};
    $bookfundname = $select_bookfunds{$bookfundid};
}

#Build sort lists
my $CGIsort1 = buildCGIsort( "Asort1", "sort1", $data->{'sort1'} );
if ($CGIsort1) {
    $template->param( CGIsort1 => $CGIsort1 );
}
else {
    $template->param( sort1 => $data->{'sort1'} );
}

my $CGIsort2 = buildCGIsort( "Asort2", "sort2", $data->{'sort2'} );
if ($CGIsort2) {
    $template->param( CGIsort2 => $CGIsort2 );
}
else {
    $template->param( sort2 => $data->{'sort2'} );
}

my $bibitemsexists;

#

    $template->param( bibitemexists => "1" ) if $biblionumber;
	 my @bibitemloop;
          my %line;
        $line{isbn}             = $data->{'isbn'};
        $line{itemtype}         = $data->{'itemtype'};
        $line{volumeddesc}      = $data->{'volumeddesc'};
        push( @bibitemloop, \%line );

        $template->param( bibitemloop => \@bibitemloop );
    


# fill template
$template->param(
    close        => $close,
    bookfundid   => $bookfundid,
    bookfundname => $bookfundname
  )
  if ($close);

$template->param(
    existing         => $biblionumber,
    ordnum           => $ordnum,
    basketno         => $basketno,
    booksellerid     => $booksellerid,
    suggestionid     => $suggestionid,
    biblionumber           => $biblionumber,
    itemtype         => $data->{'itemtype'},
    discount         => $discount,
    listincgst       => $booksellers[0]->{'listincgst'},
    listprice        => $booksellers[0]->{'listprice'},
    gstreg           => $booksellers[0]->{'gstreg'},
    invoiceinc       => $booksellers[0]->{'invoiceincgst'},
    invoicedisc      => $booksellers[0]->{'invoicedisc'},
    nocalc           => $booksellers[0]->{'nocalc'},
    name             => $booksellers[0]->{'name'},
    currency         => $booksellers[0]->{'listprice'},
    gstrate          =>$gstrate,
    loop_currencies  => \@loop_currency,
    orderexists      => ( $new eq 'yes' ) ? 0 : 1,
    title            => $data->{'title'},
    author           => $data->{'author'},
    copyrightdate    => $data->{'copyrightdate'},
    CGIbookfund      => $CGIbookfund,
    isbn             => $data->{'isbn'},
    seriestitle      => $data->{'seriestitle'},
    quantity         => $data->{'quantity'},
    listprice        => $data->{'listprice'},
    rrp              => $data->{'rrp'},
    invoice          => $data->{'booksellerinvoicenumber'},
    ecost            => $data->{'ecost'},
    total		=>$data->{'unitprice'}* $data->{'quantity'},
  unitprice            => $data->{'unitprice'},
 gst        => $data->{'ecost'}*$gstrate/100,
    notes            => $data->{'notes'},
    publishercode    => $data->{'publishercode'},
#     donation         => $donation
);

output_html_with_http_headers $input, $cookie, $template->output;
