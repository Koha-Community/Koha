#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 13;

use Koha::Database;

use_ok('C4::Reports::Guided');

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

$_->delete for Koha::AuthorisedValues->search({ category => 'XXX' });
Koha::AuthorisedValue->new({category => 'LOC'})->store;

{   # GetReservedAuthorisedValues tests
    # This one will catch new reserved words not added
    # to GetReservedAuthorisedValues
    my %test_authval = (
        'date' => 1,
        'branches' => 1,
        'itemtypes' => 1,
        'cn_source' => 1,
        'categorycode' => 1,
        'biblio_framework' => 1,
    );

    my $reserved_authorised_values = GetReservedAuthorisedValues();
    is_deeply(\%test_authval, $reserved_authorised_values,
                'GetReservedAuthorisedValues returns a fixed list');
}

{
    ok( IsAuthorisedValueValid('LOC'),
        'User defined authorised value category is valid');

    ok( ! IsAuthorisedValueValid('XXX'),
        'Not defined authorised value category is invalid');

    # Loop through the reserved authorised values
    foreach my $authorised_value ( keys %{GetReservedAuthorisedValues()} ) {
        ok( IsAuthorisedValueValid($authorised_value),
            '\''.$authorised_value.'\' is a reserved word, and thus a valid authorised value');
    }
}

{   # GetParametersFromSQL tests

    my $test_query_1 = "
        SELECT date_due
        FROM old_issues
        WHERE YEAR(timestamp) = <<Year|custom_list>> AND
              branchcode = <<Branch|branches>> AND
              borrowernumber = <<Borrower>>
    ";

    my @test_parameters_with_custom_list = (
        { 'name' => 'Year', 'authval' => 'custom_list' },
        { 'name' => 'Branch', 'authval' => 'branches' },
        { 'name' => 'Borrower', 'authval' => undef }
    );

    is_deeply( GetParametersFromSQL($test_query_1), \@test_parameters_with_custom_list,
        'SQL params are correctly parsed');

    # ValidateSQLParameters tests
    my @problematic_parameters = ();
    push @problematic_parameters, { 'name' => 'Year', 'authval' => 'custom_list' };
    is_deeply( ValidateSQLParameters( $test_query_1 ),
               \@problematic_parameters,
               '\'custom_list\' not a valid category' );

    my $test_query_2 = "
        SELECT date_due
        FROM old_issues
        WHERE YEAR(timestamp) = <<Year|date>> AND
              branchcode = <<Branch|branches>> AND
              borrowernumber = <<Borrower|LOC>>
    ";

    is_deeply( ValidateSQLParameters( $test_query_2 ),
        [],
        'All parameters valid, empty problematic authvals list');
}
