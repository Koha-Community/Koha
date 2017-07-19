use Modern::Perl;
use Test::More tests => 1;
use MARC::Record;

use t::lib::Mocks;
use Koha::Database;
use Koha::Caches;
use Koha::MarcSubfieldStructures;
use C4::Biblio;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Create/overwrite some Koha to MARC mappings in default framework
my $mapping1 = Koha::MarcSubfieldStructures->find('','300','a') // Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '300', tagsubfield => 'a' });
$mapping1->kohafield( "mytable.nicepages" );
$mapping1->store;
my $mapping2 = Koha::MarcSubfieldStructures->find('','300','b') // Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '300', tagsubfield => 'b' });
$mapping2->kohafield( "mytable2.goodillustrations" );
$mapping2->store;
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

my $record = C4::Biblio::TransformKohaToMarc({
    "mytable2.goodillustrations"   => "Other physical details", # 300$b
    "mytable.nicepages"            => "Extent",                 # 300$a
});
my @subfields = $record->field('300')->subfields();
is_deeply( \@subfields, [
          [
            'a',
            'Extent'
          ],
          [
            'b',
            'Other physical details'
          ],
        ],
'TransformKohaToMarc should return sorted subfields (regression test for bug 12343)' );

# Cleanup
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
$schema->storage->txn_rollback;
