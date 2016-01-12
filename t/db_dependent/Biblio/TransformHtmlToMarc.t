#!/usr/bin/perl

use Modern::Perl;
use CGI;
use Encode qw( encode );
use Test::More tests => 2;

use C4::Biblio;

my ( $biblionumbertagfield, $biblionumbertagsubfield ) = C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber", '' );
subtest 'Biblio record' => sub {
    plan tests => 10;
    my $leader = '00203nam a2200097   4500';
    my $input  = CGI->new;
    $input->param( -name => 'biblionumber',                                        -value => '42' );
    $input->param( -name => 'tag_000_indicator1_570367553534',                     -value => '' );
    $input->param( -name => 'tag_000_indicator2_570367553534',                     -value => '' );
    $input->param( -name => 'tag_000_code_00_570367_810561',                       -value => '' );
    $input->param( -name => 'tag_000_subfield_00_570367_810561',                   -value => $leader );
    $input->param( -name => 'tag_010_indicator1_493056',                           -value => '' );
    $input->param( -name => 'tag_010_indicator2_493056',                           -value => '' );
    $input->param( -name => 'tag_010_code_a_493056_296409',                        -value => 'a' );
    $input->param( -name => 'tag_010_subfield_a_493056_296409',                    -value => Encode::encode( 'utf-8', "first isbn é" ) );
    $input->param( -name => 'tag_010_indicator1_49305613979',                      -value => '' );
    $input->param( -name => 'tag_010_indicator2_49305613979',                      -value => '' );
    $input->param( -name => 'tag_010_code_a_493056_29640913979',                   -value => 'a' );
    $input->param( -name => 'tag_010_subfield_a_493056_29640913979',               -value => Encode::encode( 'utf-8', "second isbn à" ) );    # 2 010 fields
    $input->param( -name => 'tag_100_indicator1_588794844868',                     -value => '' );
    $input->param( -name => 'tag_100_indicator2_588794844868',                     -value => '' );
    $input->param( -name => 'tag_100_code_a_588794_15537',                         -value => 'a' );
    $input->param( -name => 'tag_100_subfield_a_588794_15537',                     -value => '20160112d        u||y0frey5050    ba' );
    $input->param( -name => 'tag_200_indicator1_593269251146',                     -value => '' );
    $input->param( -name => 'tag_200_indicator2_593269251146',                     -value => '' );
    $input->param( -name => 'tag_200_code_a_593269_944056',                        -value => 'a' );
    $input->param( -name => 'tag_200_subfield_a_593269_944056',                    -value => 'first title' );                                  # 2 200$a in the same field
    $input->param( -name => 'tag_200_code_a_593269_94405618065',                   -value => 'a' );
    $input->param( -name => 'tag_200_subfield_a_593269_94405618065',               -value => 'second title' );
    $input->param( -name => 'tag_200_code_b_593269_250538',                        -value => 'b' );
    $input->param( -name => 'tag_200_subfield_b_593269_250538',                    -value => 'DVD' );
    $input->param( -name => 'tag_200_code_f_593269_445603',                        -value => 'f' );
    $input->param( -name => 'tag_200_subfield_f_593269_445603',                    -value => 'author' );
    $input->param( -name => 'tag_200_code_h_593269_616594',                        -value => 'h' );                                            # Empty field
    $input->param( -name => 'tag_200_subfield_h_593269_616594',                    -value => '' );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator1_588794844868", -value => "" );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator2_588794844868", -value => "" );
    $input->param( -name => "tag_${biblionumbertagfield}_code_${biblionumbertagsubfield}_588794_784323",     -value => $biblionumbertagsubfield );
    $input->param( -name => "tag_${biblionumbertagfield}_subfield_${biblionumbertagsubfield}_588794_784323", -value => $biblionumbertagfield );

    my $record = C4::Biblio::TransformHtmlToMarc($input, 1);

    my @all_fields = $record->fields;
    is( @all_fields, 5, 'The record should have been created with 5 fields (biblionumber + 2x010 + 1x100 + 1x200)' );
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
    is_deeply( \@subfields_200_a, [ 'first title', 'second title' ], 'The 2 titles should have been kept in the correct order' );

    my @subfields_biblionumber = $record->subfield( $biblionumbertagfield, $biblionumbertagsubfield );
    is( @subfields_biblionumber, 1, 'The record should contain only one biblionumber field' );

    is( $record->leader, $leader, 'The leader should have been kept' );
};

subtest 'Add authority record' => sub {
    plan tests => 1;

    my $input = CGI->new;
    $input->param( -name => 'tag_200_indicator1_906288',                                                     -value => '' );
    $input->param( -name => 'tag_200_indicator2_906288',                                                     -value => '' );
    $input->param( -name => 'tag_200_code_a_906288_722171',                                                  -value => 'a' );
    $input->param( -name => 'tag_200_subfield_a_906288_722171',                                              -value => 'a 200$a' );
    $input->param( -name => 'tag_200_code_b_906288_611549',                                                  -value => 'b' );
    $input->param( -name => 'tag_200_subfield_b_906288_611549',                                              -value => 'a 200$b' );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator1_198510",                                 -value => "" );
    $input->param( -name => "tag_${biblionumbertagfield}_indicator2_198510",                                 -value => "" );
    $input->param( -name => "tag_${biblionumbertagfield}_code_${biblionumbertagsubfield}_198510_886205",     -value => $biblionumbertagsubfield );
    $input->param( -name => "tag_${biblionumbertagfield}_subfield_${biblionumbertagsubfield}_198510_886205", -value => "a biblionumber which is not a biblionumber" );

    my $record = C4::Biblio::TransformHtmlToMarc($input, 0);

    my @subfields_biblionumber = $record->subfield( $biblionumbertagfield, $biblionumbertagsubfield );
    is( @subfields_biblionumber, 1, 'The record should contain the field which are mapped to biblio.biblionumber' );
};
