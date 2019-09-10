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

use Koha::Illrequest::Availability;

use Test::More tests => 3;

use_ok('Koha::Illrequest::Availability');

my $metadata = {
    title  => 'This is a title',
    author => 'This is an author'
};

# Because hashes can reorder themselves, we need to make sure ours is in a
# predictable order
my $sorted = {};
foreach my $key( keys %{$metadata} ) {
    $sorted->{$key} = $metadata->{$key};
}

my $availability = Koha::Illrequest::Availability->new($sorted);

isa_ok( $availability, 'Koha::Illrequest::Availability' );

is(
    $availability->prep_metadata($sorted),
    'eyJhdXRob3IiOiJUaGlzIGlzIGFuIGF1dGhvciIsInRpdGxlIjoiVGhpcyBpcyBhIHRpdGxlIn0%3D%0A',
    'prep_metadata works'
);
