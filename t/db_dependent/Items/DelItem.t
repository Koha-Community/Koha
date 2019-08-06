use Modern::Perl;

# FIXME This file must be removed and the test moved to Koha::Item->delete

use MARC::Record;
use C4::Items;
use C4::Biblio;

use Koha::Items;

use t::lib::TestBuilder;

use Test::More tests => 2;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => 'Branch',
});

my $biblio = $builder->build_sample_biblio();

my $item = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        library      => $library->{branchcode}
    }
);

my $deleted = $item->delete;
is( $deleted, 1, "DelItem should return 1 if the item has been deleted" );
my $deleted_item = Koha::Items->find($item->itemnumber);
is( $deleted_item, undef, "DelItem with biblionumber parameter - the item should be deleted." );
