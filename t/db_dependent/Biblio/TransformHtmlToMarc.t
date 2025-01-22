#!/usr/bin/perl

use Modern::Perl;
use CGI;
use Encode qw( encode );
use Test::NoWarnings;
use Test::More tests => 3;

use Koha::Caches;
use Koha::Database;
use Koha::MarcSubfieldStructures;
use C4::Biblio qw( GetMarcFromKohaField TransformHtmlToMarc );

our ( $biblionumbertagfield, $biblionumbertagsubfield );
my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Move field for biblionumber to imaginary 399
Koha::MarcSubfieldStructures->search( { frameworkcode => '', kohafield => 'biblio.biblionumber' } )->delete;
Koha::MarcSubfieldStructures->search( { frameworkcode => '', tagfield => '399', tagsubfield => 'a' } )->delete;
Koha::MarcSubfieldStructure->new(
    { frameworkcode => '', tagfield => '399', tagsubfield => 'a', kohafield => "biblio.biblionumber" } )->store;
Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");
( $biblionumbertagfield, $biblionumbertagsubfield ) = C4::Biblio::GetMarcFromKohaField("biblio.biblionumber");

subtest 'Biblio record' => sub {
    plan tests => 20;
    my $leader = '00203nam a2200097   4500';
    my $input  = CGI->new;
    $input->param( -name => 'biblionumber',                      -value => '42' );
    $input->param( -name => 'tag_000_indicator1_570367553534',   -value => '' );
    $input->param( -name => 'tag_000_indicator2_570367553534',   -value => '' );
    $input->param( -name => 'tag_000_code_00_570367_810561',     -value => '' );
    $input->param( -name => 'tag_000_subfield_00_570367_810561', -value => $leader );
    $input->param( -name => 'tag_010_indicator1_493056',         -value => '' );
    $input->param( -name => 'tag_010_indicator2_493056',         -value => '' );
    $input->param( -name => 'tag_010_code_a_493056_296409',      -value => 'a' );
    $input->param( -name => 'tag_010_subfield_a_493056_296409',  -value => Encode::encode( 'utf-8', "first isbn é" ) );
    $input->param( -name => 'tag_010_indicator1_49305613979',    -value => '' );
    $input->param( -name => 'tag_010_indicator2_49305613979',    -value => '' );
    $input->param( -name => 'tag_010_code_a_493056_29640913979', -value => 'a' );
    $input->param(
        -name  => 'tag_010_subfield_a_493056_29640913979',
        -value => Encode::encode( 'utf-8', "second isbn à" )
    );    # 2 010 fields
    $input->param( -name => 'tag_100_indicator1_588794844868',   -value => '' );
    $input->param( -name => 'tag_100_indicator2_588794844868',   -value => '' );
    $input->param( -name => 'tag_100_code_a_588794_15537',       -value => 'a' );
    $input->param( -name => 'tag_100_subfield_a_588794_15537',   -value => '20160112d        u||y0frey5050    ba' );
    $input->param( -name => 'tag_200_indicator1_593269251146',   -value => '' );
    $input->param( -name => 'tag_200_indicator2_593269251146',   -value => '' );
    $input->param( -name => 'tag_200_code_a_593269_944056',      -value => 'a' );
    $input->param( -name => 'tag_200_subfield_a_593269_944056',  -value => 'first title' );  # 2 200$a in the same field
    $input->param( -name => 'tag_200_code_a_593269_94405618065', -value => 'a' );
    $input->param( -name => 'tag_200_subfield_a_593269_94405618065', -value => 'second title' );
    $input->param( -name => 'tag_200_code_b_593269_250538',          -value => 'b' );
    $input->param( -name => 'tag_200_subfield_b_593269_250538',      -value => 'DVD' );
    $input->param( -name => 'tag_200_code_f_593269_445603',          -value => 'f' );
    $input->param( -name => 'tag_200_subfield_f_593269_445603',      -value => 'author' );
    $input->param( -name => 'tag_200_code_h_593269_616594',          -value => 'h' );              # Empty field
    $input->param( -name => 'tag_200_subfield_h_593269_616594',      -value => '' );

    # Add a field 390 before our 399
    $input->param( -name => "tag_390_indicator1_123", -value => "" );
    $input->param( -name => "tag_390_indicator2_123", -value => "" );
    $input->param( -name => "tag_390_code_a_123",     -value => 'a' );
    $input->param( -name => "tag_390_subfield_a_123", -value => '390a' );

    # Our imaginary biblionumber field in 399
    $input->param( -name => "tag_${biblionumbertagfield}_indicator1_588794844868", -value => "" );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator2_588794844868", -value => "" );
    $input->param(
        -name  => "tag_${biblionumbertagfield}_code_${biblionumbertagsubfield}_588794_784323",
        -value => $biblionumbertagsubfield
    );
    $input->param(
        -name  => "tag_${biblionumbertagfield}_subfield_${biblionumbertagsubfield}_588794_784323",
        -value => $biblionumbertagfield
    );

    # A field (490) after 399
    $input->param( -name => "tag_490_indicator1_1123", -value => "" );
    $input->param( -name => "tag_490_indicator2_1123", -value => "" );
    $input->param( -name => "tag_490_code_b_1123",     -value => 'b' );
    $input->param( -name => "tag_490_subfield_b_1123", -value => '490b' );

    # A field (900) after 490
    $input->param( -name => "tag_900_indicator1_1123", -value => "" );
    $input->param( -name => "tag_900_indicator2_1123", -value => "" );
    $input->param( -name => "tag_900_code_a_1123",     -value => 'a' );
    $input->param( -name => "tag_900_subfield_a_1123", -value => "This string has bad \x{1B}characters in it" );

    my $record = C4::Biblio::TransformHtmlToMarc( $input, 1 );

    my @all_fields = $record->fields;
    is( @all_fields, 8, 'The record should have been created with 8 fields' );

    # biblionumber + 2x010 + 100 + 200 + 390 + 490
    my @fields_010 = $record->field('010');
    is( @fields_010, 2, 'The record should have been created with 2 010' );
    my @fields_100 = $record->field('100');
    is( @fields_100, 1, 'The record should have been created with 1 100' );
    my @fields_200 = $record->field('200');
    is( @fields_200, 1, 'The record should have been created with 1 200' );

    is_deeply( $fields_010[0]->subfields(), [ 'a', 'first isbn é' ],  'The first isbn should be correct' );
    is_deeply( $fields_010[1]->subfields(), [ 'a', 'second isbn à' ], 'The second isbn should be correct' );

    my @subfields_200_a = $record->subfield( 200, 'a' );
    is( @subfields_200_a, 2, 'The record should have been created with 2 200$a' );
    is_deeply(
        \@subfields_200_a, [ 'first title', 'second title' ],
        'The 2 titles should have been kept in the correct order'
    );

    my @fields_900 = $record->field('900');
    is( @fields_900, 1, 'The record should have been created with 1 900' );
    is_deeply(
        $fields_900[0]->subfields(), [ 'a', 'This string has bad characters in it' ],
        'Field 900 had its non-XML characters stripped'
    );

    my @subfields_biblionumber = $record->subfield( $biblionumbertagfield, $biblionumbertagsubfield );
    is( @subfields_biblionumber, 1, 'The record should contain only one biblionumber field' );

    is( $record->leader, $leader, 'The leader should have been kept' );

    # Check the order of some fields
    is( $all_fields[0]->tag,           '010', 'First field expected 010' );
    is( $all_fields[1]->tag,           '010', 'Second field also 010' );
    is( $all_fields[2]->tag,           '100', 'Third field is 100' );
    is( $all_fields[3]->tag,           '200', 'Fourth field is 200' );
    is( $all_fields[4]->tag,           '390', 'Fifth field is 390' );
    is( $all_fields[5]->subfield('a'), 42,    'Sixth field contains bibnumber' );
    is( $all_fields[6]->tag,           '490', 'Last field is 490' );

    my $new_record   = eval { MARC::Record::new_from_xml( $record->as_xml(), 'UTF-8' ); };
    my $record_error = $@;
    ok( !$record_error, 'No errors parsing MARCXML generated by TransformHtmlToMarc' );

};

subtest 'Add authority record' => sub {
    plan tests => 1;

    my $input = CGI->new;
    $input->param( -name => 'tag_200_indicator1_906288',                     -value => '' );
    $input->param( -name => 'tag_200_indicator2_906288',                     -value => '' );
    $input->param( -name => 'tag_200_code_a_906288_722171',                  -value => 'a' );
    $input->param( -name => 'tag_200_subfield_a_906288_722171',              -value => 'a 200$a' );
    $input->param( -name => 'tag_200_code_b_906288_611549',                  -value => 'b' );
    $input->param( -name => 'tag_200_subfield_b_906288_611549',              -value => 'a 200$b' );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator1_198510", -value => "" );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator2_198510", -value => "" );
    $input->param(
        -name  => "tag_${biblionumbertagfield}_code_${biblionumbertagsubfield}_198510_886205",
        -value => $biblionumbertagsubfield
    );
    $input->param(
        -name  => "tag_${biblionumbertagfield}_subfield_${biblionumbertagsubfield}_198510_886205",
        -value => "a biblionumber which is not a biblionumber"
    );

    my $record = C4::Biblio::TransformHtmlToMarc( $input, 0 );

    my @subfields_biblionumber = $record->subfield( $biblionumbertagfield, $biblionumbertagsubfield );
    is( @subfields_biblionumber, 1, 'The record should contain the field which are mapped to biblio.biblionumber' );
};

Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");
$schema->storage->txn_rollback;
