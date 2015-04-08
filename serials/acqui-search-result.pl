#!/usr/bin/perl

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.


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
use warnings;
use C4::Auth;
use C4::Biblio;
use C4::Output;
use CGI;
use C4::Acquisition qw( SearchOrders );
use C4::Dates qw/format_date/;
use C4::Bookseller qw( GetBookSeller );

my $query=new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "serials/acqui-search-result.tt",
                 query => $query,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {serials => '*'},
                 debug => 1,
                 });

my $supplier=$query->param('supplier');
my @suppliers = GetBookSeller($supplier);
#my $count = scalar @suppliers;

#build result page
my $loop_suppliers = [];
for my $s (@suppliers) {
    my $orders = SearchOrders({
        booksellerid => $s->{'id'},
        pending => 1
    });

    my $loop_basket = [];
    for my $ord ( @{$orders} ) {
        push @{$loop_basket}, {
            basketno     => $ord->{'basketno'},
            total        => $ord->{'count(*)'},
            authorisedby => $ord->{'authorisedby'},
            creationdate => format_date($ord->{'creationdate'}),
            closedate    => format_date($ord->{'closedate'}),
        };
    }
    push @{$loop_suppliers}, {
        loop_basket => $loop_basket,
        aqbooksellerid => $s->{'id'},
        name => $s->{'name'},
        active => $s->{'active'},
    };
}

$template->param(loop_suppliers => $loop_suppliers,
                        supplier => $supplier,
                        count => scalar @suppliers);

output_html_with_http_headers $query, $cookie, $template->output;
