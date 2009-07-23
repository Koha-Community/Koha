#!/usr/bin/perl

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000

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

acqui-search-result.pl

=head1 DESCRIPTION
 TODO
 
=head1 PARAMETERS

=over 4

=item supplier

=back

=cut


use strict;
use C4::Auth;
use C4::Biblio;
use C4::Output;
use CGI;
use C4::Acquisition;
use C4::Dates qw/format_date/;
use C4::Bookseller;

my $query=new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "serials/acqui-search-result.tmpl",
                 query => $query,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {serials => 1},
                 debug => 1,
                 });

my $supplier=$query->param('supplier');
my @suppliers = GetBookSeller($supplier);
my $count = scalar @suppliers;

#build result page
my @loop_suppliers;
for (my $i=0; $i<$count; $i++) {
    my $orders = GetPendingOrders($suppliers[$i]->{'id'});
    my $ordcount = scalar @$orders;
    
    my %line;
    $line{aqbooksellerid} =$suppliers[$i]->{'id'};
    $line{name} = $suppliers[$i]->{'name'};
    $line{active} = $suppliers[$i]->{'active'};
    my @loop_basket;
    for (my $i2=0;$i2<$ordcount;$i2++){
        my %inner_line;
        $inner_line{basketno} =$orders->[$i2]->{'basketno'};
        $inner_line{total} =$orders->[$i2]->{'count(*)'};
        $inner_line{authorisedby} = $orders->[$i2]->{'authorisedby'};
        $inner_line{creationdate} = format_date($orders->[$i2]->{'creationdate'});
        $inner_line{closedate} = format_date($orders->[$i2]->{'closedate'});
        push @loop_basket, \%inner_line;
    }
    $line{loop_basket} = \@loop_basket;
    push @loop_suppliers, \%line;
}
$template->param(loop_suppliers => \@loop_suppliers,
                        supplier => $supplier,
                        count => $count);

output_html_with_http_headers $query, $cookie, $template->output;
