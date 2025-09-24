#!/usr/bin/perl

# Copyright 2020 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;

use Koha::Import::Record::Matches;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder              = t::lib::TestBuilder->new;
my $nb_of_matches        = Koha::Import::Record::Matches->search->count;
my $nb_of_chosen_matches = Koha::Import::Record::Matches->search( { chosen => 1 } )->count;

my $match_1 = $builder->build( { source => 'ImportRecordMatch', value => { chosen => 1 } } );
my $match_2 = $builder->build(
    { source => 'ImportRecordMatch', value => { chosen => 1, import_record_id => $match_1->{import_record_id} } } );

is( Koha::Import::Record::Matches->search->count, $nb_of_matches + 2, 'The 2 matches should have been added' );

is(
    Koha::Import::Record::Matches->search( { chosen => 1 } )->count, $nb_of_chosen_matches + 2,
    'The 2 chosen matches should have been added'
);

my $retrieved_match_1 = Koha::Import::Record::Matches->search(
    { import_record_id => $match_1->{import_record_id}, candidate_match_id => $match_1->{candidate_match_id} } )->next;
is_deeply(
    $retrieved_match_1->unblessed, $match_1,
    'Find a match by import record id and candidate should return the correct match'
);

$retrieved_match_1->delete;
is( Koha::Import::Record::Matches->search->count, $nb_of_matches + 1, 'Delete should have deleted the match' );

my $retrieved_match_2 = Koha::Import::Record::Matches->search(
    { import_record_id => $match_2->{import_record_id}, candidate_match_id => $match_2->{candidate_match_id} } )->next;
my $import_record = $retrieved_match_2->import_record;
is( ref($import_record),              'Koha::Import::Record',               "import_record has the correct class" );
is( $import_record->import_record_id, $retrieved_match_2->import_record_id, "We have the right record" );

$schema->storage->txn_rollback;
