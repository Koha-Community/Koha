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

use Test::More tests => 8;

use Koha::Patrons;
use Koha::Reviews;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $patron_1 = $builder->build({ source => 'Borrower', value => { flags => undef } });
my $patron_2 = $builder->build({ source => 'Borrower' });
$patron_1 = Koha::Patrons->find( $patron_1->{borrowernumber} );
$patron_2 = Koha::Patrons->find( $patron_2->{borrowernumber} );
my $biblio_1 = $builder->build({ source => 'Biblio' });
my $biblio_2 = $builder->build({ source => 'Biblio' });
my $nb_of_reviews = Koha::Reviews->search->count;
my $nb_of_approved_reviews = Koha::Reviews->search({ approved => 1 })->count;
my $new_review_1_1 = Koha::Review->new({
    borrowernumber => $patron_1->borrowernumber,
    biblionumber => $biblio_1->{biblionumber},
    review => 'a kind review',
})->store;
my $new_review_1_2 = Koha::Review->new({
    borrowernumber => $patron_1->borrowernumber,
    biblionumber => $biblio_2->{biblionumber},
    review => 'anoter kind review',
})->store;
my $new_review_2_1 = Koha::Review->new({
    borrowernumber => $patron_2->borrowernumber,
    biblionumber => $biblio_1->{biblionumber},
    review => 'just anoter review',
})->store;

like( $new_review_1_1->reviewid, qr|^\d+$|, 'Adding a new review should have set the reviewid');
is( Koha::Reviews->search->count, $nb_of_reviews + 3, 'The 3 reviews should have been added' );

is( Koha::Reviews->search({approved => 1})->count, $nb_of_approved_reviews, 'There should not be new approved reviews' );
$new_review_1_1->approve;
is( Koha::Reviews->search({approved => 1})->count, $nb_of_approved_reviews + 1, 'There should be 1 new approved review' );
$new_review_1_1->unapprove;
is( Koha::Reviews->search({approved => 1})->count, $nb_of_approved_reviews, 'There should not be any new approved review anymore' );

my $retrieved_review_1_1 = Koha::Reviews->find( $new_review_1_1->reviewid );
is( $retrieved_review_1_1->review, $new_review_1_1->review, 'Find a review by id should return the correct review' );

subtest 'search_limited' => sub {
    plan tests => 2;
    C4::Context->_new_userenv('xxx');
    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1' } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2' } )->store;
    Koha::Library::Group->new({ parent_id => $group_1->id,  branchcode => $patron_1->branchcode })->store();
    Koha::Library::Group->new({ parent_id => $group_2->id,  branchcode => $patron_2->branchcode })->store();
    set_logged_in_user( $patron_1 );
    is( Koha::Reviews->search->count, $nb_of_approved_reviews + 3, 'Koha::Reviews->search should return all reviews' );
    is( Koha::Reviews->search_limited->count, $nb_of_approved_reviews + 2, 'Koha::Reviews->search_limited should return reviews depending on patron permissions' );
};

$retrieved_review_1_1->delete;
is( Koha::Reviews->search->count, $nb_of_reviews + 2, 'Delete should have deleted the review' );

$schema->storage->txn_rollback;

sub set_logged_in_user {
    my ($patron) = @_;
    C4::Context->set_userenv(
        $patron->borrowernumber, $patron->userid,
        $patron->cardnumber,     'firstname',
        'surname',               $patron->library->branchcode,
        'Midway Public Library', $patron->flags,
        '',                      ''
    );
}
