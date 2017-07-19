use Modern::Perl;
use Test::More tests => 4;
use MARC::Record;

use t::lib::Mocks;
use t::lib::TestBuilder;

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


# Now test multiple mappings per kohafield too
subtest "Multiple Koha to MARC mappings (BZ 10306)" => sub {
    plan tests => 4;

    # 300a and 260d mapped to mytable.nicepages
    my $mapping3 = Koha::MarcSubfieldStructures->find('','260','d') // Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '260', tagsubfield => 'd' });
    $mapping3->kohafield( "mytable.nicepages" );
    $mapping3->store;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

    # Include two values in goodillustrations too: should result in two
    # subfields.
    my $record = C4::Biblio::TransformKohaToMarc({
        "mytable2.goodillustrations" => "good | better",
        "mytable.nicepages"          => "nice",
    });
    is( $record->subfield('260','d'), "nice", "Check 260d" );
    is( $record->subfield('300','a'), "nice", "Check 300a" );
    is( $record->subfield('300','b'), "good", "Check first 300b" );
    is( ($record->field('300')->subfield('b'))[1], "better",
        "Check second 300b" );
};

subtest "Working with control fields in another framework" => sub {
    plan tests => 2;

    # Add a new framework
    my $fw = t::lib::TestBuilder->new->build_object({
        class => 'Koha::BiblioFrameworks'
    });

    # Map a controlfield to 'fullcontrol'
    my $mapping = Koha::MarcSubfieldStructure->new({ frameworkcode => $fw->frameworkcode, tagfield => '001', tagsubfield => '@', kohafield => 'fullcontrol' });
    $mapping->store;

    # First test in the wrong framework
    my @cols = ( notexist => 'i am not here', fullcontrol => 'all' );
    my $record = C4::Biblio::TransformKohaToMarc( { @cols } );
    is( $record->field('001'), undef,
        'With default framework we should not find a 001 controlfield' );
    # Now include the framework parameter and test 001
    $record = C4::Biblio::TransformKohaToMarc( { @cols }, $fw->frameworkcode );
    is( $record->field('001')->data, "all", "Check controlfield 001 with right frameworkcode" );

    # Remove from cache
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-".$fw->frameworkcode );
};

subtest "Add test for no_split option" => sub {
    plan tests => 4;

    my $fwc = t::lib::TestBuilder->new->build({ source => 'MarcSubfieldStructure' })->{frameworkcode};
    Koha::MarcSubfieldStructure->new({ frameworkcode => $fwc, tagfield => '952', tagsubfield => 'a', kohafield => 'items.fld1' })->store;
    Koha::MarcSubfieldStructure->new({ frameworkcode => $fwc, tagfield => '952', tagsubfield => 'b', kohafield => 'items.fld1' })->store;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-$fwc" );

    # Test single value in fld1
    my @cols = ( 'items.fld1' => '01' );
    my $record = C4::Biblio::TransformKohaToMarc( { @cols }, $fwc, { no_split => 1 } );
    is( $record->subfield( '952', 'a' ), '01', 'Check single in 952a' );
    is( $record->subfield( '952', 'b' ), '01', 'Check single in 952b' );

    # Test glued (composite) value in fld1
    @cols = ( 'items.fld1' => '01 | 02' );
    $record = C4::Biblio::TransformKohaToMarc( { @cols }, $fwc, { no_split => 1 } );
    is( $record->subfield( '952', 'a' ), '01 | 02', 'Check composite in 952a' );
    is( $record->subfield( '952', 'b' ), '01 | 02', 'Check composite in 952b' );

    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-$fwc" );
};

# Cleanup
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
$schema->storage->txn_rollback;
