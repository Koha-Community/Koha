#!/usr/bin/perl

# Copyright 2006 Katipo Communications
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

use C4::Context;
use strict;
use CGI;
use C4::Auth;
use C4::Output;

my $dbh      = C4::Context->dbh;
my $input    = new CGI;
my $bookfund = $input->param('bookfund');
my $start    = $input->param('start');
my $end      = $input->param('end');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/bookfund.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

my $query = '
SELECT quantity,
       datereceived,
       freight,
       unitprice,
       listprice,
       ecost,
       quantityreceived AS qrev,
       subscription,
       title,
       itemtype,
       aqorders.biblionumber,
       aqorders.booksellerinvoicenumber,
       quantity-quantityreceived AS tleft,
       aqorders.ordernumber AS ordnum,
       entrydate,
       budgetdate,
       booksellerid,
       aqbasket.basketno
  FROM aqorders
    INNER JOIN aqorderbreakdown
      ON aqorderbreakdown.ordernumber = aqorders.ordernumber
    INNER JOIN aqbasket
      ON aqbasket.basketno = aqorders.basketno
    LEFT JOIN biblioitems
      ON biblioitems.biblioitemnumber = aqorders.biblioitemnumber
  WHERE bookfundid = ?
    AND budgetdate >= ?
    AND budgetdate < ?
    AND (datecancellationprinted IS NULL
         OR datecancellationprinted = \'0000-00-00\')
';
my $sth = $dbh->prepare($query);
$sth->execute( $bookfund, $start, $end );
my @commited_loop;

my $total = 0;
while ( my $data = $sth->fetchrow_hashref ) {
    my $left = $data->{'tleft'};
    if ( !$left || $left eq '' ) {
        $left = $data->{'quantity'};
    }
    if ( $left && $left > 0 ) {
        my $subtotal = $left * $data->{'ecost'};
        $data->{subtotal} = sprintf("%.2f",$subtotal);
        $data->{'left'} = $left;
        push @commited_loop, $data;
        $total += $subtotal;
    }
}

$template->param(
    COMMITTEDLOOP => \@commited_loop,
    total        =>  sprintf("%.2f",$total),
);
$sth->finish;
$dbh->disconnect;

output_html_with_http_headers $input, $cookie, $template->output;
