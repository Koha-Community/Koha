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

use Koha::CsvProfile;
use Koha::CsvProfiles;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_csv_profiles = Koha::CsvProfiles->search->count;
my $new_csv_profile_1 = Koha::CsvProfile->new({
    profile => 'my_csv_profile_name_for_test_1',
    description => 'my_csv_profile_description_for_test_1',
    type => 'sql',
    used_for => 'late_issues',
    content => 'a content',
})->store;
my $new_csv_profile_2 = Koha::CsvProfile->new({
    profile => 'my_csv_profile_name_for_test_2',
    description => 'my_csv_profile_description_for_test_2',
    type => 'marc',
    content => 'another content',
})->store;

like( $new_csv_profile_1->export_format_id, qr|^\d+$|, 'Adding a new csv_profile should have set the export_format_id');
is( Koha::CsvProfiles->search->count, $nb_of_csv_profiles + 2, 'The 2 csv profiles should have been added' );

my $retrieved_csv_profile_1 = Koha::CsvProfiles->find( $new_csv_profile_1->export_format_id );
is( $retrieved_csv_profile_1->profile, $new_csv_profile_1->profile, 'Find a csv_profile by id should return the correct csv_profile' );

$retrieved_csv_profile_1->delete;
is( Koha::CsvProfiles->search->count, $nb_of_csv_profiles + 1, 'Delete should have deleted the csv_profile' );

$schema->storage->txn_rollback;

