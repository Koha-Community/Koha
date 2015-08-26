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

use Test::More tests => 6;
use Test::MockModule;

use List::MoreUtils qw( uniq );
use MARC::Record;
use t::lib::Mocks qw( mock_preference );

BEGIN {
    use_ok('C4::Biblio');
}

my $dbh = C4::Context->dbh;
# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Mocking variables
my $context = new Test::MockModule('C4::Context');

mock_marcfromkohafield();

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

    # Undef C4::Biblio::inverted_field_map to avoid problems introduced
    # by caching in TransformMarcToKoha
    undef $C4::Biblio::inverted_field_map;

    my $marcflavour = shift;
    t::lib::Mocks::mock_preference('marcflavour', $marcflavour);

    my $isbn = '0590353403';
    my $title = 'Foundation';

    # Generate a record with just the ISBN
    my $marc_record = MARC::Record->new;
    my $isbn_field  = create_isbn_field( $isbn, $marcflavour );
    $marc_record->append_fields( $isbn_field );

    # Add the record to the DB
    my( $biblionumber, $biblioitemnumber ) = AddBiblio( $marc_record, '' );
    my $data = GetBiblioData( $biblionumber );
    is( $data->{ isbn }, $isbn,
        '(GetBiblioData) ISBN correctly retireved.');
    is( $data->{ title }, undef,
        '(GetBiblioData) Title field is empty in fresh biblio.');

    # Add title
    my $field = create_title_field( $title, $marcflavour );
    $marc_record->append_fields( $field );
    ModBiblio( $marc_record, $biblionumber ,'' );
    $data = GetBiblioData( $biblionumber );
    is( $data->{ title }, $title,
        'ModBiblio correctly added the title field, and GetBiblioData.');
    is( $data->{ isbn }, $isbn, '(ModBiblio) ISBN is still there after ModBiblio.');

    my $itemdata = GetBiblioItemData( $biblioitemnumber );
    is( $itemdata->{ title }, $title,
        'First test of GetBiblioItemData to get same result of previous two GetBiblioData tests.');
    is( $itemdata->{ isbn }, $isbn,
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
            "(GetMarcISBN) Corretly retrieves ISBN #". ($i + 1));
    }

    is( GetMarcPrice( $record_for_isbn, $marcflavour ), 100,
        "GetMarcPrice returns the correct value");
    my $newincbiblioitemnumber=$biblioitemnumber+1;
    $dbh->do("UPDATE biblioitems SET biblioitemnumber = ? WHERE biblionumber = ?;", undef, $newincbiblioitemnumber, $biblionumber );
    my $updatedrecord = GetMarcBiblio($biblionumber, 0);
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
}

sub mock_marcfromkohafield {

    $context->mock('marcfromkohafield',
        sub {
            my ( $self ) = shift;

            if ( C4::Context->preference('marcflavour') eq 'MARC21' ||
                 C4::Context->preference('marcflavour') eq 'NORMARC' ) {

                return  {
                '' => {
                    'biblio.title' => [ '245', 'a' ],
                    'biblio.biblionumber' => [ '999', 'c' ],
                    'biblioitems.isbn' => [ '020', 'a' ],
                    'biblioitems.issn' => [ '022', 'a' ],
                    'biblioitems.biblioitemnumber' => [ '999', 'd' ]
                    }
                };
            } elsif ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {

                return {
                '' => {
                    'biblio.title' => [ '200', 'a' ],
                    'biblio.biblionumber' => [ '999', 'c' ],
                    'biblioitems.isbn' => [ '010', 'a' ],
                    'biblioitems.issn' => [ '011', 'a' ],
                    'biblioitems.biblioitemnumber' => [ '090', 'a' ]
                    }
                };
            }
        });
}

sub create_title_field {
    my ( $title, $marcflavour ) = @_;

    my $title_field = ( $marcflavour eq 'UNIMARC' ) ? '200' : '245';
    my $field = MARC::Field->new( $title_field,'','','a' => $title);

    return $field;
}

sub create_isbn_field {
    my ( $isbn, $marcflavour ) = @_;

    my $isbn_field = ( $marcflavour eq 'UNIMARC' ) ? '010' : '020';
    my $field = MARC::Field->new( $isbn_field,'','','a' => $isbn);
    # Add the price subfield
    my $price_subfield = ( $marcflavour eq 'UNIMARC' ) ? 'd' : 'c' ;
    $field->add_subfields( $price_subfield => '$100' );

    return $field;
}

sub create_issn_field {
    my ( $issn, $marcflavour ) = @_;

    my $issn_field = ( $marcflavour eq 'UNIMARC' ) ? '011' : '022';
    my $field = MARC::Field->new( $issn_field,'','','a' => $issn);

    return $field;
}

subtest 'MARC21' => sub {
    plan tests => 29;
    run_tests('MARC21');
    $dbh->rollback;
};

subtest 'UNIMARC' => sub {
    plan tests => 29;
    run_tests('UNIMARC');
    $dbh->rollback;
};

subtest 'NORMARC' => sub {
    plan tests => 29;
    run_tests('NORMARC');
    $dbh->rollback;
};

subtest 'GetMarcSubfieldStructureFromKohaField' => sub {
    plan tests => 23;

    my @columns = qw(
        tagfield tagsubfield liblibrarian libopac repeatable mandatory kohafield tab
        authorised_value authtypecode value_builder isurl hidden frameworkcode
        seealso link defaultvalue maxlength
    );

    # biblio.biblionumber must be mapped so this should return something
    my $marc_subfield_structure = GetMarcSubfieldStructureFromKohaField('biblio.biblionumber', '');

    ok(defined $marc_subfield_structure, "There is a result");
    is(ref $marc_subfield_structure, "HASH", "Result is a hashref");
    foreach my $col (@columns) {
        ok(exists $marc_subfield_structure->{$col}, "Hashref contains key '$col'");
    }
    is($marc_subfield_structure->{kohafield}, 'biblio.biblionumber', "Result is the good result");
    like($marc_subfield_structure->{tagfield}, qr/^\d{3}$/, "tagfield is a valid tagfield");

    # foo.bar does not exist so this should return undef
    $marc_subfield_structure = GetMarcSubfieldStructureFromKohaField('foo.bar', '');
    is($marc_subfield_structure, undef, "invalid kohafield returns undef");
};

subtest 'IsMarcStructureInternal' => sub {
    plan tests => 6;
    my $tagslib = GetMarcStructure();
    my @internals;
    for my $tag ( sort keys %$tagslib ) {
        next unless $tag;
        for my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
            push @internals, $subfield if IsMarcStructureInternal($tagslib->{$tag}{$subfield});
        }
    }
    @internals = uniq @internals;
    is( scalar(@internals), 4, 'expect four internals');
    is( grep( /^lib$/, @internals ), 1, 'check lib' );
    is( grep( /^tab$/, @internals ), 1, 'check tab' );
    is( grep( /^mandatory$/, @internals ), 1, 'check mandatory' );
    is( grep( /^repeatable$/, @internals ), 1, 'check repeatable' );
    is( grep( /^a$/, @internals ), 0, 'no subfield a' );
};

1;
