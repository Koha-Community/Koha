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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use Encode;

use C4::Auth        qw( get_template_and_user );
use C4::Acquisition qw( GetOrder );
use C4::Output;
use C4::Context;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "acqui/csv/lateorders.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { acquisition => 'order_receive' },
    }
);
my @ordernumbers = $input->multi_param('ordernumber');

my $csv_profile_id = $input->param('csv_profile');

unless ($csv_profile_id) {
    my @orders;
    for my $ordernumber (@ordernumbers) {
        my $order        = GetOrder $ordernumber;
        my $order_object = Koha::Acquisition::Orders->find($ordernumber);
        my $claims       = $order_object->claims;
        push @orders, {
            orderdate             => $order->{orderdate},
            latesince             => $order->{latesince},
            estimateddeliverydate => $order->{estimated_delivery_date} || $order->{calculateddeliverydate},
            supplier              => $order->{supplier},
            supplierid            => $order->{supplierid},
            title                 => $order->{title},
            author                => $order->{author},
            publisher             => $order->{publisher},
            unitpricesupplier     => $order->{unitpricesupplier},
            quantity_to_receive   => $order->{quantity_to_receive},
            subtotal              => $order->{subtotal},
            budget                => $order->{budget},
            basketname            => $order->{basketname},
            basketno              => $order->{basketno},
            claims_count          => $claims->count,
            claimed_date          => $claims->count ? $claims->last->claimed_on : undef,
            internalnote          => $order->{order_internalnote},
            vendornote            => $order->{order_vendornote},
            isbn                  => $order->{isbn},
        };
    }

    # We want to export using the default profile, using the template acqui/csv/lateorders.tt
    print $input->header(
        -type       => 'text/csv',
        -attachment => 'lateorders.csv',
    );
    $template->param( orders => \@orders );
    for my $line ( split '\n', $template->output ) {
        print "$line\n" unless $line =~ m|^\s*$|;
    }
    exit;
} else {
    my $csv_profile = Koha::CsvProfiles->find($csv_profile_id);
    my $content     = '[% SET separator = "' . $csv_profile->csv_separator . '" ~%]' . $csv_profile->content;

    my $csv = C4::Letters::_process_tt(
        {
            content => $content,
            loops   => { aqorders => \@ordernumbers },
        }
    );

    print $input->header(
        -type       => 'text/csv',
        -attachment => 'lateorders.csv',
        -charset    => 'UTF-8',
    );
    print Encode::encode_utf8($csv);
    exit;
}
