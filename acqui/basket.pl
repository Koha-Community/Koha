#!/usr/bin/perl

# $Id$

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
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Acquisition;
use C4::Date;

my $query =new CGI;
my $basketno = $query ->param('basket');
my $booksellerid = $query->param('supplierid');
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/basket.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });
my ($count,@results);

my $basket = getbasket($basketno);
# FIXME : the query->param('supplierid') below is probably useless. The bookseller is always known from the basket
# if no booksellerid in parameter, get it from basket
# warn "=>".$basket->{booksellerid};
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my ($count2,@booksellers)=bookseller($booksellerid);

# if new basket, pre-fill infos
$basket->{creationdate} = "" unless ($basket->{creationdate});
$basket->{authorisedby} = $loggedinuser unless ($basket->{authorisedby});
($count,@results)=getbasketcontent($basketno);

my $line_total; # total of each line
my $sub_total; # total of line totals
my $gist;      # GST
my $grand_total; # $subttotal + $gist
my $toggle=0;

my @books_loop;
for (my $i=0;$i<$count;$i++){
	my $rrp=$results[$i]->{'listprice'};
	$rrp=curconvert($results[$i]->{'currency'},$rrp);

	$line_total=$results[$i]->{'quantity'}*$results[$i]->{'ecost'};
	$sub_total+=$line_total;
	my %line;
	if ($toggle==0){
		$line{color}='#EEEEEE';
		$toggle=1;
	} else {
		$line{color}='white';
		$toggle=0;
	}
	$line{ordernumber} = $results[$i]->{'ordernumber'};
	$line{publishercode} = $results[$i]->{'publishercode'};
	$line{isbn} = $results[$i]->{'isbn'};
	$line{booksellerid} = $results[$i]->{'booksellerid'};
	$line{basketno}=$basketno;
	$line{title} = $results[$i]->{'title'};
	$line{author} = $results[$i]->{'author'};
	$line{i} = $i;
	$line{rrp} = $results[$i]->{'rrp'};
	$line{ecost} = $results[$i]->{'ecost'};
	$line{quantity} = $results[$i]->{'quantity'};
	$line{quantityrecieved} = $results[$i]->{'quantityreceived'};
	$line{line_total} = $line_total;
	$line{biblionumber} = $results[$i]->{'biblionumber'};
	push @books_loop, \%line;
}
my $prefgist =C4::Context->preference("gist");
$gist=sprintf("%.2f",$sub_total*$prefgist);
$grand_total=$sub_total+$gist;
$template->param(basketno => $basketno,
				creationdate => $basket->{creationdate},
				authorisedby => $basket->{authorisedby},
				authorisedbyname => $basket->{authorisedbyname},
				closedate => format_date($basket->{closedate}),
				booksellerid=> $booksellers[0]->{'id'},
				name => $booksellers[0]->{'name'},
				entrydate => format_date($results[0]->{'entrydate'}),
				books_loop => \@books_loop,
				count =>$count,
				sub_total => $sub_total,
				gist => $gist,
				grand_total =>$grand_total,
				currency => $booksellers[0]->{'listprice'},
				);
output_html_with_http_headers $query, $cookie, $template->output;
