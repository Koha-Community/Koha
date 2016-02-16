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

use Test::More tests => 4;

use Koha::Review;
use Koha::Reviews;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $patron_1 = $builder->build({ source => 'Borrower' });
my $patron_2 = $builder->build({ source => 'Borrower' });
my $biblio_1 = $builder->build({ source => 'Biblio' });
my $biblio_2 = $builder->build({ source => 'Biblio' });
my $nb_of_reviews = Koha::Reviews->search->count;
my $new_review_1_1 = Koha::Review->new({
    borrowernumber => $patron_1->{borrowernumber},
    biblionumber => $biblio_1->{biblionumber},
    review => 'a kind review',
})->store;
my $new_review_1_2 = Koha::Review->new({
    borrowernumber => $patron_1->{borrowernumber},
    biblionumber => $biblio_2->{biblionumber},
    review => 'anoter kind review',
})->store;
my $new_review_2_1 = Koha::Review->new({
    borrowernumber => $patron_2->{borrowernumber},
    biblionumber => $biblio_1->{biblionumber},
    review => 'just anoter review',
})->store;

like( $new_review_1_1->reviewid, qr|^\d+$|, 'Adding a new review should have set the reviewid');
is( Koha::Reviews->search->count, $nb_of_reviews + 3, 'The 3 reviews should have been added' );

my $retrieved_review_1_1 = Koha::Reviews->find( $new_review_1_1->reviewid );
is( $retrieved_review_1_1->review, $new_review_1_1->review, 'Find a review by id should return the correct review' );

$retrieved_review_1_1->delete;
is( Koha::Reviews->search->count, $nb_of_reviews + 2, 'Delete should have deleted the review' );

$schema->storage->txn_rollback;

1;
