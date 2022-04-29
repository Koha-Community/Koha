#! /usr/bin/perl

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
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::CurbsidePickupPolicies;
use Koha::Libraries;

my $input       = CGI->new;
my $op          = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/curbside_pickup.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_curbside_pickups' },
    }
);

my $libraries = Koha::Libraries->search( {}, { order_by => ['branchname'] } );
if ( $op eq 'save' ) {
    foreach my $library ( $libraries->as_list ) {
        my $branchcode = $library->branchcode;

        my $params = {

            branchcode      => $branchcode,
            enabled         => scalar $input->param("enable-$branchcode") || 0,
            pickup_interval => scalar $input->param("interval-$branchcode"),
            patrons_per_interval    => scalar $input->param("max-per-interval-$branchcode"),
            patron_scheduled_pickup => scalar $input->param("patron-scheduled-$branchcode") || 0,
        };

        for my $day (
            qw( sunday monday tuesday wednesday thursday friday saturday ))
        {
            for my $start_end (qw( start end )) {
                for my $hour_min (qw( hour minute )) {

                    my $value = $input->param(
                        "pickup-$start_end-$hour_min-$day-$branchcode");
                    $value = undef if $value eq q{};

                    my $key = $day . '_' . $start_end . '_' . $hour_min;

                    $params->{$key} = $value;
                }
            }
        }

        my $CurbsidePickupPolicy =
          Koha::CurbsidePickupPolicies->find( { branchcode => $branchcode } );
        $CurbsidePickupPolicy->delete if $CurbsidePickupPolicy;

        Koha::CurbsidePickupPolicy->new($params)->store();
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    $template->param(
        policies => {
            map { $_->branchcode => $_ }
              Koha::CurbsidePickupPolicies->search->as_list
        },
        libraries => $libraries,
    );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
