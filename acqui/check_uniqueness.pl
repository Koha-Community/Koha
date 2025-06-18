#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

# This script search in items table if a value for a given field exists.
# It is used in check_additem (additem.js)
# Parameters are a list of 'field', which must be field names in items table
# and a list of 'value', which are the corresponding value to check
# Eg. @field = ('barcode', 'barcode', 'stocknumber')
#     @value = ('1234', '1235', 'ABC')
#     The script will check if there is already an item with barcode '1234',
#     then an item with barcode '1235', and finally check if there is an item
#     with stocknumber 'ABC'
# It returns a JSON string which contains what have been found
# Eg. { barcode: ['1234', '1235'], stocknumber: ['ABC'] }

use Modern::Perl;

use CGI        qw ( -utf8 );
use JSON       qw( to_json );
use C4::Output qw( output_with_http_headers );
use C4::Items  qw( SearchItems );
use C4::Auth   qw( check_cookie_auth );

my $input = CGI->new;
my ($auth_status) =
    check_cookie_auth( $input->cookie('CGISESSID'), { catalogue => 1 } );
if ( $auth_status ne "ok" ) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit 0;
}

my @field = $input->multi_param('field[]');
my @value = $input->multi_param('value[]');

my $r = {};
my $i = 0;
for ( my $i = 0 ; $i < @field ; $i++ ) {
    my ($items) = C4::Items::SearchItems( { field => $field[$i], query => $value[$i] } );

    if (@$items) {
        push @{ $r->{ $field[$i] } }, $value[$i];
    }
}

output_with_http_headers $input, undef, to_json($r), 'json';
