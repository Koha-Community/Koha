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

use Test::More tests => 18;
use Test::Warn;
use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('C4::Reports::Guided');
}
can_ok(
    'C4::Reports::Guided',
    qw(save_report delete_report execute_query)
);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM saved_sql|);
$dbh->do(q|DELETE FROM saved_reports|);

#Start tests

#Test save_report
my $count = scalar @{ get_saved_reports() };
is( $count, 0, "There is no report" );

my @report_ids;
foreach ( 1..3 ) {
    my $id = $builder->build({ source => 'Borrower' })->{ borrowernumber };
    push @report_ids, save_report({
        borrowernumber => $id,
        sql            => "SQL$id",
        name           => "Name$id",
        area           => "area$id",
        group          => "group$id",
        subgroup       => "subgroup$id",
        type           => "type$id",
        notes          => "note$id",
        cache_expiry   => "null",
        public         => "null"
    });
    $count++;
}
like( $report_ids[0], '/^\d+$/', "Save_report returns an id for first" );
like( $report_ids[1], '/^\d+$/', "Save_report returns an id for second" );
like( $report_ids[2], '/^\d+$/', "Save_report returns an id for third" );

is( scalar @{ get_saved_reports() },
    $count, "$count reports have been added" );

is( scalar @{ get_saved_reports( $report_ids[0] ) },
    1, "filter takes report id" );

#Test delete_report
is (delete_report(),undef, "Without id delete_report returns undef");

is( delete_report( $report_ids[0] ), 1, "report 1 is deleted" );
$count--;

is( scalar @{ get_saved_reports() }, $count, "Report1 has been deleted" );

is( delete_report( $report_ids[1], $report_ids[2] ), 2, "report 2 and 3 are deleted" );
$count -= 2;

is( scalar @{ get_saved_reports() },
    $count, "Report2 and report3 have been deleted" );

my $sth = execute_query('SELECT COUNT(*) FROM systempreferences', 0, 10);
my $results = $sth->fetchall_arrayref;
is(scalar @$results, 1, 'running a query returned a result');

my $version = C4::Context->preference('Version');
$sth = execute_query(
    'SELECT value FROM systempreferences WHERE variable = ?',
    0,
    10,
    [ 'Version' ],
);
$results = $sth->fetchall_arrayref;
is_deeply(
    $results,
    [ [ $version ] ],
    'running a query with a parameter returned the expected result'
);

# for next test, we want to let execute_query capture any SQL errors
$dbh->{RaiseError} = 0;
my $errors;
warning_like { ($sth, $errors) = execute_query(
        'SELECT surname FRM borrowers',  # error in the query is intentional
        0, 10 ) }
        qr/^DBD::mysql::st execute failed: You have an error in your SQL syntax;/,
        "Wrong SQL syntax raises warning";
ok(
    defined($errors) && exists($errors->{queryerr}),
    'attempting to run a report with an SQL syntax error returns error message (Bug 12214)'
);

is_deeply( get_report_areas(), [ 'CIRC', 'CAT', 'PAT', 'ACQ', 'ACC', 'SER' ],
    "get_report_areas returns the correct array of report areas");

$schema->storage->txn_rollback;
