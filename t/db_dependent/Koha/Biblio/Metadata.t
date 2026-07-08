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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;
use Test::Exception;
use Test::MockModule;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Biblio qw( AddBiblio );
use Koha::Database;
use MARC::Record;
use MARC::Field;

BEGIN {
    use_ok('Koha::Biblio::Metadatas');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Testing store() method' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    # Create a test bibliographic record
    my $biblio = $builder->build(
        {
            source => 'Biblio',
        }
    );

    subtest 'Valid MARCXML storage' => sub {
        plan tests => 2;
        $schema->storage->txn_begin;

        my $marc_rec = MARC::Record->new;
        $marc_rec->append_fields( MARC::Field->new( '245', '', '', 'a' => 'Test Title' ) );
        my $valid_marcxml = $marc_rec->as_xml_record('MARC21');

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => $valid_marcxml,
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );

        lives_ok { $record->store }
        'Valid MARCXML record stores successfully';
        is(
            $record->metadata_errors->search( { error_type => 'nonxml_stripped' } )->count,
            0, 'No nonxml_stripped error for clean record'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'MARCXML with strippable non-XML characters' => sub {
        plan tests => 4;
        $schema->storage->txn_begin;

        # Build MARCXML containing a non-XML control character (chr(31) = Unit Separator)
        my $bad_title   = 'Title with' . chr(31) . ' bad character';
        my $clean_title = 'Title with bad character';

        # Generate the MARCXML string with the embedded bad character
        my $marc_record = MARC::Record->new;
        $marc_record->append_fields( MARC::Field->new( '245', '', '', 'a' => $bad_title ) );
        my $marcxml_with_bad_char = $marc_record->as_xml_record('MARC21');

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => $marcxml_with_bad_char,
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );

        lives_ok { $record->store } 'MARCXML with strippable characters stores successfully';

        my @errors = $record->metadata_errors->search( { error_type => 'nonxml_stripped' } )->as_list;
        ok( scalar @errors, 'nonxml_stripped error(s) recorded after stripping' );
        like(
            $errors[0]->message,
            qr/245\$a: invalid char value 31 \(U\+001F\) at position \d+/,
            'error message identifies field, char value, and position'
        );

        my $stored = Koha::Biblio::Metadatas->find( { biblionumber => $biblio->{biblionumber}, format => 'marcxml' } );
        is(
            $stored->record->field('245')->subfield('a'),
            $clean_title,
            'Stored record has control character removed'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'MARCXML with an empty datafield' => sub {
        plan tests => 4;
        $schema->storage->txn_begin;

        # A datafield with no subfields at all cannot be produced via the public MARC::Field
        # API (it refuses to construct one), but legacy data saved before this validation
        # existed can contain exactly that. Simulate it by poking the internal structure.
        my $marc_record = MARC::Record->new;
        $marc_record->append_fields( MARC::Field->new( '245', '', '', 'a' => 'Test Title' ) );
        my $empty_field = MARC::Field->new( '500', ' ', ' ', 'a' => 'placeholder' );
        $empty_field->{_subfields} = [];
        $marc_record->append_fields($empty_field);
        my $marcxml_with_empty_field = $marc_record->as_xml_record('MARC21');

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => $marcxml_with_empty_field,
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );

        lives_ok { $record->store } 'MARCXML with an empty datafield stores successfully';

        my @errors = $record->metadata_errors->search( { error_type => 'empty_datafield_stripped' } )->as_list;
        ok( scalar @errors, 'empty_datafield_stripped error(s) recorded after stripping' );
        like(
            $errors[0]->message,
            qr/^500: field removed, it had no subfields/,
            'error message identifies the removed field'
        );

        my $stored = Koha::Biblio::Metadatas->find( { biblionumber => $biblio->{biblionumber}, format => 'marcxml' } );
        ok( !$stored->record->field('500'), 'Stored record no longer has the empty field' );

        $schema->storage->txn_rollback;
    };

    subtest 'MARCXML with both strippable characters and an empty datafield' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $marc_record = MARC::Record->new;
        $marc_record->append_fields( MARC::Field->new( '245', '', '', 'a' => 'Bad' . chr(31) . ' Title' ) );
        my $empty_field = MARC::Field->new( '500', ' ', ' ', 'a' => 'placeholder' );
        $empty_field->{_subfields} = [];
        $marc_record->append_fields($empty_field);
        my $marcxml = $marc_record->as_xml_record('MARC21');

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => $marcxml,
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );

        lives_ok { $record->store } 'MARCXML with both faults stores successfully';
        ok(
            $record->metadata_errors->search( { error_type => 'nonxml_stripped' } )->count,
            'nonxml_stripped error recorded'
        );
        ok(
            $record->metadata_errors->search( { error_type => 'empty_datafield_stripped' } )->count,
            'empty_datafield_stripped error recorded'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'Non-MARCXML format' => sub {
        plan tests => 1;
        $schema->storage->txn_begin;
        my $other_metadata = '{"title": "Test Title"}';

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'json',
                metadata     => $other_metadata,
                biblionumber => $biblio->{biblionumber},
                schema       => 'LOCAL',
            }
        );

        lives_ok { $record->store }
        'Non-MARCXML record stores without validation';
        $schema->storage->txn_rollback;
    };

    subtest 'Empty MARCXML handling' => sub {
        plan tests => 1;
        $schema->storage->txn_begin;
        my $empty_record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => '',
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );

        throws_ok { $empty_record->store }
        'Koha::Exceptions::Metadata::Invalid',
            'Empty MARCXML throws expected exception';
        $schema->storage->txn_rollback;
    };

    subtest 'Re-saving a record with the same recoverable fault does not duplicate the error row' => sub {
        plan tests => 2;
        $schema->storage->txn_begin;

        my $bad_title   = 'Title with' . chr(31) . ' bad character';
        my $marc_record = MARC::Record->new;
        $marc_record->append_fields( MARC::Field->new( '245', '', '', 'a' => $bad_title ) );
        my $marcxml_with_bad_char = $marc_record->as_xml_record('MARC21');

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => $marcxml_with_bad_char,
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );
        $record->store;

        # Simulate the same dirty source record being re-harvested/re-imported again
        # before anyone fixes the underlying data.
        $record->metadata($marcxml_with_bad_char);
        $record->store;

        is(
            $record->metadata_errors->search( { error_type => 'nonxml_stripped' } )->count,
            1, 'Re-triggering the exact same fault does not create a duplicate error row'
        );
        is(
            Koha::Biblio::Metadatas->find( { biblionumber => $biblio->{biblionumber}, format => 'marcxml' } )
                ->record->subfield( '245', 'a' ),
            'Title with bad character',
            'The record is still stored with the control character removed'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'Pre-existing error rows survive a clean re-save' => sub {
        plan tests => 1;
        $schema->storage->txn_begin;

        my $bad_title   = 'Title with' . chr(31) . ' bad character';
        my $marc_record = MARC::Record->new;
        $marc_record->append_fields( MARC::Field->new( '245', '', '', 'a' => $bad_title ) );

        my $record = Koha::Biblio::Metadata->new(
            {
                format       => 'marcxml',
                metadata     => $marc_record->as_xml_record('MARC21'),
                biblionumber => $biblio->{biblionumber},
                schema       => 'MARC21',
            }
        );
        $record->store;    # records the nonxml_stripped error row

        # Re-save with already-clean MARCXML, as if the cataloguer just edited an unrelated
        # field - the earlier fault has not been explicitly resolved.
        my $clean_record = MARC::Record->new;
        $clean_record->append_fields( MARC::Field->new( '245', '', '', 'a' => 'Title with bad character' ) );
        $record->metadata( $clean_record->as_xml_record('MARC21') );
        $record->store;

        is(
            $record->metadata_errors->search( { error_type => 'nonxml_stripped' } )->count,
            1,
            'The pre-existing error row is left in place after a subsequent clean save, since resolution is explicit'
        );

        $schema->storage->txn_rollback;
    };
};

subtest 'record() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $title = 'Oranges and Peaches';

    # Create a valid record
    my $record = MARC::Record->new();
    my $field  = MARC::Field->new( '245', '', '', 'a' => $title );
    my $f952_1 = MARC::Field->new(
        '952', '', '', 0 => '1',
        y => 'BK',
        c => 'GEN',
        d => '2001-06-25',
    );
    my $f952_2 = MARC::Field->new(
        '952', '', '', 0 => '1',
        y => 'BK',
        c => 'GEN',
        d => '2001-06-25',
    );
    $record->append_fields( $field, $f952_1, $f952_2 );
    my ($biblio_id) = C4::Biblio::AddBiblio( $record, '' );

    my @fields_952 = $record->field('952');
    is( scalar @fields_952, 2, 'The record to be inserted contains 2 item fields' );

    my $c4_biblio = Test::MockModule->new('C4::Biblio');
    $c4_biblio->mock( 'GetMarcFromKohaField', sub { return '952'; } );

    my $metadata = Koha::Biblios->find($biblio_id)->metadata;
    my $record2  = $metadata->record;

    @fields_952 = $record2->field('952');
    is( scalar @fields_952, 0, 'Item fields stripped out then calling $metadata->record' );

    is( ref $record2, 'MARC::Record', 'Method record() returned a MARC::Record object' );
    is(
        $record2->field('245')->subfield("a"),
        $title, 'Title in 245$a matches title from original record object'
    );

    my $bad_data = $builder->build_object(
        {
            class => 'Koha::Biblio::Metadatas',
            value => { format => 'marcxml', schema => 'MARC21', metadata => 'this_is_not_marcxml' }
        }
    );

    warning_like {
        throws_ok { $bad_data->record; }
        'Koha::Exceptions::Metadata::Invalid', 'Exception thrown on bad record';
    }
    qr/parser error : Start tag expected, '<' not found/,
        'Warning thrown excplicitly';

    my $exception = $@;
    is( $exception->id,     $bad_data->id, 'id passed correctly to exception' );
    is( $exception->format, 'marcxml',     'format passed correctly to exception' );
    is( $exception->schema, 'MARC21',      'schema passed correctly to exception' );

    my $bad_format = $builder->build_object(
        {
            class => 'Koha::Biblio::Metadatas',
            value => { format => 'mij', schema => 'MARC21', metadata => 'something' }
        }
    );

    throws_ok { $bad_format->record; }
    'Koha::Exceptions::Metadata', 'Exception thrown on unhandled format';

    is(
        "$@",
        'Koha::Biblio::Metadata->record called on unhandled format: mij',
        'Exception message built correctly'
    );

    $schema->storage->txn_rollback;
};

subtest 'record_strip_nonxml() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $title = 'Oranges and Peaches';

    # Create a valid record
    my $record = MARC::Record->new();
    my $field  = MARC::Field->new( '245', '', '', 'a' => $title );
    $record->append_fields($field);
    my ($biblio_id) = C4::Biblio::AddBiblio( $record, '' );

    my $metadata = Koha::Biblios->find($biblio_id)->metadata;

    # Update the record in the database directly to include our error character
    my $bad_title = 'Oranges and' . chr(31) . ' Peaches';
    $record = $metadata->record;
    $record->delete_fields( $record->field('245') );
    $record->insert_fields_ordered( MARC::Field->new( '245', '', '', 'a' => $bad_title ) );
    $metadata->_result->update( { metadata => $record->as_xml_record } );
    $metadata->discard_changes;

    my $record2 = $metadata->record_strip_nonxml;

    is( ref $record2, 'MARC::Record', 'Method record() returned a MARC::Record object' );
    is(
        $record2->field('245')->subfield("a"),
        "Oranges and Peaches", 'Title in 245$a matches title with control character removed'
    );

    my $bad_data = $builder->build_object(
        {
            class => 'Koha::Biblio::Metadatas',
            value => { format => 'marcxml', schema => 'MARC21', metadata => 'this_is_not_marcxml' }
        }
    );

    warning_like { $record2 = $bad_data->record_strip_nonxml; }
    qr/parser error : Start tag expected, '<' not found/,
        'Warning thrown explicitly';

    is(
        $record2, undef,
        "record_strip_nonxml returns undef when the record cannot be parsed after removing nonxml characters"
    );

    my $item = $builder->build_sample_item( { biblionumber => $metadata->biblionumber } );

    # Emptied the OpacHiddenItems pref
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', '' );
    my ($itemfield) = C4::Biblio::GetMarcFromKohaField('items.itemnumber');

    $record2 = $metadata->record_strip_nonxml( { embed_items => 1 } );

    my @items = $record2->field($itemfield);

    is( scalar @items, 1, "We got back our item" );

    $schema->storage->txn_rollback;
};

subtest '_embed_items' => sub {
    plan tests => 10;

    $schema->storage->txn_begin();

    my $builder  = t::lib::TestBuilder->new;
    my $library1 = $builder->build(
        {
            source => 'Branch',
        }
    );
    my $library2 = $builder->build(
        {
            source => 'Branch',
        }
    );
    my $itemtype = $builder->build(
        {
            source => 'Itemtype',
        }
    );

    my $biblio     = $builder->build_sample_biblio();
    my $item_infos = [
        { homebranch => $library1->{branchcode}, holdingbranch => $library1->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library1->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library1->{branchcode} },
        { homebranch => $library2->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library2->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library2->{branchcode} },
    ];
    my $number_of_items = scalar @$item_infos;
    my $number_of_items_with_homebranch_is_CPL =
        grep { $_->{homebranch} eq $library1->{branchcode} } @$item_infos;

    my @itemnumbers;
    for my $item_info (@$item_infos) {
        my $itemnumber = $builder->build_sample_item(
            {
                biblionumber  => $biblio->biblionumber,
                homebranch    => $item_info->{homebranch},
                holdingbranch => $item_info->{holdingbranch},
                itype         => $itemtype->{itemtype}
            }
        )->itemnumber;

        push @itemnumbers, $itemnumber;
    }

    # Emptied the OpacHiddenItems pref
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', '' );

    throws_ok { Koha::Biblio::Metadata->record() }
    'Koha::Exceptions::Metadata',
        'Koha::Biblio::Metadata->record must be called on an instantiated object or like a class method with a record passed in parameter';

    my ($itemfield) = C4::Biblio::GetMarcFromKohaField('items.itemnumber');
    my $record = $biblio->metadata->record;
    Koha::Biblio::Metadata->record(
        {
            record       => $record,
            embed_items  => 1,
            biblionumber => $biblio->biblionumber
        }
    );
    my @items = $record->field($itemfield);
    is( scalar @items, $number_of_items, 'Should return all items' );

    my $marc_with_items = $biblio->metadata->record( { embed_items => 1 } );
    is_deeply( $record, $marc_with_items, 'A direct call to GetMarcBiblio with items matches' );

    $record = $biblio->metadata->record( { embed_items => 1, itemnumbers => [ $itemnumbers[1], $itemnumbers[3] ] } );
    @items  = $record->field($itemfield);
    is( scalar @items, 2, 'Should return all items present in the list' );

    $record = $biblio->metadata->record( { embed_items => 1, opac => 1 } );
    @items  = $record->field($itemfield);
    is( scalar @items, $number_of_items, 'Should return all items for opac' );

    my $opachiddenitems = "
        homebranch: ['$library1->{branchcode}']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );

    $record = $biblio->metadata->record( { embed_items => 1 } );
    @items  = $record->field($itemfield);
    is(
        scalar @items,
        $number_of_items,
        'Even with OpacHiddenItems set, all items should have been embedded'
    );

    $record = $biblio->metadata->record( { embed_items => 1, opac => 1 } );
    @items  = $record->field($itemfield);
    is(
        scalar @items,
        $number_of_items - $number_of_items_with_homebranch_is_CPL,
        'For OPAC, the pref OpacHiddenItems should have been take into account. Only items with homebranch ne CPL should have been embedded'
    );

    $opachiddenitems = "
        homebranch: ['$library1->{branchcode}', '$library2->{branchcode}']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    $record = $biblio->metadata->record( { embed_items => 1, opac => 1 } );
    @items  = $record->field($itemfield);
    is(
        scalar @items,
        0,
        'For OPAC, If all items are hidden, no item should have been embedded'
    );

    # Check position of 952 in response of embed_items marc
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', q{} );
    $record = $biblio->metadata->record;
    $record->insert_fields_ordered(
        MARC::Field->new( '951', '', '', a => 'before items' ),
        MARC::Field->new( '953', '', '', a => 'after  items' ),
    );
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber, q{} );
    my $field_list = join ',', map { $_->tag } $record->fields;
    ok( $field_list =~ /951,953/, "951 and 953 in $field_list" );
    $biblio->discard_changes;
    $record     = $biblio->metadata->record( { embed_items => 1 } );
    $field_list = join ',', map { $_->tag } $record->fields;
    ok( $field_list =~ /951,(952,)+953/, "951-952s-953 in $field_list" );

    $schema->storage->txn_rollback;
};

subtest 'record_source() and source_allows_editing() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $metadata = $biblio->metadata;
    is( $metadata->record_source_id, undef, 'No record source defined for metadata object' );
    ok( $metadata->source_allows_editing, 'No record source, can be edited' );
    is( $metadata->record_source, undef );

    my $source = $builder->build_object( { class => 'Koha::RecordSources', value => { can_be_edited => 1 } } );
    $metadata->record_source_id( $source->id )->store();

    my $retrieved_source = $metadata->record_source;

    ok( $metadata->source_allows_editing, 'Record source allows, can be edited' );
    is( ref($retrieved_source), 'Koha::RecordSource' );
    is( $retrieved_source->id,  $source->id );

    $source->can_be_edited(0)->store();
    $metadata->discard_changes;

    ok( !$metadata->source_allows_editing, 'Record source does not allow, cannot be edited' );

    $schema->storage->txn_rollback;
};
