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

use Test::More tests => 6;

use Koha::Database;
use Koha::Rating;
use Koha::Ratings;

use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $patron_1 = $builder->build( { source => 'Borrower', } );
my $patron_2 = $builder->build( { source => 'Borrower', } );
my $biblio_1 = $builder->build_sample_biblio;
my $biblionumber = $biblio_1->biblionumber;

my $rating_1 = Koha::Rating->new( { biblionumber => $biblionumber, borrowernumber => $patron_1->{borrowernumber}, rating_value => 3 } )->store;
my $rating_2 = Koha::Rating->new( { biblionumber => $biblionumber, borrowernumber => $patron_2->{borrowernumber}, rating_value => 4 } )->store;

is( $biblio_1->ratings->get_avg_rating, 3.5, 'get_avg_rating is 3.5' );

$rating_1->rating_value(5)->store;

is( $biblio_1->ratings->get_avg_rating, 4.5, 'get_avg_rating now up to 4.5' );

$rating_1->rating_value(42)->store;
is( Koha::Ratings->find( { biblionumber => $biblionumber, borrowernumber => $patron_1->{borrowernumber} } )->rating_value,
    5, 'Koha::Ratings->store should mark out the boundaries of the rating values, 5 is max' );

$rating_1->rating_value(-42)->store;
is( Koha::Ratings->find( { biblionumber => $biblionumber, borrowernumber => $patron_1->{borrowernumber} } )->rating_value,
    0, 'Koha::Ratings->store should mark out the boundaries of the rating values, 0 is min' );

Koha::Ratings->find( { biblionumber => $biblionumber, borrowernumber => $patron_1->{borrowernumber} } )->delete;
Koha::Ratings->find( { biblionumber => $biblionumber, borrowernumber => $patron_2->{borrowernumber} } )->delete;
is( $biblio_1->ratings->count, 0, 'Delete should have deleted the ratings' );

is( int($biblio_1->ratings->get_avg_rating), 0, 'get_avg_rating should return 0 if no rating exist' );
