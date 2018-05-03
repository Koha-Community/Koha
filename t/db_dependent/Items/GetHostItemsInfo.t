use Modern::Perl;

use Test::More tests => 1;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Items;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'GetHostItemsInfo' => sub {
    plan tests => 3;

    my $builder = t::lib::TestBuilder->new;
    my $bib1 = $builder->build({ source => 'Biblio' });
    my $itm1 = $builder->build({ source => 'Item', value => { biblionumber => $bib1->{biblionumber} }});
    my $itm2 = $builder->build({ source => 'Item', value => { biblionumber => $bib1->{biblionumber} }});
    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '461', '', '', 0 => $bib1->{biblionumber}, 9 => $itm1->{itemnumber} ),
        MARC::Field->new( '773', '', '', 0 => $bib1->{biblionumber}, 9 => $itm1->{itemnumber} ),
        MARC::Field->new( '773', '', '', 0 => $bib1->{biblionumber}, 9 => $itm2->{itemnumber} ),
    );

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('EasyAnalyticalRecords', 0);
    my @a = C4::Items::GetHostItemsInfo( $marc );
    is( @a, 0, 'GetHostItemsInfo returns empty list when pref is disabled' );

    t::lib::Mocks::mock_preference('EasyAnalyticalRecords', 1);
    @a = C4::Items::GetHostItemsInfo( $marc );
    is( @a, 2, 'GetHostItemsInfo returns two items for MARC21' );

    t::lib::Mocks::mock_preference('marcflavour', 'UNIMARC');
    @a = C4::Items::GetHostItemsInfo( $marc );
    is( @a, 1, 'GetHostItemsInfo returns one item for UNIMARC' );
};

$schema->storage->txn_rollback;
