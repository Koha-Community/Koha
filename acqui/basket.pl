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

# $Id$

use strict;
use C4::Auth;
use C4::Koha;
use CGI;
use C4::Interface::CGI::Output;
use C4::Acquisition;
use C4::Bookfund;
use C4::Bookseller;
use C4::Date;

=head1 NAME

basket.pl

=head1 DESCRIPTION

 This script display all informations about basket for the supplier given
 on input arg. Moreover, it allow to add a new order for this supplier from
 an existing record, a suggestion or from a new record.

=head1 CGI PARAMETERS

=over 4

=item $basketno

this parameter seems to be unused.

=item supplierid

the supplier this script have to display the basket.

=item order



=back

=cut

my $query        = new CGI;
my $basketno     = $query->param('basketno');
my $booksellerid = $query->param('supplierid');
my $order        = $query->param('order');
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/basket.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

my $basket = GetBasket($basketno);
$basket->{authorisedbyname};
# FIXME : the query->param('supplierid') below is probably useless. The bookseller is always known from the basket
# if no booksellerid in parameter, get it from basket
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my @booksellers = GetBookSeller($booksellerid);
my $count2 = scalar @booksellers;

# get librarian branch...
if ( C4::Context->preference("IndependantBranches") ) {
    my $userenv = C4::Context->userenv;
    unless ( $userenv->{flags} == 1 ) {
        my $validtest = ( $basket->{creationdate} eq '' )
          || ( $basket->{branch}  eq '' )
          || ( $userenv->{branch} eq $basket->{branch} )
          || ( $userenv->{branch} eq '' )
          || ( $basket->{branch}  eq '' );
        unless ($validtest) {
            print $query->redirect("../mainpage.pl");
            exit 1;
        }
    }
}

# if new basket, pre-fill infos
$basket->{creationdate} = ""            unless ( $basket->{creationdate} );
$basket->{authorisedby} = $loggedinuser unless ( $basket->{authorisedby} );

my ( $count, @results );
@results  = GetOrders( $basketno, $order );
$count = scalar @results;
my $line_total;     # total of each line
my $gist =C4::Context->preference('gist');           # GST 
my $toggle = 0;

# my $line_total_est; # total of each line
my $sub_total_est;      # total of line totals
my $gist_est;           # GST
my $grand_total_est;    # $subttotal + $gist_est - $disc_est
my $disc_est;
my $qty_total;

my @books_loop;
for ( my $i = 0 ; $i < $count ; $i++ ) {
     $line_total = $results[$i]->{'quantity'} * $results[$i]->{'rrp'};
    $sub_total_est += $line_total ;
   $disc_est +=$line_total *$results[$i]->{'discount'}/100;
   $gist_est +=($line_total  - ($line_total *$results[$i]->{'discount'}/100))*$results[$i]->{'gst'}/100;
   
   
    $qty_total += $results[$i]->{'quantity'};
    my %line;
   if ( $toggle == 0 ) {
        $line{color} = '#EEEEEE';
        $toggle = 1;
    }
    else {
        $line{color} = 'white';
        $toggle = 0;
    }
    $line{ordernumber}      = $results[$i]->{'ordernumber'};
    $line{publishercode}    = $results[$i]->{'publishercode'};
    $line{isbn}             = $results[$i]->{'isbn'};
    $line{booksellerid}     = $booksellers[0]->{'id'};
    $line{basketno}         = $basketno;
    $line{title}            = $results[$i]->{'title'};
    $line{notes}            = $results[$i]->{'notes'};
    $line{author}           = $results[$i]->{'author'};
    $line{i}                = $i;
    $line{rrp}              = sprintf( "%.2f", $results[$i]->{'rrp'} );
    $line{ecost}            = sprintf( "%.2f", $results[$i]->{'ecost'} );
      $line{discount}            = sprintf( "%.2f", $results[$i]->{'discount'} );
    $line{quantity}         = $results[$i]->{'quantity'};
    $line{quantityrecieved} = $results[$i]->{'quantityreceived'};
    $line{line_total}       = sprintf( "%.2f", $line_total );
    $line{biblionumber}     = $results[$i]->{'biblionumber'};
    $line{bookfundid}       = $results[$i]->{'bookfundid'};
    $line{odd}              = $i % 2;
if  ($line{quantityrecieved}>0){$line{donotdelete}=1;}
    push @books_loop, \%line;
$template->param(purchaseordernumber    => $results[0]->{'purchaseordernumber'},
		booksellerinvoicenumber=>$results[0]->{booksellerinvoicenumber},);
}
$grand_total_est =  sprintf( "%.2f", $sub_total_est - $disc_est+$gist_est );

$template->param(
    basketno         => $basketno,
    creationdate     => format_date( $basket->{creationdate} ),
    authorisedby     => $basket->{authorisedby},
    authorisedbyname => $basket->{authorisedbyname},
    closedate        => format_date( $basket->{closedate} ),
    active           => $booksellers[0]->{'active'},
    booksellerid     => $booksellers[0]->{'id'},
    name             => $booksellers[0]->{'name'},
    address1         => $booksellers[0]->{'address1'},
    address2         => $booksellers[0]->{'address2'},
    address3         => $booksellers[0]->{'address3'},
    address4         => $booksellers[0]->{'address4'},
    entrydate        => format_date( $results[0]->{'entrydate'} ),
    books_loop       => \@books_loop,
    count            => $count,
    gist             => $gist,
    sub_total_est    =>  sprintf( "%.2f",$sub_total_est),
    gist_est         =>  sprintf( "%.2f",$gist_est),
    disc_est	=> sprintf( "%.2f",$disc_est),
    grand_total_est  => $grand_total_est,
    currency         => $booksellers[0]->{'listprice'},
    qty_total        => $qty_total,
);
output_html_with_http_headers $query, $cookie, $template->output;
