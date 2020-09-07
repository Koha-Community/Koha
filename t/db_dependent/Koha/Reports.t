#!/usr/bin/perl

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

use Koha::Report;
use Koha::Reports;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_reports = Koha::Reports->search->count;
my $new_report_1 = Koha::Report->new({
    report_name => 'report_name_for_test_1',
    savedsql => 'SELECT "I wrote a report"',
})->store;
my $new_report_2 = Koha::Report->new({
    report_name => 'report_name_for_test_1',
    savedsql => 'SELECT "Oops, I did it again"',
})->store;

like( $new_report_1->id, qr|^\d+$|, 'Adding a new report should have set the id');
is( Koha::Reports->search->count, $nb_of_reports + 2, 'The 2 reports should have been added' );

my $retrieved_report_1 = Koha::Reports->find( $new_report_1->id );
is( $retrieved_report_1->report_name, $new_report_1->report_name, 'Find a report by id should return the correct report' );

$retrieved_report_1->delete;
is( Koha::Reports->search->count, $nb_of_reports + 1, 'Delete should have deleted the report' );

$schema->storage->txn_rollback;
