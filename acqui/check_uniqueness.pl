#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

use CGI;
use JSON;
use C4::Context;
use C4::Output;
use C4::Auth;

my $input = new CGI;
my @field = $input->param('field');
my @value = $input->param('value');

my $dbh = C4::Context->dbh;

my $query = "SHOW COLUMNS FROM items";
my $sth = $dbh->prepare($query);
$sth->execute;
my $results = $sth->fetchall_hashref('Field');
my @columns = keys %$results;

my $r = {};
my $index = 0;
for my $f ( @field ) {
    if(0 < grep /^$f$/, @columns) {
        $query = "SELECT $f FROM items WHERE $f = ?";
        $sth = $dbh->prepare( $query );
        $sth->execute( $value[$index] );
        my @values = $sth->fetchrow_array;

        if ( @values ) {
            push @{ $r->{$f} }, $values[0];
        }
    }
    $index++;
}

output_with_http_headers $input, undef, to_json($r), 'json';
