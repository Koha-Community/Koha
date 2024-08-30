#!/usr/bin/perl

# Copyright 2012 Catalyst IT Ltd.
# Copyright 2015 Koha Development team
#
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

use Test::NoWarnings;
use Test::More tests => 14;
use Test::Warn;

use t::lib::TestBuilder;
use C4::Context;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Reports;
use Koha::Notice::Messages;

use_ok(
    'C4::Reports::Guided',
    qw( execute_query save_report delete_report strip_limit GetReservedAuthorisedValues IsAuthorisedValueValid GetParametersFromSQL ValidateSQLParameters get_saved_reports update_sql get_report_areas convert_sql EmailReport nb_rows )
);
can_ok(
    'C4::Reports::Guided',
    qw(save_report delete_report execute_query)
);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

subtest 'strip_limit' => sub {

    # This is the query I found that triggered bug 8594.
    my $sql = "SELECT aqorders.ordernumber, biblio.title, biblio.biblionumber, items.homebranch,
        aqorders.entrydate, aqorders.datereceived,
        (SELECT DATE(datetime) FROM statistics
            WHERE itemnumber=items.itemnumber AND
                (type='return' OR type='issue') LIMIT 1)
        AS shelvedate,
        DATEDIFF(COALESCE(
            (SELECT DATE(datetime) FROM statistics
                WHERE itemnumber=items.itemnumber AND
                (type='return' OR type='issue') LIMIT 1),
        aqorders.datereceived), aqorders.entrydate) AS totaldays
    FROM aqorders
    LEFT JOIN biblio USING (biblionumber)
    LEFT JOIN items ON (items.biblionumber = biblio.biblionumber
        AND dateaccessioned=aqorders.datereceived)
    WHERE (entrydate >= '2011-01-01' AND (datereceived < '2011-02-01' OR datereceived IS NULL))
        AND items.homebranch LIKE 'INFO'
    ORDER BY title";

    my ( $res_sql, $res_lim1, $res_lim2 ) = C4::Reports::Guided::strip_limit($sql);
    is( $res_sql,  $sql,  "Not breaking subqueries" );
    is( $res_lim1, 0,     "Returns correct default offset" );
    is( $res_lim2, undef, "Returns correct default LIMIT" );

    # Now the same thing, but we want it to remove the LIMIT from the end

    my $test_sql = $res_sql . " LIMIT 242";
    ( $res_sql, $res_lim1, $res_lim2 ) = C4::Reports::Guided::strip_limit($test_sql);

    # The replacement drops a ' ' where the limit was
    is( trim($res_sql), $sql, "Correctly removes only final LIMIT" );
    is( $res_lim1,      0,    "Returns correct default offset" );
    is( $res_lim2,      242,  "Returns correct extracted LIMIT" );

    $test_sql = $res_sql . " LIMIT 13,242";
    ( $res_sql, $res_lim1, $res_lim2 ) = C4::Reports::Guided::strip_limit($test_sql);

    # The replacement drops a ' ' where the limit was
    is( trim($res_sql), $sql, "Correctly removes only final LIMIT (with offset)" );
    is( $res_lim1,      13,   "Returns correct extracted offset" );
    is( $res_lim2,      242,  "Returns correct extracted LIMIT" );

    # After here is the simpler case, where there isn't a WHERE clause to worry
    # about.

    # First case with nothing to change
    $sql = "SELECT * FROM items";
    ( $res_sql, $res_lim1, $res_lim2 ) = C4::Reports::Guided::strip_limit($sql);
    is( $res_sql,  $sql,  "Not breaking simple queries" );
    is( $res_lim1, 0,     "Returns correct default offset" );
    is( $res_lim2, undef, "Returns correct default LIMIT" );

    $test_sql = $sql . " LIMIT 242";
    ( $res_sql, $res_lim1, $res_lim2 ) = C4::Reports::Guided::strip_limit($test_sql);
    is( trim($res_sql), $sql, "Correctly removes LIMIT in simple case" );
    is( $res_lim1,      0,    "Returns correct default offset" );
    is( $res_lim2,      242,  "Returns correct extracted LIMIT" );

    $test_sql = $sql . " LIMIT 13,242";
    ( $res_sql, $res_lim1, $res_lim2 ) = C4::Reports::Guided::strip_limit($test_sql);
    is( trim($res_sql), $sql, "Correctly removes LIMIT in simple case (with offset)" );
    is( $res_lim1,      13,   "Returns correct extracted offset" );
    is( $res_lim2,      242,  "Returns correct extracted LIMIT" );
};

$_->delete for Koha::AuthorisedValues->search( { category => 'XXX' } );
Koha::AuthorisedValue->new( { category => 'LOC' } )->store;

subtest 'GetReservedAuthorisedValues' => sub {
    plan tests => 1;

    # This one will catch new reserved words not added
    # to GetReservedAuthorisedValues
    my %test_authval = (
        'date'             => 1,
        'branches'         => 1,
        'itemtypes'        => 1,
        'cn_source'        => 1,
        'categorycode'     => 1,
        'biblio_framework' => 1,
        'list'             => 1,
        'cash_registers'   => 1,
        'debit_types'      => 1,
        'credit_types'     => 1
    );

    my $reserved_authorised_values = GetReservedAuthorisedValues();
    is_deeply(
        \%test_authval, $reserved_authorised_values,
        'GetReservedAuthorisedValues returns a fixed list'
    );
};

subtest 'IsAuthorisedValueValid' => sub {
    plan tests => 12;
    ok(
        IsAuthorisedValueValid('LOC'),
        'User defined authorised value category is valid'
    );

    ok(
        !IsAuthorisedValueValid('XXX'),
        'Not defined authorised value category is invalid'
    );

    # Loop through the reserved authorised values
    foreach my $authorised_value ( keys %{ GetReservedAuthorisedValues() } ) {
        ok(
            IsAuthorisedValueValid($authorised_value),
            '\'' . $authorised_value . '\' is a reserved word, and thus a valid authorised value'
        );
    }
};

subtest 'GetParametersFromSQL+ValidateSQLParameters' => sub {
    plan tests => 3;
    my $test_query_1 = "
        SELECT date_due
        FROM old_issues
        WHERE YEAR(timestamp) = <<Year|custom_list>> AND
              branchcode = <<Branch|branches>> AND
              borrowernumber = <<Borrower>> AND
              itemtype = <<Item type|itemtypes:all>>
    ";

    my @test_parameters_with_custom_list = (
        { 'name' => 'Year',      'authval' => 'custom_list' },
        { 'name' => 'Branch',    'authval' => 'branches' },
        { 'name' => 'Borrower',  'authval' => undef },
        { 'name' => 'Item type', 'authval' => 'itemtypes' }
    );

    is_deeply(
        GetParametersFromSQL($test_query_1), \@test_parameters_with_custom_list,
        'SQL params are correctly parsed'
    );

    my @problematic_parameters = ();
    push @problematic_parameters, { 'name' => 'Year', 'authval' => 'custom_list' };
    is_deeply(
        ValidateSQLParameters($test_query_1),
        \@problematic_parameters,
        '\'custom_list\' not a valid category'
    );

    my $test_query_2 = "
        SELECT date_due
        FROM old_issues
        WHERE YEAR(timestamp) = <<Year|date>> AND
              branchcode = <<Branch|branches>> AND
              borrowernumber = <<Borrower|LOC>>
    ";

    is_deeply(
        ValidateSQLParameters($test_query_2),
        [],
        'All parameters valid, empty problematic authvals list'
    );
};

subtest 'get_saved_reports' => sub {
    plan tests => 18;
    my $dbh = C4::Context->dbh;
    $dbh->do(q|DELETE FROM saved_sql|);
    $dbh->do(q|DELETE FROM saved_reports|);

    #Test save_report
    my $count = scalar @{ get_saved_reports() };
    is( $count, 0, "There is no report" );

    my @report_ids;
    foreach my $ii ( 1 .. 3 ) {
        my $id = $builder->build( { source => 'Borrower' } )->{borrowernumber};
        push @report_ids, save_report(
            {
                borrowernumber => $id,
                sql            => "SQL$id",
                name           => "Name$id",
                area           => "area$ii",       # ii vs id area is varchar(6)
                group          => "group$id",
                subgroup       => "subgroup$id",
                type           => "type$id",
                notes          => "note$id",
                cache_expiry   => undef,
                public         => 0,
            }
        );
        $count++;
    }
    like( $report_ids[0], '/^\d+$/', "Save_report returns an id for first" );
    like( $report_ids[1], '/^\d+$/', "Save_report returns an id for second" );
    like( $report_ids[2], '/^\d+$/', "Save_report returns an id for third" );

    is(
        scalar @{ get_saved_reports() },
        $count, "$count reports have been added"
    );

    ok( 0 < scalar @{ get_saved_reports( $report_ids[0] ) }, "filter takes report id" );

    ok( 0 < scalar @{ get_saved_reports( { date => dt_from_string->ymd } ) }, "filter takes date" );

    my $r1 = Koha::Reports->find( $report_ids[0] );
    $r1 = update_sql(
        $r1->id,
        { %{ $r1->unblessed }, borrowernumber => $r1->borrowernumber, name => 'Just another report' }
    );
    is( $r1->cache_expiry, 300, 'cache_expiry has the correct default value, from DBMS' );

    #Test delete_report
    is( delete_report(), undef, "Without id delete_report returns undef" );

    is( delete_report( $report_ids[0] ), 1, "report 1 is deleted" );
    $count--;

    is( scalar @{ get_saved_reports() }, $count, "Report1 has been deleted" );

    is( delete_report( $report_ids[1], $report_ids[2] ), 2, "report 2 and 3 are deleted" );
    $count -= 2;

    is(
        scalar @{ get_saved_reports() },
        $count, "Report2 and report3 have been deleted"
    );

    my $sth = execute_query(
        {
            sql    => 'SELECT COUNT(*) FROM systempreferences',
            offset => 0,
            limit  => 10,
        }
    );
    my $results = $sth->fetchall_arrayref;
    is( scalar @$results, 1, 'running a query returned a result' );

    my $version = C4::Context->preference('Version');
    $sth = execute_query(
        {
            sql        => 'SELECT value FROM systempreferences WHERE variable = ?',
            offset     => 0,
            limit      => 10,
            sql_params => ['Version'],
        }
    );
    $results = $sth->fetchall_arrayref;
    is_deeply(
        $results,
        [ [$version] ],
        'running a query with a parameter returned the expected result'
    );

    # for next test, we want to let execute_query capture any SQL errors
    my $errors;
    warning_like {
        local $dbh->{RaiseError} = 0;
        ( $sth, $errors ) = execute_query(
            {
                sql    => 'SELECT surname FRM borrowers',    # error in the query is intentional
                offset => 0,
                limit  => 10,
            }
        )
    }
    qr/DBD::mysql::st execute failed: You have an error in your SQL syntax;/,
        "Wrong SQL syntax raises warning";
    ok(
        defined($errors) && exists( $errors->{queryerr} ),
        'attempting to run a report with an SQL syntax error returns error message (Bug 12214)'
    );

    is_deeply(
        get_report_areas(), [ 'CIRC', 'CAT', 'PAT', 'ACQ', 'ACC', 'SER' ],
        "get_report_areas returns the correct array of report areas"
    );
};

subtest 'Ensure last_run is populated' => sub {
    plan tests => 3;

    my $rs = Koha::Database->new()->schema()->resultset('SavedSql');

    my $report = $rs->new(
        {
            report_name => 'Test Report',
            savedsql    => 'SELECT * FROM branches',
            notes       => undef,
        }
    )->insert();

    is( $report->last_run, undef, 'Newly created report has null last_run ' );

    execute_query( { sql => $report->savedsql, report_id => $report->id } );
    $report->discard_changes();

    isnt( $report->last_run, undef, 'First run of report populates last_run' );

    my $previous_last_run = $report->last_run;
    sleep(1);    # last_run is stored to the second, so we need to ensure at least one second has passed between runs
    execute_query( { sql => $report->savedsql, report_id => $report->id } );
    $report->discard_changes();

    isnt( $report->last_run, $previous_last_run, 'Second run of report updates last_run' );
};

subtest 'convert_sql' => sub {
    plan tests => 4;

    my $sql = q|
    SELECT biblionumber, ExtractValue(marcxml,
'count(//datafield[@tag="505"])') AS count505
    FROM biblioitems
    HAVING count505 > 1|;
    my $expected_converted_sql = q|
    SELECT biblionumber, ExtractValue(metadata,
'count(//datafield[@tag="505"])') AS count505
    FROM biblio_metadata
    HAVING count505 > 1|;

    is(
        C4::Reports::Guided::convert_sql($sql), $expected_converted_sql,
        "Simple query should have been correctly converted"
    );

    $sql = q|
    SELECT biblionumber, substring(
ExtractValue(marcxml,'//controlfield[@tag="008"]'), 8,4 ) AS 'PUB DATE',
title
    FROM biblioitems
    INNER JOIN biblio USING (biblionumber)
    WHERE biblionumber = 14|;

    $expected_converted_sql = q|
    SELECT biblionumber, substring(
ExtractValue(metadata,'//controlfield[@tag="008"]'), 8,4 ) AS 'PUB DATE',
title
    FROM biblio_metadata
    INNER JOIN biblio USING (biblionumber)
    WHERE biblionumber = 14|;
    is(
        C4::Reports::Guided::convert_sql($sql), $expected_converted_sql,
        "Query with biblio info should have been correctly converted"
    );

    $sql = q|
    SELECT concat(b.title, ' ', ExtractValue(m.marcxml,
'//datafield[@tag="245"]/subfield[@code="b"]')) AS title, b.author,
count(h.reservedate) AS 'holds'
    FROM biblio b
    LEFT JOIN biblioitems m USING (biblionumber)
    LEFT JOIN reserves h ON (b.biblionumber=h.biblionumber)
    GROUP BY b.biblionumber
    HAVING count(h.reservedate) >= 42|;

    $expected_converted_sql = q|
    SELECT concat(b.title, ' ', ExtractValue(m.metadata,
'//datafield[@tag="245"]/subfield[@code="b"]')) AS title, b.author,
count(h.reservedate) AS 'holds'
    FROM biblio b
    LEFT JOIN biblio_metadata m USING (biblionumber)
    LEFT JOIN reserves h ON (b.biblionumber=h.biblionumber)
    GROUP BY b.biblionumber
    HAVING count(h.reservedate) >= 42|;
    is(
        C4::Reports::Guided::convert_sql($sql), $expected_converted_sql,
        "Query with 2 joins should have been correctly converted"
    );

    $sql = q|
    SELECT t1.marcxml AS first, t2.marcxml AS second,
    FROM biblioitems t1
    LEFT JOIN biblioitems t2 USING ( biblionumber )|;

    $expected_converted_sql = q|
    SELECT t1.metadata AS first, t2.metadata AS second,
    FROM biblio_metadata t1
    LEFT JOIN biblio_metadata t2 USING ( biblionumber )|;
    is(
        C4::Reports::Guided::convert_sql($sql), $expected_converted_sql,
        "Query with multiple instances of marcxml and biblioitems should have them all replaced"
    );
};

subtest 'Email report test' => sub {

    plan tests => 14;
    my $dbh = C4::Context->dbh;

    my $id1 = $builder->build(
        { source => 'Borrower', value => { surname => 'mailer', email => 'a@b.com', emailpro => 'b@c.com' } } )
        ->{borrowernumber};
    my $id2 = $builder->build(
        { source => 'Borrower', value => { surname => 'nomailer', email => undef, emailpro => 'd@e.com' } } )
        ->{borrowernumber};
    my $id3 = $builder->build(
        { source => 'Borrower', value => { surname => 'norman', email => 'a@b.com', emailpro => undef } } )
        ->{borrowernumber};
    my $report1 = $builder->build(
        {
            source => 'SavedSql',
            value  => {
                savedsql =>
                    "SELECT surname,borrowernumber,email,emailpro FROM borrowers WHERE borrowernumber IN ($id1,$id2,$id3)"
            }
        }
    )->{id};
    my $report2 =
        $builder->build( { source => 'SavedSql', value => { savedsql => "SELECT potato FROM mashed" } } )->{id};

    my $letter1 = $builder->build(
        {
            source => 'Letter',
            value  => {
                content                => "[% surname %]",
                branchcode             => "",
                message_transport_type => 'email',
                is_html                => undef
            }
        }
    );
    my $letter2 = $builder->build(
        {
            source => 'Letter',
            value  => {
                content                => "[% firstname %]",
                branchcode             => "",
                message_transport_type => 'email',
                is_html                => 0
            }
        }
    );

    my $letter3 = $builder->build(
        {
            source => 'Letter',
            value  => {
                content                => "[% surname %]",
                branchcode             => "",
                message_transport_type => 'email',
                is_html                => 1
            }
        }
    );

    my $message_count = Koha::Notice::Messages->search( {} )->count;

    my ( $emails, $errors ) = C4::Reports::Guided::EmailReport();
    is( $errors->[0]{FATAL}, 'MISSING_PARAMS', "Need to enter required params" );

    ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
        { report_id => $report1, module => $letter1->{module}, code => $letter2->{code} } );
    is( $errors->[0]{FATAL}, 'NO_LETTER', "Must have a letter that exists" );

    # for next test, we want to let execute_query capture any SQL errors
    warning_like {
        local $dbh->{RaiseError} = 0;
        ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
            { report_id => $report2, module => $letter1->{module}, code => $letter1->{code} } )
    }
    qr/DBD::mysql::st execute failed/,
        'Error from bad report';
    is( $errors->[0]{FATAL}, 'REPORT_FAIL', "Bad report returns failure" );

    ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
        { report_id => $report1, module => $letter1->{module}, code => $letter1->{code} } );
    is(
        $errors->[0]{NO_FROM_COL} == 1 && $errors->[1]{NO_EMAIL_COL} == 2 && $errors->[2]{NO_FROM_COL} == 2, 1,
        "Correct warnings from the routine"
    );

    ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
        { report_id => $report1, module => $letter1->{module}, code => $letter1->{code}, from => 'the@future.ooh' } );
    is( $errors->[0]{NO_EMAIL_COL}, 2, "Warning only for patron with no email" );

    is( $message_count, Koha::Notice::Messages->search( {} )->count, "Messages not added without commit" );

    ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
        { report_id => $report1, module => $letter1->{module}, code => $letter1->{code}, from => 'the@future.ooh' } );
    is( $emails->[0]{letter}->{content},        "mailer", "Message has expected content" );
    is( $emails->[1]{letter}->{content},        "norman", "Message has expected content" );
    is( $emails->[0]{letter}->{'content-type'}, undef,    "Message content type is not set for plain text mail" );

    ( $emails, $errors ) = C4::Reports::Guided::EmailReport(
        {
            report_id => $report1, module => $letter1->{module}, code => $letter1->{code}, from => 'the@future.ooh',
            email     => 'emailpro'
        }
    );
    is_deeply( $errors, [ { 'NO_EMAIL_COL' => 3 } ], "We report missing email in emailpro column" );
    is( $emails->[0]->{to_address}, 'b@c.com', "Message uses correct email" );
    is( $emails->[1]->{to_address}, 'd@e.com', "Message uses correct email" );

    ($emails) = C4::Reports::Guided::EmailReport(
        { report_id => $report1, module => $letter3->{module}, code => $letter3->{code}, from => 'the@future.ooh' } );
    is( $emails->[0]{letter}->{'content-type'}, 'text/html; charset="UTF-8"', "Message has expected content type" );

};

$schema->storage->txn_rollback;

subtest 'nb_rows() tests' => sub {

    plan tests => 3;

    my $dbh = C4::Context->dbh;
    $schema->storage->txn_begin;

    my $items_count = Koha::Items->search->count;
    $builder->build_object( { class => 'Koha::Items' } );
    $builder->build_object( { class => 'Koha::Items' } );
    $items_count += 2;

    my $query = q{
        SELECT * FROM items xxx
    };

    my $nb_rows = nb_rows($query);

    is( $nb_rows, $items_count, 'nb_rows returns the right value' );

    my $bad_query = q{
        SELECT * items xxx
    };

    # for next test, we want to let execute_query capture any SQL errors

    warning_like { $nb_rows = nb_rows($bad_query) }
    qr/DBD::mysql::st execute failed:/,
        'Bad queries raise a warning';

    is( $nb_rows, 0, 'nb_rows returns 0 on bad queries' );

    $schema->storage->txn_rollback;
};

subtest 'Returning passwords tests' => sub {

    plan tests => 4;

    my $dbh = C4::Context->dbh;
    $schema->storage->txn_begin;

    my $query = q{ SELECT * FROM borrowers };

    my ( $sth, $errors ) = execute_query( { sql => $query } );

    is( defined($errors), 1, 'Query returns password field' );

    $query = q{ SELECT * FROM z3950servers };

    ( $sth, $errors ) = execute_query( { sql => $query } );

    is( defined($errors), 1, 'Query returns password field' );

    $query = q{ SELECT password FROM deletedborrowers };

    ( $sth, $errors ) = execute_query( { sql => $query } );

    is( defined($errors), 1, 'Query returns password field' );

    $query = q{ SELECT password as secret FROM borrowers };

    ( $sth, $errors ) = execute_query( { sql => $query } );

    is( defined($errors), 1, 'Error raised for returning password' );

    $schema->storage->txn_rollback;
};

subtest 'get_columns' => sub {
    plan tests => 8;
    $schema->storage->txn_begin;
    my $area    = 'foo';
    my $success = eval { C4::Reports::Guided::get_columns($area) };
    ok !$success && $@ =~ m{^Unsupported report area "$area"}, 'Call with wrong report area explodes';

    my $columns = C4::Reports::Guided::get_columns('CAT');
    ok exists $columns->{biblio};
    ok exists $columns->{biblioitems};
    ok exists $columns->{items};
    ok scalar grep  { $_->{name} eq 'biblio.biblionumber' } @{ $columns->{biblio} };
    ok scalar grep  { $_->{description} =~ m{Biblio number} } @{ $columns->{biblio} };
    ok !scalar grep { $_->{name} eq 'not_a_column' } @{ $columns->{biblio} };

    $columns = C4::Reports::Guided::get_columns('PAT');
    ok(
        !exists $columns->{password},
        "Password is a forbidden field and should not be returned"
    );

    $schema->storage->txn_rollback;
};

sub trim {
    my ($s) = @_;
    $s =~ s/^\s*(.*?)\s*$/$1/s;
    return $s;
}
