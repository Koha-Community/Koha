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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Context;

use Text::CSV::Encoded;
use open qw/ :std :utf8 /;

my $csv = Text::CSV::Encoded->new ({
        encoding    => undef,
        quote_char  => '"',
        escape_char => '"',
        sep_char    => ',',
        binary      => 1,
    });

my $query        = new CGI;
my @ordernumbers = $query->param('ordernumber');

print $query->header(
    -type       => 'text/csv',
    -attachment => "lateorders.csv",
);

print "LATE ORDERS\n\n";
print "ORDER DATE,ESTIMATED DELIVERY DATE,VENDOR,INFORMATION,TOTAL COST,BASKET,CLAIMS COUNT,CLAIMED DATE\n";

for my $ordernumber ( @ordernumbers ) {
    my $order = GetOrder $ordernumber;
    $csv->combine(
        "(" . $order->{supplierid} . ") " . $order->{orderdate} . " (" . $order->{latesince} . " days)",
        $order->{estimateddeliverydate},
        $order->{supplier},
        $order->{title} . ( $order->{author} ? " Author: $order->{author}" : "" ) . ( $order->{publisher} ? " Published by: $order->{publisher}" : "" ),
        $order->{unitpricesupplier} . "x" . $order->{quantity_to_receive} . " = " . $order->{subtotal} . " (" . $order->{budget} . ")",
        $order->{basketname} . " (" . $order->{basketno} . ")",
        $order->{claims_count},
        $order->{claimed_date}
    );
    my $string = $csv->string;
    print $string, "\n";
}

print ",,Total Number Late, " . scalar @ordernumbers . "\n";
