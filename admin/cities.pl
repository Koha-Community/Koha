#!/usr/bin/perl

# Copyright 2006 SAN OUEST-PROVENCE et Paul POULAIN
# Copyright 2015 Koha Development Team
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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Cities;

my $input       = CGI->new;
my $city_name_filter = $input->param('city_name_filter') // q||;
my $cityid      = $input->param('cityid');
my $op          = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "admin/cities.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_cities' },
    }
);

my $dbh = C4::Context->dbh;
if ( $op eq 'add_form' ) {
    my $city;
    if ($cityid) {
        $city = Koha::Cities->find($cityid);
    }

    $template->param( city => $city, );
} elsif ( $op eq 'add_validate' ) {
    my $city_name    = $input->param('city_name');
    my $city_state   = $input->param('city_state');
    my $city_zipcode = $input->param('city_zipcode');
    my $city_country = $input->param('city_country');

    if ($cityid) {
        my $city = Koha::Cities->find($cityid);
        $city->city_name($city_name);
        $city->city_state($city_state);
        $city->city_zipcode($city_zipcode);
        $city->city_country($city_country);
        eval { $city->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $city = Koha::City->new(
            {   city_name    => $city_name,
                city_state   => $city_state,
                city_zipcode => $city_zipcode,
                city_country => $city_country,
            }
        );
        eval { $city->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }
    $city_name = q||;
    $op        = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $city = Koha::Cities->find($cityid);
    $template->param( city => $city, );
} elsif ( $op eq 'delete_confirmed' ) {
    my $city = Koha::Cities->find($cityid);
    my $deleted = eval { $city->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    $template->param( cities_count => Koha::Cities->search->count );
}

$template->param(
    cityid      => $cityid,
    city_name_filter => $city_name_filter,
    messages    => \@messages,
    op          => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
