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

use Test::More tests => 6;

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

subtest 'prep_report' => sub {
    plan tests => 4;

    my $report = Koha::Report->new({
        report_name => 'report_name_for_test_1',
        savedsql => 'SELECT * FROM items WHERE itemnumber IN <<Test|list>>',
    })->store;
    my $id = $report->id;

    my ($sql, undef) = $report->prep_report( ['Test|list'],["1\n12\n\r243"] );
    is( $sql, qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') /* saved_sql.id: $id */},'Expected sql generated correctly with single param and name');

    $report->savedsql('SELECT * FROM items WHERE itemnumber IN <<Test|list>> AND <<Another>> AND <<Test|list>>')->store;

    ($sql, undef) = $report->prep_report( ['Test|list','Another'],["1\n12\n\r243",'the other'] );
    is( $sql, qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') AND 'the other' AND ('1','12','243') /* saved_sql.id: $id */},'Expected sql generated correctly with multiple params and names');

    ($sql, undef) = $report->prep_report( [],["1\n12\n\r243",'the other',"42\n32\n22\n12"] );
    is( $sql, qq{SELECT * FROM items WHERE itemnumber IN ('1','12','243') AND 'the other' AND ('42','32','22','12') /* saved_sql.id: $id */},'Expected sql generated correctly with multiple params and no names');

    $report->savedsql(
        q{SELECT  i.itemnumber, i.itemnumber as Exemplarnummber, [[i.itemnumber| itemnumber for batch]] FROM items})
        ->store;
    my $headers;
    ( $sql, $headers ) = $report->prep_report( [], [] );
    is_deeply( $headers, { 'itemnumber for batch' => 'itemnumber' } );
};

$schema->storage->txn_rollback;

subtest 'is_sql_valid' => sub {
    plan tests => 3 + 6 * 2;
    my @badwords = ( 'UPDATE', 'DELETE', 'DROP', 'INSERT', 'SHOW', 'CREATE' );
    is_deeply(
        [ Koha::Report->new( { savedsql => '' } )->is_sql_valid ],
        [ 0, [ { queryerr => 'Missing SELECT' } ] ],
        'Empty sql is missing SELECT'
    );
    is_deeply(
        [ Koha::Report->new( { savedsql => 'FOO' } )->is_sql_valid ],
        [ 0, [ { queryerr => 'Missing SELECT' } ] ],
        'Nonsense sql is missing SELECT'
    );
    is_deeply(
        [ Koha::Report->new( { savedsql => 'select FOO' } )->is_sql_valid ],
        [ 1, [] ],
        'select FOO is good'
    );
    foreach my $word (@badwords) {
        is_deeply(
            [
                Koha::Report->new(
                    { savedsql => 'select FOO;' . $word . ' BAR' }
                )->is_sql_valid
            ],
            [ 0, [ { sqlerr => $word } ] ],
            'select FOO with ' . $word . ' BAR'
        );
        is_deeply(
            [
                Koha::Report->new( { savedsql => $word . ' qux' } )
                  ->is_sql_valid
            ],
            [ 0, [ { sqlerr => $word } ] ],
            $word . ' qux'
        );
    }
  }
