use Modern::Perl;

use Test::More tests => 3;
use Test::Warn;

use t::lib::Mocks;
use C4::Biblio;
use C4::Circulation;
use C4::Items;
use C4::Members;
use Koha::Database;
use Koha::DateUtils;
use Koha::Issues;
use Koha::OldIssues;

use t::lib::TestBuilder;

use MARC::Record;

*C4::Context::userenv = \&Mock_userenv;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => 'Branch',
});

my $record = MARC::Record->new();
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );

my ( undef, undef, $itemnumber ) = AddItem(
    {
        homebranch         => $library->{branchcode},
        holdingbranch      => $library->{branchcode},
        barcode            => 'i_dont_exist',
        location           => 'PROC',
        permanent_location => 'TEST'
    },
    $biblionumber
);

my $item;

t::lib::Mocks::mock_preference( "InProcessingToShelvingCart", 1 );
AddReturn( 'i_dont_exist', $library->{branchcode} );
$item = GetItem($itemnumber);
is( $item->{location}, 'CART', "InProcessingToShelvingCart functions as intended" );

$item->{location} = 'PROC';
ModItem( $item, undef, $itemnumber );

t::lib::Mocks::mock_preference( "InProcessingToShelvingCart", 0 );
AddReturn( 'i_dont_exist', $library->{branchcode} );
$item = GetItem($itemnumber);
is( $item->{location}, 'TEST', "InProcessingToShelvingCart functions as intended" );

# C4::Context->userenv
sub Mock_userenv {
    return { branch => $library->{branchcode} };
}

subtest 'Handle ids duplication' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
    t::lib::Mocks::mock_preference( 'CalculateFinesOnReturn', 1 );
    t::lib::Mocks::mock_preference( 'finesMode', 'production' );
    my $dbh = C4::Context->dbh;
    $dbh->do(q|UPDATE issuingrules SET chargeperiod = 1, fine = 1, firstremind = 1|);

    my $biblio = $builder->build( { source => 'Biblio' } );
    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber => $biblio->{biblionumber},
                notforloan => 0,
                itemlost   => 0,
                withdrawn  => 0,

            }
        }
    );
    my $patron = $builder->build({source => 'Borrower'});
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );

    my $original_checkout = AddIssue( $patron->unblessed, $item->{barcode}, dt_from_string->subtract( days => 50 ) );

    my $issue_id = $original_checkout->issue_id;
    # Create an existing entry in old_issue
    $builder->build({ source => 'OldIssue', value => { issue_id => $issue_id } });

    my $old_checkout = Koha::OldIssues->find( $issue_id );

    my ($doreturn, $messages, $new_checkout, $borrower);
    warning_like {
        ( $doreturn, $messages, $new_checkout, $borrower ) =
          AddReturn( $item->{barcode}, undef, undef, undef, dt_from_string );
    }
    [
        qr{.*DBD::mysql::st execute failed: Duplicate entry.*},
        { carped => qr{The checkin for the following issue failed.*DBIx::Class::Storage::DBI::_dbh_execute.*} }
    ],
    'DBD should have raised an error about dup primary key';

    is( $doreturn, 0, 'Return should not have been done' );
    is( $messages->{WasReturned}, 0, 'messages should have the WasReturned flag set to 0' );
    is( $messages->{DataCorrupted}, 1, 'messages should have the DataCorrupted flag set to 1' );

    my $account_lines = Koha::Account::Lines->search({ borrowernumber => $patron->borrowernumber, issue_id => $issue_id });
    is( $account_lines->count, 0, 'No account lines should exist for this issue_id, patron should not have been charged' );

    is( Koha::Issues->find( $issue_id )->issue_id, $issue_id, 'The issues entry should not have been removed' );
};

1;
