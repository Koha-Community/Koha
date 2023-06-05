#!/usr/bin/perl

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

use Test::More tests => 16;
use Test::MockModule;
use Test::Warn;
use List::MoreUtils qw( uniq );
use MARC::Record;

use t::lib::Mocks qw( mock_preference );
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Caches;
use Koha::MarcSubfieldStructures;

use C4::Linker::Default qw( get_link );

BEGIN {
    use_ok('C4::Biblio', qw( AddBiblio GetMarcFromKohaField BiblioAutoLink GetMarcSubfieldStructure GetMarcSubfieldStructureFromKohaField LinkBibHeadingsToAuthorities GetBiblioData ModBiblio GetMarcISSN GetMarcControlnumber GetMarcISBN GetMarcPrice GetFrameworkCode GetMarcUrls IsMarcStructureInternal GetMarcStructure GetXmlBiblio DelBiblio ));
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

my $builder = t::lib::TestBuilder->new;

subtest 'AddBiblio' => sub {
    plan tests => 9;

    my $marcflavour = 'MARC21';
    t::lib::Mocks::mock_preference( 'marcflavour', $marcflavour );

    my ( $f, $sf ) = GetMarcFromKohaField('biblioitems.cn_item');
    my $cn_item_field = MARC::Field->new( $f, ' ', ' ',
        $sf => 'Thisisgoingtobetoomanycharactersforthe.cn_item.field' );
    my $record = MARC::Record->new();
    $record->append_fields($cn_item_field);

    my $nb_biblios = Koha::Biblios->count;
    my ( $biblionumber, $biblioitemnumber );
    warnings_like { ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' ) }
        [ qr/Data too long for column 'cn_item'/, qr/Data too long for column 'cn_item'/ ],
        "expected warnings when adding too long cn_item";
    is( $biblionumber, undef,
        'AddBiblio returns undef for biblionumber if something went wrong' );
    is( $biblioitemnumber, undef,
        'AddBiblio returns undef for biblioitemnumber if something went wrong'
    );
    is( Koha::Biblios->count, $nb_biblios,
        'No biblio should have been added if something went wrong' );

    ( $f, $sf ) = GetMarcFromKohaField('biblioitems.lccn');
    my $lccn_field = MARC::Field->new( $f, ' ', ' ',
        $sf => 'ThisisNOTgoingtobetoomanycharactersfortheLCCNfield' );
    $record = MARC::Record->new();
    $record->append_fields($lccn_field);

    warnings_like { ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( $record, '' ) }
        [],
        "No warning expected when adding a long LCCN";
    isnt( $biblionumber, undef,
        'AddBiblio returns the biblionumber' );
    isnt( $biblioitemnumber, undef,
        'AddBiblio returns the biblioitemnumber'
    );
    is( Koha::Biblios->count, $nb_biblios + 1,
        'The biblio should have been added if nothing went wrong' );

    t::lib::Mocks::mock_preference( 'AutoLinkBiblios', $marcflavour );
    t::lib::Mocks::mock_preference( 'AutoCreateAuthorities', $marcflavour );
    t::lib::Mocks::mock_preference( 'autoControlNumber', "OFF" );

    my $mock_biblio = Test::MockModule->new("C4::Biblio");
    $mock_biblio->mock( BiblioAutoLink => sub {
        my $record = shift;
        my $frameworkcode = shift;
        warn "My biblionumber is ".$record->subfield('999','c')." and my frameworkcode is $frameworkcode";
    });
    warning_like { $builder->build_sample_biblio(); }
        qr/My biblionumber is \d+ and my frameworkcode is /, "The biblionumber is correctly passed to BiblioAutoLink";

};

subtest 'GetMarcSubfieldStructureFromKohaField' => sub {
    plan tests => 25;

    my @columns = qw(
        tagfield tagsubfield liblibrarian libopac repeatable mandatory kohafield tab
        authorised_value authtypecode value_builder isurl hidden frameworkcode
        seealso link defaultvalue maxlength
    );

    # biblio.biblionumber must be mapped so this should return something
    my $marc_subfield_structure = GetMarcSubfieldStructureFromKohaField('biblio.biblionumber');

    ok(defined $marc_subfield_structure, "There is a result");
    is(ref $marc_subfield_structure, "HASH", "Result is a hashref");
    foreach my $col (@columns) {
        ok(exists $marc_subfield_structure->{$col}, "Hashref contains key '$col'");
    }
    is($marc_subfield_structure->{kohafield}, 'biblio.biblionumber', "Result is the good result");
    like($marc_subfield_structure->{tagfield}, qr/^\d{3}$/, "tagfield is a valid tagfield");

    # Add a test for list context (BZ 10306)
    my @results = GetMarcSubfieldStructureFromKohaField('biblio.biblionumber');
    is( @results, 1, 'We expect only one mapping' );
    is_deeply( $results[0], $marc_subfield_structure,
        'The first entry should be the same hashref as we had before' );

    # foo.bar does not exist so this should return undef
    $marc_subfield_structure = GetMarcSubfieldStructureFromKohaField('foo.bar');
    is($marc_subfield_structure, undef, "invalid kohafield returns undef");

};

subtest "GetMarcSubfieldStructure" => sub {
    plan tests => 5;

    # Add multiple Koha to Marc mappings
    Koha::MarcSubfieldStructures->search({ frameworkcode => '', tagfield => '399', tagsubfield => [ 'a', 'b' ] })->delete;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '399', tagsubfield => 'a', kohafield => "mytable.nicepages" })->store;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '399', tagsubfield => 'b', kohafield => "mytable.nicepages" })->store;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
    my $structure = C4::Biblio::GetMarcSubfieldStructure('');

    is( @{ $structure->{"mytable.nicepages"} }, 2,
        'GetMarcSubfieldStructure should return two entries for nicepages' );
    is( $structure->{"mytable.nicepages"}->[0]->{tagfield}, '399',
        'Check tagfield for first entry' );
    is( $structure->{"mytable.nicepages"}->[0]->{tagsubfield}, 'a',
        'Check tagsubfield for first entry' );
    is( $structure->{"mytable.nicepages"}->[1]->{tagfield}, '399',
        'Check tagfield for second entry' );
    is( $structure->{"mytable.nicepages"}->[1]->{tagsubfield}, 'b',
        'Check tagsubfield for second entry' );
};

subtest "GetMarcFromKohaField" => sub {
    plan tests => 8;

    #NOTE: We are building on data from the previous subtest
    # With: field 399 / mytable.nicepages

    # Check call in list context for multiple mappings
    my @retval = C4::Biblio::GetMarcFromKohaField('mytable.nicepages');
    is( @retval, 4, 'Should return two tags and subfields' );
    is( $retval[0], '399', 'Check first tag' );
    is( $retval[1], 'a', 'Check first subfield' );
    is( $retval[2], '399', 'Check second tag' );
    is( $retval[3], 'b', 'Check second subfield' );

    # Check same call in scalar context
    is( C4::Biblio::GetMarcFromKohaField('mytable.nicepages'), '399',
        'GetMarcFromKohaField returns first tag in scalar context' );

    # Bug 19096 Default is authoritative
    # If we add a new empty framework, we should still get the mappings
    # from Default. CAUTION: This test passes intentionally the obsoleted
    # framework parameter.
    my $new_fw = t::lib::TestBuilder->new->build({source => 'BiblioFramework'});
    @retval = C4::Biblio::GetMarcFromKohaField(
        'mytable.nicepages', $new_fw->{frameworkcode},
    );
    is( @retval, 4, 'Still got two pairs of tags/subfields' );
    is( $retval[0].$retval[1], '399a', 'Including 399a' );
};

subtest "Authority creation with default linker" => sub {
    plan tests => 4;
    # Automatic authority creation
    t::lib::Mocks::mock_preference('LinkerModule', 'Default');
    t::lib::Mocks::mock_preference('AutoLinkBiblios', 1);
    t::lib::Mocks::mock_preference('AutoCreateAuthorities', 1);
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my $linker = C4::Linker::Default->new({});
    my $authorities_mod = Test::MockModule->new( 'C4::Heading' );
    $authorities_mod->mock(
        'authorities',
        sub {
            my $results = [{ authid => 'original' },{ authid => 'duplicate' }];
            return $results;
        }
    );
    my $marc_record = MARC::Record->new();
    my $field = MARC::Field->new(655, ' ', ' ','a' => 'Magical realism');
    $marc_record->append_fields( $field );
    my ($num_changed,$results) = LinkBibHeadingsToAuthorities($linker, $marc_record, "",undef);
    is( $num_changed, 0, "We shouldn't link or create a new record");
    ok( !defined $results->{added}, "If we have multiple matches, we shouldn't create a new record");

    ($num_changed,$results) = LinkBibHeadingsToAuthorities($linker, $marc_record, "",undef);
    is( $num_changed, 0, "We shouldn't link or create a new record using cached result");
    ok( !defined $results->{added}, "If we have multiple matches, we shouldn't create a new record on second instance");
};



# Mocking variables
my $biblio_module = Test::MockModule->new('C4::Biblio');
$biblio_module->mock(
    'GetMarcSubfieldStructure',
    sub {
        my ($self) = shift;

        my ( $title_field,            $title_subfield )            = get_title_field();
        my ( $subtitle_field,         $subtitle_subfield )         = get_subtitle_field();
        my ( $medium_field,           $medium_subfield )           = get_medium_field();
        my ( $part_number_field,      $part_number_subfield )      = get_part_number_field();
        my ( $part_name_field,        $part_name_subfield )        = get_part_name_field();
        my ( $isbn_field,             $isbn_subfield )             = get_isbn_field();
        my ( $issn_field,             $issn_subfield )             = get_issn_field();
        my ( $biblionumber_field,     $biblionumber_subfield )     = ( '999', 'c' );
        my ( $biblioitemnumber_field, $biblioitemnumber_subfield ) = ( '999', '9' );
        my ( $itemnumber_field,       $itemnumber_subfield )       = get_itemnumber_field();

        return {
            'biblio.title'                 => [ { tagfield => $title_field,            tagsubfield => $title_subfield } ],
            'biblio.subtitle'              => [ { tagfield => $subtitle_field,         tagsubfield => $subtitle_subfield } ],
            'biblio.medium'                => [ { tagfield => $medium_field,           tagsubfield => $medium_subfield } ],
            'biblio.part_number'           => [ { tagfield => $part_number_field,      tagsubfield => $part_number_subfield } ],
            'biblio.part_name'             => [ { tagfield => $part_name_field,        tagsubfield => $part_name_subfield } ],
            'biblio.biblionumber'          => [ { tagfield => $biblionumber_field,     tagsubfield => $biblionumber_subfield } ],
            'biblioitems.isbn'             => [ { tagfield => $isbn_field,             tagsubfield => $isbn_subfield } ],
            'biblioitems.issn'             => [ { tagfield => $issn_field,             tagsubfield => $issn_subfield } ],
            'biblioitems.biblioitemnumber' => [ { tagfield => $biblioitemnumber_field, tagsubfield => $biblioitemnumber_subfield } ],
            'items.itemnumber'             => [ { tagfield => $itemnumber_subfield,    tagsubfield => $itemnumber_subfield } ],
        };
      }
);

my $currency = Test::MockModule->new('Koha::Acquisition::Currencies');
$currency->mock(
    'get_active',
    sub {
        return Koha::Acquisition::Currency->new(
            {   symbol   => '$',
                isocode  => 'USD',
                currency => 'USD',
                active   => 1,
            }
        );
    }
);

sub run_tests {

    my $marcflavour = shift;
    t::lib::Mocks::mock_preference('marcflavour', $marcflavour);
    # Authority tests don't interact well with Elasticsearch at the moment due to the fact that there's currently no way to
    # roll back ES index changes.
    t::lib::Mocks::mock_preference('SearchEngine', 'Zebra');
    t::lib::Mocks::mock_preference('autoControlNumber', 'OFF');

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    my $isbn = '0590353403';
    my $title = 'Foundation';
    my $subtitle1 = 'Research';
    my $subtitle2 = 'Conclusions';
    my $medium = 'Medium';
    my $part_number = '123';
    my $part_name = 'First years';

    # Generate a record with just the ISBN
    my $marc_record = MARC::Record->new;
    $marc_record->append_fields( create_isbn_field( $isbn, $marcflavour ) );

    # Add the record to the DB
    my( $biblionumber, $biblioitemnumber ) = AddBiblio( $marc_record, '' );
    my $data = GetBiblioData( $biblionumber );
    is( $data->{ isbn }, $isbn,
        '(GetBiblioData) ISBN correctly retireved.');
    is( $data->{ title }, undef,
        '(GetBiblioData) Title field is empty in fresh biblio.');

    my $biblio = Koha::Biblios->find($biblionumber);

    my ( $isbn_field, $isbn_subfield ) = get_isbn_field();
    my $marc = $biblio->metadata->record;
    is( $marc->subfield( $isbn_field, $isbn_subfield ), $isbn, );

    # Add title
    my $field = create_title_field( $title, $marcflavour );
    $marc_record->append_fields( $field );
    ModBiblio( $marc_record, $biblionumber ,'' );
    $data = GetBiblioData( $biblionumber );
    is( $data->{ title }, $title,
        'ModBiblio correctly added the title field, and GetBiblioData.');
    is( $data->{ isbn }, $isbn, '(ModBiblio) ISBN is still there after ModBiblio.');
    $marc = $biblio->get_from_storage->metadata->record;
    my ( $title_field, $title_subfield ) = get_title_field();
    is( $marc->subfield( $title_field, $title_subfield ), $title, );

    # Add other fields
    $marc_record->append_fields( create_field( $subtitle1, $marcflavour, get_subtitle_field() ) );
    $marc_record->append_fields( create_field( $subtitle2, $marcflavour, get_subtitle_field() ) );
    $marc_record->append_fields( create_field( $medium, $marcflavour, get_medium_field() ) );
    $marc_record->append_fields( create_field( $part_number, $marcflavour, get_part_number_field() ) );
    $marc_record->append_fields( create_field( $part_name, $marcflavour, get_part_name_field() ) );

    ModBiblio( $marc_record, $biblionumber ,'' );
    $data = GetBiblioData( $biblionumber );
    is( $data->{ title }, $title, '(ModBiblio) still there after adding other fields.' );
    is( $data->{ isbn }, $isbn, '(ModBiblio) ISBN is still there after adding other fields.' );

    is( $data->{ subtitle }, "$subtitle1 | $subtitle2", '(ModBiblio) subtitles correctly added and returned in GetBiblioData.' );
    is( $data->{ medium }, $medium, '(ModBiblio) medium correctly added and returned in GetBiblioData.' );
    is( $data->{ part_number }, $part_number, '(ModBiblio) part_number correctly added and returned in GetBiblioData.' );
    is( $data->{ part_name }, $part_name, '(ModBiblio) part_name correctly added and returned in GetBiblioData.' );

    my $biblioitem = Koha::Biblioitems->find( $biblioitemnumber );
    is( $biblioitem->_result->biblio->title, $title, # Should be $biblioitem->biblio instead, but not needed elsewhere for now
        'Do not know if this makes sense - compare result of previous two GetBiblioData tests.');
    is( $biblioitem->isbn, $isbn,
        'Second test checking it returns the correct isbn.');

    my $success = 0;
    $field = MARC::Field->new(
            655, ' ', ' ',
            'a' => 'Auction catalogs',
            '9' => '1'
            );
    eval {
        $marc_record->append_fields($field);
        $success = ModBiblio($marc_record,$biblionumber,'');
    } or do {
        diag($@);
        $success = 0;
    };
    ok($success, "ModBiblio handles authority-linked 655");

    eval {
        $field->delete_subfields('a');
        $marc_record->append_fields($field);
        $success = ModBiblio($marc_record,$biblionumber,'');
    } or do {
        diag($@);
        $success = 0;
    };
    ok($success, "ModBiblio handles 655 with authority link but no heading");

    eval {
        $field->delete_subfields('9');
        $marc_record->append_fields($field);
        $success = ModBiblio($marc_record,$biblionumber,'');
    } or do {
        diag($@);
        $success = 0;
    };
    ok($success, "ModBiblio handles 655 with no subfields");

    ## Testing GetMarcISSN
    my $issns;
    $issns = GetMarcISSN( $marc_record, $marcflavour );
    is( $issns->[0], undef,
        'GetMarcISSN handles records without the ISSN field (list is empty)' );
    is( scalar @$issns, 0,
        'GetMarcISSN handles records without the ISSN field (count is 0)' );
    # Add an ISSN field
    my $issn = '1234-1234';
    $field = create_issn_field( $issn, $marcflavour );
    $marc_record->append_fields($field);
    $issns = GetMarcISSN( $marc_record, $marcflavour );
    is( $issns->[0], $issn,
        'GetMarcISSN handles records with a single ISSN field (first element is correct)' );
    is( scalar @$issns, 1,
        'GetMARCISSN handles records with a single ISSN field (count is 1)');
    # Add multiple ISSN field
    my @more_issns = qw/1111-1111 2222-2222 3333-3333/;
    foreach (@more_issns) {
        $field = create_issn_field( $_, $marcflavour );
        $marc_record->append_fields($field);
    }
    $issns = GetMarcISSN( $marc_record, $marcflavour );
    is( scalar @$issns, 4,
        'GetMARCISSN handles records with multiple ISSN fields (count correct)');
    # Create an empty ISSN
    $field = create_issn_field( "", $marcflavour );
    $marc_record->append_fields($field);
    $issns = GetMarcISSN( $marc_record, $marcflavour );
    is( scalar @$issns, 4,
        'GetMARCISSN skips empty ISSN fields (Bug 12674)');

    ## Testing GetMarcControlnumber
    my $controlnumber;
    $controlnumber = GetMarcControlnumber( $marc_record, $marcflavour );
    is( $controlnumber, '', 'GetMarcControlnumber handles records without 001' );

    $field = MARC::Field->new( '001', '' );
    $marc_record->append_fields($field);
    $controlnumber = GetMarcControlnumber( $marc_record, $marcflavour );
    is( $controlnumber, '', 'GetMarcControlnumber handles records with empty 001' );

    $field = $marc_record->field('001');
    $field->update('123456789X');
    $controlnumber = GetMarcControlnumber( $marc_record, $marcflavour );
    is( $controlnumber, '123456789X', 'GetMarcControlnumber handles records with 001' );

    ## Testing GetMarcISBN
    my $record_for_isbn = MARC::Record->new();
    my $isbns = GetMarcISBN( $record_for_isbn, $marcflavour );
    is( scalar @$isbns, 0, '(GetMarcISBN) The record contains no ISBN');

    # We add one ISBN
    $isbn_field = create_isbn_field( $isbn, $marcflavour );
    $record_for_isbn->append_fields( $isbn_field );
    $isbns = GetMarcISBN( $record_for_isbn, $marcflavour );
    is( scalar @$isbns, 1, '(GetMarcISBN) The record contains one ISBN');
    is( $isbns->[0], $isbn, '(GetMarcISBN) The record contains our ISBN');

    # We add 3 more ISBNs
    $record_for_isbn = MARC::Record->new();
    my @more_isbns = qw/1111111111 2222222222 3333333333 444444444/;
    foreach (@more_isbns) {
        $field = create_isbn_field( $_, $marcflavour );
        $record_for_isbn->append_fields($field);
    }
    $isbns = GetMarcISBN( $record_for_isbn, $marcflavour );
    is( scalar @$isbns, 4, '(GetMarcISBN) The record contains 4 ISBNs');
    for my $i (0 .. $#more_isbns) {
        is( $isbns->[$i], $more_isbns[$i],
            "(GetMarcISBN) Correctly retrieves ISBN #". ($i + 1));
    }

    is( GetMarcPrice( $record_for_isbn, $marcflavour ), 100,
        "GetMarcPrice returns the correct value");
    my $frameworkcode = GetFrameworkCode($biblionumber);
    my $updatedrecord = $biblio->metadata->record;
    my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField( "biblioitems.biblioitemnumber" );
    die qq{No biblioitemnumber tag for framework "$frameworkcode"} unless $biblioitem_tag;
    my $biblioitemnumbertotest;
    if ( $biblioitem_tag < 10 ) {
        $biblioitemnumbertotest = $updatedrecord->field($biblioitem_tag)->data();
    } else {
        $biblioitemnumbertotest = $updatedrecord->field($biblioitem_tag)->subfield($biblioitem_subfield);
    }

    # test for GetMarcUrls
    $marc_record->append_fields(
        MARC::Field->new( '856', '', '', u => ' https://koha-community.org ' ),
        MARC::Field->new( '856', '', '', u => 'koha-community.org' ),
    );
    my $marcurl = GetMarcUrls( $marc_record, $marcflavour );
    is( @$marcurl, 2, 'GetMarcUrls returns two URLs' );
    like( $marcurl->[0]->{MARCURL}, qr/^https/, 'GetMarcUrls did not stumble over a preceding space' );
    ok( $marcflavour ne 'MARC21' || $marcurl->[1]->{MARCURL} =~ /^http:\/\//,
        'GetMarcUrls prefixed a MARC21 URL with http://' );

    # Automatic authority creation
    t::lib::Mocks::mock_preference('AutoLinkBiblios', 1);
    t::lib::Mocks::mock_preference('AutoCreateAuthorities', 1);
    my $authorities_mod = Test::MockModule->new( 'C4::Heading' );
    $authorities_mod->mock(
        'authorities',
        sub {
            my @results;
            return \@results;
        }
    );
    $success = 0;
    $field = create_author_field('Author Name');
    eval {
        $marc_record->append_fields($field);
        $success = ModBiblio($marc_record,$biblionumber,'');
    } or do {
        diag($@);
        $success = 0;
    };
    ok($success, "ModBiblio handles authority addition for author");

    my ($author_field, $author_subfield, $author_relator_subfield) = get_author_field();
    $field = $marc_record->field($author_field);
    ok($field->subfield($author_subfield), "ModBiblio keeps $author_field$author_subfield intact");

    my $authid = $field->subfield('9');
    ok($authid, 'ModBiblio adds authority id');

    use_ok('C4::AuthoritiesMarc', qw( GetAuthority ));
    my $auth_record = C4::AuthoritiesMarc::GetAuthority($authid);
    ok($auth_record, 'Authority record successfully retrieved');


    my ($auth_author_field, $auth_author_subfield) = get_auth_author_field();
    $field = $auth_record->field($auth_author_field);
    ok($field, "Authority record contains field $auth_author_field");
    is(
        $field->subfield($auth_author_subfield),
        'Author Name',
        'Authority $auth_author_field$auth_author_subfield contains author name'
    );
    is($field->subfield($author_relator_subfield), undef, 'Authority does not contain relator subfield');

    # Reset settings
    t::lib::Mocks::mock_preference('AutoLinkBiblios', 0);
    t::lib::Mocks::mock_preference('AutoCreateAuthorities', 0);
}

sub get_title_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'a' ) : ( '245', 'a' );
}

sub get_medium_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'b' ) : ( '245', 'h' );
}

sub get_subtitle_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'e' ) : ( '245', 'b' );
}

sub get_part_number_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'h' ) : ( '245', 'n' );
}

sub get_part_name_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'i' ) : ( '245', 'p' );
}

sub get_isbn_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '010', 'a' ) : ( '020', 'a' );
}

sub get_issn_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '011', 'a' ) : ( '022', 'a' );
}

sub get_itemnumber_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '995', '9' ) : ( '952', '9' );
}

sub get_author_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '700', 'a', '4' ) : ( '100', 'a', 'e' );
}

sub get_auth_author_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '106', 'a' ) : ( '100', 'a' );
}

sub create_title_field {
    my ( $title, $marcflavour ) = @_;

    my ( $title_field, $title_subfield ) = get_title_field();
    my $field = MARC::Field->new( $title_field, '', '', $title_subfield => $title );

    return $field;
}

sub create_field {
    my ( $content, $marcflavour, $field, $subfield ) = @_;

    return MARC::Field->new( $field, '', '', $subfield => $content );
}

sub create_isbn_field {
    my ( $isbn, $marcflavour ) = @_;

    my ( $isbn_field, $isbn_subfield ) = get_isbn_field();
    my $field = MARC::Field->new( $isbn_field, '', '', $isbn_subfield => $isbn );

    # Add the price subfield
    my $price_subfield = ( $marcflavour eq 'UNIMARC' ) ? 'd' : 'c';
    $field->add_subfields( $price_subfield => '$100' );

    return $field;
}

sub create_issn_field {
    my ( $issn, $marcflavour ) = @_;

    my ( $issn_field, $issn_subfield ) = get_issn_field();
    my $field = MARC::Field->new( $issn_field, '', '', $issn_subfield => $issn );

    return $field;
}

sub create_author_field {
    my ( $author ) = @_;

    my ( $author_field, $author_subfield, $author_relator_subfield ) = get_author_field();
    my $field = MARC::Field->new(
        $author_field, '', '',
        $author_subfield => $author,
        $author_relator_subfield => 'aut'
    );

    return $field;
}

subtest 'MARC21' => sub {
    plan tests => 46;
    run_tests('MARC21');
    $schema->storage->txn_rollback;
    $schema->storage->txn_begin;
};

subtest 'UNIMARC' => sub {
    plan tests => 46;

    # Mock the auth type data for UNIMARC
    $dbh->do("UPDATE auth_types SET auth_tag_to_report = '106' WHERE auth_tag_to_report = '100'") or die $dbh->errstr;

    run_tests('UNIMARC');
    $schema->storage->txn_rollback;
    $schema->storage->txn_begin;
};

subtest 'IsMarcStructureInternal' => sub {
    plan tests => 9;
    my $tagslib = GetMarcStructure();
    my @internals;
    for my $tag ( sort keys %$tagslib ) {
        next unless $tag;
        for my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
            push @internals, $subfield if IsMarcStructureInternal($tagslib->{$tag}{$subfield});
        }
    }
    @internals = uniq @internals;
    is( scalar(@internals), 7, 'expect 7 internals');
    is( grep( /^lib$/, @internals ), 1, 'check lib' );
    is( grep( /^tab$/, @internals ), 1, 'check tab' );
    is( grep( /^mandatory$/, @internals ), 1, 'check mandatory' );
    is( grep( /^repeatable$/, @internals ), 1, 'check repeatable' );
    is( grep( /^important$/, @internals ), 1, 'check important' );
    is( grep( /^a$/, @internals ), 0, 'no subfield a' );
    is( grep( /^ind1_defaultvalue$/, @internals ), 1, 'check indicator 1 default value' );
    is( grep( /^ind2_defaultvalue$/, @internals ), 1, 'check indicator 2 default value' );
};

subtest 'deletedbiblio_metadata' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
    my $biblio_metadata = C4::Biblio::GetXmlBiblio( $biblionumber );
    C4::Biblio::DelBiblio( $biblionumber );
    my ( $moved ) = $dbh->selectrow_array(q|SELECT biblionumber FROM deletedbiblio WHERE biblionumber=?|, undef, $biblionumber);
    is( $moved, $biblionumber, 'Found in deletedbiblio' );
    ( $moved ) = $dbh->selectrow_array(q|SELECT biblionumber FROM deletedbiblio_metadata WHERE biblionumber=?|, undef, $biblionumber);
    is( $moved, $biblionumber, 'Found in deletedbiblio_metadata' );
};

subtest 'DelBiblio' => sub {

    plan tests => 10;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    my ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio(MARC::Record->new, '');
    my $deleted = C4::Biblio::DelBiblio( $biblionumber );
    is( $deleted, undef, 'DelBiblio returns undef is the biblio has been deleted correctly - Must be 1 instead'); # FIXME We should return 1 instead!

    $deleted = C4::Biblio::DelBiblio( $biblionumber );
    is( $deleted, undef, 'DelBiblo should return undef is the record did not exist');

    my $biblio       = $builder->build_sample_biblio;
    my $subscription = $builder->build_object(
        {
            class => 'Koha::Subscriptions',
            value => { biblionumber => $biblio->biblionumber }
        }
    );
    my $serial = $builder->build_object(
        {
            class => 'Koha::Serials',
            value => {
                biblionumber   => $biblio->biblionumber,
                subscriptionid => $subscription->subscriptionid
            }
        }
    );
    my $subscription_history = $builder->build_object(
        {
            class => 'Koha::Subscription::Histories',
            value => {
                biblionumber   => $biblio->biblionumber,
                subscriptionid => $subscription->subscriptionid
            }
        }
    );

    my $order_basket = $builder->build( { source => 'Aqbasket' } );

    my $orderinfo = {
        biblionumber => $biblio->biblionumber,
        basketno     => $order_basket->{basketno},
    };
    my $order = $builder->build_object(
        { class => 'Koha::Acquisition::Orders', value => $orderinfo } );

    # Add some ILL requests
    my $ill_req_1 = $builder->build_object({ class => 'Koha::Illrequests', value => { biblio_id => $biblio->id, deleted_biblio_id => undef } });
    my $ill_req_2 = $builder->build_object({ class => 'Koha::Illrequests', value => { biblio_id => $biblio->id, deleted_biblio_id => undef } });

    C4::Biblio::DelBiblio($biblio->biblionumber); # Or $biblio->delete
    is( $subscription->get_from_storage, undef, 'subscription should be deleted on biblio deletion' );
    is( $serial->get_from_storage, undef, 'serial should be deleted on biblio deletion' );
    is( $subscription_history->get_from_storage, undef, 'subscription history should be deleted on biblio deletion' );
    is( $order->get_from_storage->deleted_biblionumber, $biblio->biblionumber, 'biblionumber of order has been moved to deleted_biblionumber column' );

    $ill_req_1 = $ill_req_1->get_from_storage;
    $ill_req_2 = $ill_req_2->get_from_storage;
    is( $ill_req_1->biblio_id, undef, 'biblio_id cleared on biblio deletion' );
    is( $ill_req_1->deleted_biblio_id, $biblio->id, 'biblio_id is kept on the deleted_biblio_id column' );
    is( $ill_req_2->biblio_id, undef, 'biblio_id cleared on biblio deletion' );
    is( $ill_req_2->deleted_biblio_id, $biblio->id, 'biblio_id is kept on the deleted_biblio_id column' );
};

subtest 'MarcFieldForCreatorAndModifier' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('MarcFieldForCreatorId', '998$a');
    t::lib::Mocks::mock_preference('MarcFieldForCreatorName', '998$b');
    t::lib::Mocks::mock_preference('MarcFieldForModifierId', '998$c');
    t::lib::Mocks::mock_preference('MarcFieldForModifierName', '998$d');
    my $c4_context = Test::MockModule->new('C4::Context');
    $c4_context->mock('userenv', sub { return { number => 123, firstname => 'John', surname => 'Doe'}; });

    my $record = MARC::Record->new();
    my ($biblionumber) = C4::Biblio::AddBiblio($record, '');

    my $biblio = Koha::Biblios->find($biblionumber);
    $record = $biblio->metadata->record;
    is($record->subfield('998', 'a'), 123, '998$a = 123');
    is($record->subfield('998', 'b'), 'John Doe', '998$b = John Doe');
    is($record->subfield('998', 'c'), 123, '998$c = 123');
    is($record->subfield('998', 'd'), 'John Doe', '998$d = John Doe');

    $c4_context->mock('userenv', sub { return { number => 321, firstname => 'Jane', surname => 'Doe'}; });
    C4::Biblio::ModBiblio($record, $biblionumber, '');

    $record = $biblio->get_from_storage->metadata->record;
    is($record->subfield('998', 'a'), 123, '998$a = 123');
    is($record->subfield('998', 'b'), 'John Doe', '998$b = John Doe');
    is($record->subfield('998', 'c'), 321, '998$c = 321');
    is($record->subfield('998', 'd'), 'Jane Doe', '998$d = Jane Doe');
};

subtest 'ModBiblio called from linker test' => sub {
    plan tests => 2;
    my $called = 0;
    t::lib::Mocks::mock_preference('AutoLinkBiblios', 1);
    my $biblio_mod = Test::MockModule->new( 'C4::Biblio' );
    $biblio_mod->mock( 'LinkBibHeadingsToAuthorities', sub {
        $called = 1;
    });
    my $record = MARC::Record->new();
    my ($biblionumber) = C4::Biblio::AddBiblio($record,'');
    C4::Biblio::ModBiblio($record,$biblionumber,'');
    is($called,1,"We called to link bibs because not from linker");
    $called = 0;
    C4::Biblio::ModBiblio($record,$biblionumber,'',{ disable_autolink => 1 });
    is($called,0,"We didn't call to link bibs because from linker");
};

subtest "LinkBibHeadingsToAuthorities record generation tests" => sub {
    plan tests => 12;

    # Set up mocks to ensure authorities are generated
    my $biblio_mod = Test::MockModule->new( 'C4::Linker::Default' );
    $biblio_mod->mock( 'get_link', sub {
        return (undef,undef);
    });
    # UNIMARC valid headings are built from the marc_subfield_structure for bibs and
    # include all subfields as valid, testing with MARC21 should be sufficient for now
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('AutoCreateAuthorities', '1');

    my $linker = C4::Linker::Default->new();
    my $biblio = $builder->build_sample_biblio();
    my $record = $biblio->metadata->record;

    # Generate a record including all valid subfields and an invalid one 'e'
    my $field = MARC::Field->new('650','','','a' => 'Beach city', 'b' => 'Weirdness', 'v' => 'Fiction', 'x' => 'Books', 'y' => '21st Century', 'z' => 'Fish Stew Pizza', 'e' => 'Depicted');

    $record->append_fields($field);
    my ( $num_headings_changed, $results ) = LinkBibHeadingsToAuthorities($linker, $record, "",undef,650);

    is( $num_headings_changed, 1, 'We changed the one we passed' );
    is_deeply( $results->{added},
        {"Beach city Weirdness--Fiction--Books--21st Century--Fish Stew Pizza" => 1 },
        "We added an authority record for the heading"
    );

    # Now we check the authority record itself
    my $authority = GetAuthority( $record->subfield('650','9') );
    is( $authority->field('150')->as_string(),
        "Beach city Weirdness Fiction Books 21st Century Fish Stew Pizza",
        "The generated record contains the correct subfields"
    );

    #Add test for this case using verbose
    $record->field('650')->delete_subfield('9');
    ( $num_headings_changed, $results ) = LinkBibHeadingsToAuthorities($linker, $record, "",undef, 650, 1);
    is( $num_headings_changed, 1, 'We changed the one we passed' );
    is( $results->{details}->[0]->{status}, 'CREATED', "We added an authority record for the heading using verbose");

    # Now we check the authority record itself
    $authority = GetAuthority($results->{details}->[0]->{authid});

    is( $authority->field('150')->as_string(),
         "Beach city Weirdness Fiction Books 21st Century Fish Stew Pizza",
         "The generated record contains the correct subfields when using verbose"
    );

    # Example series link with volume and punctuation
    $field = MARC::Field->new('800','','','a' => 'Tolkien, J. R. R.', 'q' => '(John Ronald Reuel),', 'd' => '1892-1973.', 't' => 'Lord of the rings ;', 'v' => '1');
    $record->append_fields($field);

    ( $num_headings_changed, $results ) = LinkBibHeadingsToAuthorities($linker, $record, "",undef, 800);

    is( $num_headings_changed, 1, 'We changed the one we passed' );
    is_deeply( $results->{added},
        {"Tolkien, J. R. R. (John Ronald Reuel), 1892-1973. Lord of the rings ;" => 1 },
        "We added an authority record for the heading"
    );

    # Now we check the authority record itself
    $authority = GetAuthority( $record->subfield('800','9') );
    is( $authority->field('100')->as_string(),
        "Tolkien, J. R. R. (John Ronald Reuel), 1892-1973. Lord of the rings",
        "The generated record contains the correct subfields"
    );

    # The same example With verbose
    $record->field('800')->delete_subfield('9');
    ( $num_headings_changed, $results ) = LinkBibHeadingsToAuthorities($linker, $record, "",undef, 800, 1);
    is( $num_headings_changed, 1, 'We changed the one we passed' );
    is( $results->{details}->[0]->{status}, 'CREATED', "We added an authority record for the heading using verbose");

    # Now we check the authority record itself
    $authority = GetAuthority($results->{details}->[0]->{authid});
    is( $authority->field('100')->as_string(),
         "Tolkien, J. R. R. (John Ronald Reuel), 1892-1973. Lord of the rings",
         "The generated record contains the correct subfields"
    );
};

subtest 'autoControlNumber tests' => sub {

    plan tests => 3;

    t::lib::Mocks::mock_preference('autoControlNumber', 'OFF');

    my $record = MARC::Record->new();
    my ($biblio_id) = C4::Biblio::AddBiblio($record, '');
    my $biblio = Koha::Biblios->find($biblio_id);

    $record = $biblio->metadata->record;
    is($record->field('001'), undef, '001 not set when pref is off');

    t::lib::Mocks::mock_preference('autoControlNumber', 'biblionumber');
    C4::Biblio::ModBiblio($record, $biblio_id, "", { skip_record_index => 1, disable_autolink => 1 });
    $biblio->discard_changes;
    $record = $biblio->metadata->record;
    is($record->field('001')->as_string(), $biblio_id, '001 set to biblionumber when pref set and field is blank');

    $record->field('001')->update('Not biblionumber');
    C4::Biblio::ModBiblio($record, $biblio_id, "", { skip_record_index => 1, disable_autolink => 1 });
    $biblio->discard_changes;
    $record = $biblio->metadata->record;
    is($record->field('001')->as_string(), 'Not biblionumber', '001 not set to biblionumber when pref set and field exists');

};

subtest 'record test' => sub {
    plan tests => 1;

    my $marc_record = MARC::Record->new;
    $marc_record->append_fields( create_isbn_field( '0590353403', 'MARC21' ) );

    my ($biblionumber) = C4::Biblio::AddBiblio( $marc_record, '' );

    my $biblio = Koha::Biblios->find($biblionumber);

    is( $biblio->record->as_formatted,
        $biblio->metadata->record->as_formatted );
};



# Cleanup
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
$schema->storage->txn_rollback;
