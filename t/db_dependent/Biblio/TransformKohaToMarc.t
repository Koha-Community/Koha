use Modern::Perl;
use Test::More tests => 1;
use MARC::Record;

use t::lib::Mocks;
use Koha::Database;
use Koha::Cache;
use C4::Biblio;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Create/overwrite some Koha to MARC mappings in default framework
$dbh->do(q|DELETE FROM marc_subfield_structure WHERE frameworkcode='' and tagfield=300 and tagsubfield='a'|);
$dbh->do(q|INSERT INTO marc_subfield_structure(frameworkcode, tagfield, tagsubfield, kohafield) VALUES ('', 300, 'a', 'mytable.nicepages')|);
$dbh->do(q|DELETE FROM marc_subfield_structure WHERE frameworkcode='' and tagfield=300 and tagsubfield='b'|);
$dbh->do(q|INSERT INTO marc_subfield_structure(frameworkcode, tagfield, tagsubfield, kohafield) VALUES ('', 300, 'b', 'mytable2.goodillustrations')|);
Koha::Cache->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

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
Koha::Cache->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
$schema->storage->txn_rollback;
