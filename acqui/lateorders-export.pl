#!/usr/bin/perl

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

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Auth;
use C4::Acquisition;
use C4::Output;
use C4::Context;

my $input = new CGI;
my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => "acqui/csv/lateorders.tt",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => {acquisition => 'order_receive'},
});
my @ordernumbers = $input->multi_param('ordernumber');

my @orders;
for my $ordernumber ( @ordernumbers ) {
    my $order = GetOrder $ordernumber;
    push @orders, {
            orderdate => $order->{orderdate},
            latesince => $order->{latesince},
            estimateddeliverydate => $order->{estimateddeliverydate},
            supplier => $order->{supplier},
            supplierid => $order->{supplierid},
            title => $order->{title},
            author => $order->{author},
            publisher => $order->{publisher},
            unitpricesupplier => $order->{unitpricesupplier},
            quantity_to_receive => $order->{quantity_to_receive},
            subtotal => $order->{subtotal},
            budget => $order->{budget},
            basketname => $order->{basketname},
            basketno => $order->{basketno},
            claims_count => $order->{claims_count},
            claimed_date => $order->{claimed_date},
        }
    ;
}

print $input->header(
    -type       => 'text/csv',
    -attachment => 'lateorders.csv',
);
$template->param( orders => \@orders );
for my $line ( split '\n', $template->output ) {
    print "$line\n" unless $line =~ m|^\s*$|;
}
