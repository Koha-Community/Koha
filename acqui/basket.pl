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


use strict;
use C4::Auth;
use C4::Koha;
use C4::Output;
use CGI;
use C4::Acquisition;
use C4::Bookfund;
use C4::Bookseller;
use C4::Dates qw/format_date/;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 1;
}

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

# FIXME : the query->param('supplierid') below is probably useless. The bookseller is always known from the basket
# if no booksellerid in parameter, get it from basket
# warn "=>".$basket->{booksellerid};
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
$debug and warn 
	sprintf "loggedinuser: $loggedinuser; creationdate: %s; authorisedby: %s",
		$basket->{creationdate}, $basket->{authorisedby} ;


my ( $count, @results );
@results  = GetOrders( $basketno, $order );
$count = scalar @results;

my $line_total;     # total of each line
my $sub_total;      # total of line totals
my $gist;           # GST
my $grand_total;    # $subttotal + $gist
my $toggle = 0;


# my $line_total_est; # total of each line
my $sub_total_est;      # total of line totals
my $gist_est;           # GST
my $grand_total_est;    # $subttotal + $gist

my $qty_total;
my @books_loop;
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my $rrp = $results[$i]->{'listprice'};
    $rrp = ConvertCurrency( $results[$i]->{'currency'}, $rrp );

    $sub_total_est += $results[$i]->{'quantity'} * $results[$i]->{'rrp'};
    $line_total = $results[$i]->{'quantity'} * $results[$i]->{'ecost'};
    $sub_total += $line_total;
    $qty_total += $results[$i]->{'quantity'};
    my %line;
    %line=%{$results[$i]};
   if ( $toggle == 0 ) {
        $line{color} = '#EEEEEE';
        $toggle = 1;
    }
    else {
        $line{color} = 'white';
        $toggle = 0;
    }
	$line{publishercode} 	= $results[$i]->{'publishercode'};
	$line{basketno}         = $basketno;
    $line{i}                = $i;
    $line{rrp}              = sprintf( "%.2f", $line{'rrp'} );
    $line{ecost}            = sprintf( "%.2f", $line{'ecost'} );
    $line{line_total}       = sprintf( "%.2f", $line_total );
    $line{odd}              = $i % 2;
    push @books_loop, \%line;
}
my $prefgist = C4::Context->preference("gist");
$gist            = sprintf( "%.2f", $sub_total * $prefgist );
$grand_total     = $sub_total + $gist;
$grand_total_est =
  $sub_total_est + sprintf( "%.2f", $sub_total_est * $prefgist );
$gist_est = sprintf( "%.2f", $sub_total_est * $prefgist );
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
    sub_total        => $sub_total,
    gist             => $gist,
    grand_total      => $grand_total,
    sub_total_est    => $sub_total_est,
    gist_est         => $gist_est,
    grand_total_est  => $grand_total_est,
    currency         => $booksellers[0]->{'listprice'},
    qty_total        => $qty_total,
    GST => C4::Context->preference("gist"),
);
output_html_with_http_headers $query, $cookie, $template->output;
