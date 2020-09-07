#!/usr/bin/perl

# Copyright 2015 Koha Development team
#
# This file is part of Koha
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
use Test::More tests => 1;
use LWP::Simple;
use JSON;
my $content  = get("https://openlibrary.org/search.json?q=9780201038095");

SKIP: {
    skip "json has not been retrieved from openlibrary.org", 1 unless defined $content;
    my $data     = from_json($content);
    my $numFound = $data->{numFound};

    ok( $numFound > 0, "The openlibrary ws should return at least 1 result" );
}
