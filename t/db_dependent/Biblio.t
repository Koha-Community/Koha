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

use Test::More tests => 9;
use Test::MockModule;
use List::MoreUtils qw( uniq );
use MARC::Record;

use t::lib::Mocks qw( mock_preference );
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Caches;
use Koha::MarcSubfieldStructures;

BEGIN {
    use_ok('C4::Biblio');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

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

# Mocking variables
my $biblio_module = new Test::MockModule('C4::Biblio');
$biblio_module->mock(
    'GetMarcSubfieldStructure',
    sub {
        my ($self) = shift;

        my ( $title_field,            $title_subfield )            = get_title_field();
        my ( $isbn_field,             $isbn_subfield )             = get_isbn_field();
        my ( $issn_field,             $issn_subfield )             = get_issn_field();
        my ( $biblionumber_field,     $biblionumber_subfield )     = ( '999', 'c' );
        my ( $biblioitemnumber_field, $biblioitemnumber_subfield ) = ( '999', '9' );
        my ( $itemnumber_field,       $itemnumber_subfield )       = get_itemnumber_field();

        return {
            'biblio.title'                 => [ { tagfield => $title_field,            tagsubfield => $title_subfield } ],
            'biblio.biblionumber'          => [ { tagfield => $biblionumber_field,     tagsubfield => $biblionumber_subfield } ],
            'biblioitems.isbn'             => [ { tagfield => $isbn_field,             tagsubfield => $isbn_subfield } ],
            'biblioitems.issn'             => [ { tagfield => $issn_field,             tagsubfield => $issn_subfield } ],
            'biblioitems.biblioitemnumber' => [ { tagfield => $biblioitemnumber_field, tagsubfield => $biblioitemnumber_subfield } ],
            'items.itemnumber'             => [ { tagfield => $itemnumber_subfield,    tagsubfield => $itemnumber_subfield } ],
        };
      }
);

my $currency = new Test::MockModule('Koha::Acquisition::Currencies');
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

    my $isbn = '0590353403';
    my $title = 'Foundation';

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

    my ( $isbn_field, $isbn_subfield ) = get_isbn_field();
    my $marc = GetMarcBiblio({ biblionumber => $biblionumber });
    is( $marc->subfield( $isbn_field, $isbn_subfield ), $isbn, );

    # Add title
    my $field = create_title_field( $title, $marcflavour );
    $marc_record->append_fields( $field );
    ModBiblio( $marc_record, $biblionumber ,'' );
    $data = GetBiblioData( $biblionumber );
    is( $data->{ title }, $title,
        'ModBiblio correctly added the title field, and GetBiblioData.');
    is( $data->{ isbn }, $isbn, '(ModBiblio) ISBN is still there after ModBiblio.');
    $marc = GetMarcBiblio({ biblionumber => $biblionumber });
    my ( $title_field, $title_subfield ) = get_title_field();
    is( $marc->subfield( $title_field, $title_subfield ), $title, );

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
    my $newincbiblioitemnumber=$biblioitemnumber+1;
    $dbh->do("UPDATE biblioitems SET biblioitemnumber = ? WHERE biblionumber = ?;", undef, $newincbiblioitemnumber, $biblionumber );
    my $updatedrecord = GetMarcBiblio({
        biblionumber => $biblionumber,
        embed_items  => 0 });
    my $frameworkcode = GetFrameworkCode($biblionumber);
    my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField( "biblioitems.biblioitemnumber", $frameworkcode );
    die qq{No biblioitemnumber tag for framework "$frameworkcode"} unless $biblioitem_tag;
    my $biblioitemnumbertotest;
    if ( $biblioitem_tag < 10 ) {
        $biblioitemnumbertotest = $updatedrecord->field($biblioitem_tag)->data();
    } else {
        $biblioitemnumbertotest = $updatedrecord->field($biblioitem_tag)->subfield($biblioitem_subfield);
    }
    is ($newincbiblioitemnumber, $biblioitemnumbertotest, 'Check newincbiblioitemnumber');

    # test for GetMarcNotes
    my $a1= GetMarcNotes( $marc_record, $marcflavour );
    my $field2 = MARC::Field->new( $marcflavour eq 'UNIMARC'? 300: 555, 0, '', a=> 'Some text', u=> 'http://url-1.com', u=> 'nohttp://something_else' );
    $marc_record->append_fields( $field2 );
    my $a2= GetMarcNotes( $marc_record, $marcflavour );
    is( ( $marcflavour eq 'UNIMARC' && @$a2 == @$a1 + 1 ) ||
        ( $marcflavour ne 'UNIMARC' && @$a2 == @$a1 + 3 ), 1,
        'Check the number of returned notes of GetMarcNotes' );

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
}

sub get_title_field {
    my $marc_flavour = C4::Context->preference('marcflavour');
    return ( $marc_flavour eq 'UNIMARC' ) ? ( '200', 'a' ) : ( '245', 'a' );
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

sub create_title_field {
    my ( $title, $marcflavour ) = @_;

    my ( $title_field, $title_subfield ) = get_title_field();
    my $field = MARC::Field->new( $title_field, '', '', $title_subfield => $title );

    return $field;
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

subtest 'MARC21' => sub {
    plan tests => 34;
    run_tests('MARC21');
    $schema->storage->txn_rollback;
    $schema->storage->txn_begin;
};

subtest 'UNIMARC' => sub {
    plan tests => 34;
    run_tests('UNIMARC');
    $schema->storage->txn_rollback;
    $schema->storage->txn_begin;
};

subtest 'NORMARC' => sub {
    plan tests => 34;
    run_tests('NORMARC');
    $schema->storage->txn_rollback;
    $schema->storage->txn_begin;
};

subtest 'IsMarcStructureInternal' => sub {
    plan tests => 8;
    my $tagslib = GetMarcStructure();
    my @internals;
    for my $tag ( sort keys %$tagslib ) {
        next unless $tag;
        for my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
            push @internals, $subfield if IsMarcStructureInternal($tagslib->{$tag}{$subfield});
        }
    }
    @internals = uniq @internals;
    is( scalar(@internals), 6, 'expect 6 internals');
    is( grep( /^lib$/, @internals ), 1, 'check lib' );
    is( grep( /^tab$/, @internals ), 1, 'check tab' );
    is( grep( /^mandatory$/, @internals ), 1, 'check mandatory' );
    is( grep( /^repeatable$/, @internals ), 1, 'check repeatable' );
    is( grep( /^a$/, @internals ), 0, 'no subfield a' );
    is( grep( /^ind1_defaultvalue$/, @internals ), 1, 'check indicator 1 default value' );
    is( grep( /^ind2_defaultvalue$/, @internals ), 1, 'check indicator 2 default value' );
};

subtest 'deletedbiblio_metadata' => sub {
    plan tests => 2;

    my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
    my $biblio_metadata = C4::Biblio::GetXmlBiblio( $biblionumber );
    C4::Biblio::DelBiblio( $biblionumber );
    my ( $moved ) = $dbh->selectrow_array(q|SELECT biblionumber FROM deletedbiblio WHERE biblionumber=?|, undef, $biblionumber);
    is( $moved, $biblionumber, 'Found in deletedbiblio' );
    ( $moved ) = $dbh->selectrow_array(q|SELECT biblionumber FROM deletedbiblio_metadata WHERE biblionumber=?|, undef, $biblionumber);
    is( $moved, $biblionumber, 'Found in deletedbiblio_metadata' );
};

# Cleanup
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
$schema->storage->txn_rollback;
