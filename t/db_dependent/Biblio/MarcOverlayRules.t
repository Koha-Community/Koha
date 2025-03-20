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
use Try::Tiny;
use POSIX qw(floor);

use MARC::Record;

use C4::Context;
use C4::Biblio qw( AddBiblio ModBiblio DelBiblio );
use Koha::Database;
use Koha::Biblios;

use Test::NoWarnings;
use Test::More tests => 25;
use Test::MockModule;

use Koha::MarcOverlayRules;

use t::lib::Mocks;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

t::lib::Mocks::mock_preference( 'MARCOverlayRules', '1' );

Koha::MarcOverlayRules->search->delete;

sub build_record {
    my ($fields) = @_;
    my $record = MARC::Record->new;
    my @marc_fields;
    for my $f (@$fields) {
        my $tag = $f->[0];
        my @subfields;
        for my $i ( 1 .. ( scalar(@$f) / 2 ) ) {
            my $ii = floor( $i * 2 );
            push @subfields, $f->[ $ii - 1 ], $f->[$ii];
        }
        push @marc_fields, MARC::Field->new( $tag, '', '', @subfields );
    }

    $record->append_fields(@marc_fields);
    return $record;
}

# Create a record
my $orig_record = build_record(
    [
        [ '250', 'a', '250 bottles of beer on the wall' ],
        [ '250', 'a', '256 bottles of beer on the wall' ],
        [ '500', 'a', 'One bottle of beer in the fridge' ],
    ]
);

my $incoming_record = build_record(
    [
        [ '250', 'a', '256 bottles of beer on the wall' ],    # Unchanged
        [ '250', 'a', '251 bottles of beer on the wall' ],    # Appended
            # ['250', 'a', '250 bottles of beer on the wall'],          # Removed
            # ['500', 'a', 'One bottle of beer in the fridge'],         # Deleted
        [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # Added
        [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # Added
    ]
);

# Test default behavior when MARCOverlayRules is enabled, but no rules defined (overwrite)
subtest 'No rule defined' => sub {
    plan tests => 1;

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'Incoming record used as it with no rules defined'
    );

};

my $rule = Koha::MarcOverlayRules->find_or_create(
    {
        tag    => '*',
        module => 'source',
        filter => '*',
        add    => 0,
        append => 0,
        remove => 0,
        delete => 0
    }
);

subtest 'Record fields has been protected when matched merge all rule operations are set to "0"' => sub {
    plan tests => 1;

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $orig_record->as_formatted,
        'Record not modified if all op=0'
    );

};

subtest '"Add new" - Only new fields has been added when add = 1, append = 0, remove = 0, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 0,
            'remove' => 0,
            'delete' => 0,
        }
    )->store();

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    my $expected_record = build_record(
        [
            [ '250', 'a', '250 bottles of beer on the wall' ],           # original
            [ '250', 'a', '256 bottles of beer on the wall' ],           # original
            [ '500', 'a', 'One bottle of beer in the fridge' ],          # original
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );
    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Add fields from the incoming record that are not in the original record'
    );

};

subtest 'Only appended fields has been added when add = 0, append = 1, remove = 0, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 1,
            'remove' => 0,
            'delete' => 0,
        }
    )->store;

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    my $expected_record = build_record(
        [
            [ '250', 'a', '250 bottles of beer on the wall' ],     # original
            [ '250', 'a', '256 bottles of beer on the wall' ],     # original
                                                                   # "251" field has been appended
            [ '250', 'a', '251 bottles of beer on the wall' ],     # incoming
                                                                   # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],    # original
        ]
    );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Add fields from the incoming record that are in the original record'
    );

};

subtest '"Add and append" - add = 1, append = 1, remove = 0, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 1,
            'remove' => 0,
            'delete' => 0,
        }
    )->store;

    my $expected_record = build_record(
        [
            [ '250', 'a', '250 bottles of beer on the wall' ],           # original
            [ '250', 'a', '256 bottles of beer on the wall' ],           # original
                                                                         # "251" field has been appended
            [ '250', 'a', '251 bottles of beer on the wall' ],           # incoming
                                                                         # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],          # original
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Appended and added fields have been added'
    );

};

subtest 'Record fields has been only removed when add = 0, append = 0, remove = 1, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 0,
            'remove' => 1,
            'delete' => 0,
        }
    )->store;

    # Warning - not obvious as the 500 is untouched
    my $expected_record = build_record(
        [
            # "250" field has been removed
            [ '250', 'a', '256 bottles of beer on the wall' ],     # original and incoming
                                                                   # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],    # original
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields not in the incoming record are removed'
    );

};

subtest 'Record fields has been added and removed when add = 1, append = 0, remove = 1, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 0,
            'remove' => 1,
            'delete' => 0,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been removed
            [ '250', 'a', '256 bottles of beer on the wall' ],           # original and incoming
                                                                         # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],          # original
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields not in the incoming record are removed, fields not in the original record have been added'
    );

};

subtest 'Record fields has been appended and removed when add = 0, append = 1, remove = 1, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 1,
            'remove' => 1,
            'delete' => 0,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been appended and removed
            [ '250', 'a', '256 bottles of beer on the wall' ],     # incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],     # incoming
                                                                   # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],    # original
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields in the incoming record replace fields from the original record, fields only in the original record has been kept, fields not in the original record have been skipped'
    );

};

subtest 'Record fields has been added, appended and removed when add = 0, append = 1, remove = 1, delete = 0' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 1,
            'remove' => 1,
            'delete' => 0,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been appended and removed
            [ '250', 'a', '256 bottles of beer on the wall' ],           # incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],           # incoming
                                                                         # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],          # original
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields in the incoming record replace fields from the original record, fields only in the original record has been kept, fields not in the original record have been added'
    );

};

subtest 'Record fields has been deleted when add = 0, append = 0, remove = 0, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 0,
            'remove' => 0,
            'delete' => 1,
        }
    )->store();

    # FIXME the tooltip for delete is saying
    # "If the original record has fields matching the rule tag, but no fields with this are found in the incoming record"
    # But it does not seem to do that
    my $expected_record = build_record(
        [
            # "250" fields have retained their original value
            [ '250', 'a', '250 bottles of beer on the wall' ],    # original
            [ '250', 'a', '256 bottles of beer on the wall' ],    # original
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Only fields in original and incoming are kept, but incoming values are ignored'
    );

};

subtest 'Record fields has been added and deleted when add = 1, append = 0, remove = 0, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 0,
            'remove' => 0,
            'delete' => 1,
        }
    )->store();

    # Warning - is there a use case in real-life for this combinaison?
    my $expected_record = build_record(
        [
            # "250" field have retained their original value
            [ '250', 'a', '250 bottles of beer on the wall' ],           # original
            [ '250', 'a', '256 bottles of beer on the wall' ],           # original
                                                                         # "500" field has been removed
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields from the incoming records are kept, but keep the value from the original record if they already existed'
    );

};

subtest 'Record fields has been appended and deleted when add = 0, append = 1, remove = 0, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 1,
            'remove' => 0,
            'delete' => 1,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been appended
            [ '250', 'a', '250 bottles of beer on the wall' ],    # original
            [ '250', 'a', '256 bottles of beer on the wall' ],    # original and incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],    # incoming
                                                                  # "500" field has been removed
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Only fields that already existed are appended'
    );

};

subtest 'Record fields has been added, appended and deleted when add = 1, append = 1, remove = 0, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 1,
            'remove' => 0,
            'delete' => 1,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been appended
            [ '250', 'a', '250 bottles of beer on the wall' ],           # original
            [ '250', 'a', '256 bottles of beer on the wall' ],           # original and incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],           # incoming
                                                                         # "500" field has been removed
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields in the incoming record are added and appended, fields not in the original record are removed'
    );

};

subtest 'Record fields has been removed and deleted when add = 0, append = 0, remove = 1, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 0,
            'remove' => 1,
            'delete' => 1,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been removed
            [ '250', 'a', '256 bottles of beer on the wall' ],    # original and incoming
                                                                  # "500" field has been removed
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Union'
    );

};

subtest 'Record fields has been added, removed and deleted when add = 1, append = 0, remove = 1, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 0,
            'remove' => 1,
            'delete' => 1,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been appended
            [ '250', 'a', '256 bottles of beer on the wall' ],           # original and incoming
                                                                         # "500" field has been removed
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Union for existing fields, new fields are added'
    );

};

subtest 'Record fields has been appended, removed and deleted when add = 0, append = 1, remove = 1, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 0,
            'append' => 1,
            'remove' => 1,
            'delete' => 1,
        }
    )->store();

    my $expected_record = build_record(
        [
            # "250" field has been appended and removed
            [ '250', 'a', '256 bottles of beer on the wall' ],    # incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],    # incoming
                                                                  # "500" field has been removed
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields from incoming replace original record. Existing fields not in incoming are removed'
    );

};

subtest 'Record fields has been overwritten when add = 1, append = 1, remove = 1, delete = 1' => sub {
    plan tests => 1;

    $rule->set(
        {
            'add'    => 1,
            'append' => 1,
            'remove' => 1,
            'delete' => 1,
        }
    )->store();

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'Incoming record erase original record'
    );

};

subtest 'subfields order' => sub {
    plan tests => 2;

    $rule->set(
        {
            'add'    => 0,
            'append' => 0,
            'remove' => 0,
            'delete' => 0,
        }
    )->store();

    my $incoming_record = build_record(
        [
            [ '250', 'a', '256 bottles of beer on the wall' ],
            [ '250', 'a', '250 bottles of beer on the wall' ],
            [ '500', 'a', 'One bottle of beer in the fridge' ],
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $orig_record->as_formatted,
        'Original record not modified - order of subfields not modified'
    );

    $rule->set(
        {
            'add'    => 1,
            'append' => 1,
            'remove' => 1,
            'delete' => 1,
        }
    )->store();

    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'Original record modified - order of subfields has been modified'
    );

};

# Test rule tag specificity

# Protect field 500 with more specific tag value
my $skip_all_rule = Koha::MarcOverlayRules->find_or_create(
    {
        tag    => '500',
        module => 'source',
        filter => '*',
        add    => 0,
        append => 0,
        remove => 0,
        delete => 0
    }
);

subtest
    '"500" field has been protected when rule matching on tag "500" is add = 0, append = 0, remove = 0, delete = 0' =>
    sub {
    plan tests => 1;

    my $expected_record = build_record(
        [
            # "250" field has been appended
            [ '250', 'a', '256 bottles of beer on the wall' ],           # incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],           # incoming
                                                                         # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],          # original
                                                                         # "501" fields have been added
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # incoming
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # incoming
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'All fields are erased by incoming record but 500 is protected'
    );

    };

# Test regexp matching
subtest
    '"5XX" fields has been protected when rule matching on regexp "5\d{2}" is add = 0, append = 0, remove = 0, delete = 0'
    => sub {
    plan tests => 1;

    $skip_all_rule->set(
        {
            'tag' => '5\d{2}',
        }
    )->store;

    my $expected_record = build_record(
        [
            # "250" field has been appended
            [ '250', 'a', '256 bottles of beer on the wall' ],     # incoming
            [ '250', 'a', '251 bottles of beer on the wall' ],     # incoming
                                                                   # "500" field has retained its original value
            [ '500', 'a', 'One bottle of beer in the fridge' ],    # original
        ]
    );

    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Fields are erased by incoming record but 500 is protected and 501 is not added'
    );

    };

$skip_all_rule->delete();

# Test module filter specificity
subtest 'Module filter precedence tests' => sub {
    plan tests => 9;

    $rule->set(
        {
            tag    => '*',
            module => 'source',
            filter => '*',
            add    => 0,
            append => 0,
            remove => 0,
            delete => 0,
        }
    )->store();

    my $matching_filter_rule_overwrite = Koha::MarcOverlayRules->find_or_create(
        {
            tag    => '*',
            module => 'source',
            filter => 'test',
            add    => 1,
            append => 1,
            remove => 1,
            delete => 1
        }
    );

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: test, tag: *, add: 1, append: 1, remove: 1, delete: 1
    my $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'Non wildcard rule with wildcard tag matches and overrides wildcard rule with wildcard tag'
    );

    $rule->set( { tag => '5\d{2}' } )->store();

    # Current rules:
    # source: *, tag: 5\d{2}, add: 0, append: 0, remove: 0, delete: 0
    # source: test, tag: *, add: 1, append: 1, remove: 1, delete: 1
    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'Non wildcard rule with wildcard tag matches and overrides wildcard rules with regexp tags'
    );

    $rule->set( { tag => '501' } )->store();

    # Current rules:
    # source: *, tag: 501, add: 0, append: 0, remove: 0, delete: 0
    # source: test, tag: *, add: 1, append: 1, remove: 1, delete: 1
    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'Non wildcard rule with wildcard tag matches and overrides wildcard rules with specific tags'
    );

    $rule->set( { tag => '*' } )->store();

    my $wildcard_filter_rule_overwrite = Koha::MarcOverlayRules->find_or_create(
        {
            tag    => '501',
            module => 'source',
            filter => '*',
            add    => 1,
            append => 1,
            remove => 1,
            delete => 1,
        }
    );

    $matching_filter_rule_overwrite->set( { tag => '250' } )->store();

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: *, tag: 501, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 250, add: 1, append: 1, remove: 1, delete: 1
    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    my $expected_record = build_record(
        [
            [ '250', 'a', '256 bottles of beer on the wall' ],    # Unchanged
            [ '250', 'a', '251 bottles of beer on the wall' ],    # Appended
                #['250', 'a', '250 bottles of beer on the wall'], # Removed
            [ '500', 'a', 'One bottle of beer in the fridge' ],          # Protected
            [ '501', 'a', 'One cold bottle of beer in the fridge' ],     # Added
            [ '501', 'a', 'Two cold bottles of beer in the fridge' ],    # Added
        ]
    );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Rules have been merged when non wildcard filter context does not contain any wildcard tag rules'
    );

    my $matching_filter_rule_protect = Koha::MarcOverlayRules->find_or_create(
        {
            tag    => '501',
            module => 'source',
            filter => 'test',
            add    => 0,
            append => 0,
            remove => 0,
            delete => 0
        }
    );

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: *, tag: 501, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 250, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 501, add: 0, append: 0, remove: 0, delete: 0
    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    $expected_record = build_record(
        [
            [ '250', 'a', '256 bottles of beer on the wall' ],    # Unchanged
            [ '250', 'a', '251 bottles of beer on the wall' ],    # Appended
                #['250', 'a', '250 bottles of beer on the wall'], # Removed
            [ '500', 'a', 'One bottle of beer in the fridge' ],    # Protected
                #['501', 'a', 'One cold bottle of beer in the fridge'], # Protected
                #['501', 'a', 'Two cold bottles of beer in the fridge'], # Protected
        ]
    );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Wildcard filter rule has been overridden by non wildcard filter rule with same tag'
    );

    $matching_filter_rule_protect->set(
        {
            tag => '5\d{2}',
        }
    )->store();

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: *, tag: 501, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 250, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 5\d{2}, add: 0, append: 0, remove: 0, delete: 0
    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Wildcard filter rules with tags that matches tag regexps for non wildcard filter rules has been overridden'
    );

    $wildcard_filter_rule_overwrite->set(
        {
            tag => '5\d{2}',
        }
    )->store();

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: *, tag: 5\d{2}, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 250, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 5\d{2}, add: 0, append: 0, remove: 0, delete: 0
    $merged_record = Koha::MarcOverlayRules->merge_records( $orig_record, $incoming_record, { 'source' => 'test' } );

    is(
        $merged_record->as_formatted,
        $expected_record->as_formatted,
        'Wildcard filter rules with tags with tag regexps matching the same tag as regexps for non wildcard filter rules has been overridden'
    );

    my $categorycode_matching_filter_rule_protect = Koha::MarcOverlayRules->find_or_create(
        {
            tag    => '*',
            module => 'categorycode',
            filter => 'C',
            add    => 0,
            append => 0,
            remove => 0,
            delete => 0
        }
    );

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: *, tag: 5\d{2}, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 250, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 5\d{2}, add: 0, append: 0, remove: 0, delete: 0
    # categorycode: C, tag: *, add: 0, append: 0, remove: 0, delete: 0
    $merged_record = Koha::MarcOverlayRules->merge_records(
        $orig_record,
        $incoming_record,
        { 'source' => 'test', 'categorycode' => 'C' }
    );

    is(
        $merged_record->as_formatted,
        $orig_record->as_formatted,
        'If both categorycode and source module contexts matches, rules from categorycode module context are used'
    );

    my $userid_matching_filter_rule_protect = Koha::MarcOverlayRules->find_or_create(
        {
            tag    => '*',
            module => 'userid',
            filter => '123',
            add    => 1,
            append => 1,
            remove => 1,
            delete => 1
        }
    );

    # Current rules:
    # source: *, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # source: *, tag: 5\d{2}, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 250, add: 1, append: 1, remove: 1, delete: 1
    # source: test, tag: 5\d{2}, add: 0, append: 0, remove: 0, delete: 0
    # categorycode: C, tag: *, add: 0, append: 0, remove: 0, delete: 0
    # userid: 123, tag: *, add: 1, append: 1, remove: 1, delete: 1
    $merged_record = Koha::MarcOverlayRules->merge_records(
        $orig_record,
        $incoming_record,
        { 'source' => 'test', 'categorycode' => 'C', 'userid' => '123' }
    );

    is(
        $merged_record->as_formatted,
        $incoming_record->as_formatted,
        'If both userid, categorycode and source module contexts matches, rules from userid module context are used'
    );

    $categorycode_matching_filter_rule_protect->delete();
    $userid_matching_filter_rule_protect->delete();
    $wildcard_filter_rule_overwrite->delete();
    $matching_filter_rule_overwrite->delete();
    $matching_filter_rule_protect->delete();
};

subtest 'An exception is thrown when append = 1, remove = 0 is set for control field rule' => sub {
    plan tests => 2;
    my $exception = try {
        Koha::MarcOverlayRules->validate(
            {
                'tag'    => '008',
                'append' => 1,
                'remove' => 0,
            }
        );
    } catch {
        return $_;
    };
    ok( defined $exception, "Exception was caught" );
    ok(
        $exception->isa('Koha::Exceptions::MarcOverlayRule::InvalidControlFieldActions'),
        "Exception is of correct class"
    );
};

subtest 'An exception is thrown when rule tag is set to invalid regexp' => sub {
    plan tests => 2;

    my $exception = try {
        Koha::MarcOverlayRules->validate( { 'tag' => '**' } );
    } catch {
        return $_;
    };
    ok( defined $exception,                                                     "Exception was caught" );
    ok( $exception->isa('Koha::Exceptions::MarcOverlayRule::InvalidTagRegExp'), "Exception is of correct class" );
};

subtest 'context option in ModBiblio is handled correctly' => sub {
    plan tests => 2;

    $rule->set(
        {
            tag      => '250',
            module   => 'source',
            filter   => '*',
            'add'    => 0,
            'append' => 0,
            'remove' => 0,
            'delete' => 0,
        }
    )->store();

    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $orig_record, '' );

    # Since marc merc rules are not run on save, only update
    # saved record should be identical to orig_record
    my $biblio       = Koha::Biblios->find($biblionumber);
    my $saved_record = $biblio->metadata->record;

    my @all_fields = $saved_record->fields();

    # Koha also adds 999c field, therefore 4 not 3

    my $expected_record = build_record(
        [
            # "250" field has been appended
            [ '250', 'a', '250 bottles of beer on the wall' ],        # original
            [ '250', 'a', '256 bottles of beer on the wall' ],        # original
            [ '500', 'a', 'One bottle of beer in the fridge' ],       # original
            [ '999', 'c', $biblionumber, 'd', $biblioitemnumber ],    # created by AddBiblio
        ]
    );

    # Remove timestamp from saved record when comparing
    $saved_record->delete_fields( $saved_record->field('005') );

    # Make sure leader is equal after AddBiblio
    $expected_record->leader( $saved_record->leader() );

    is(
        $saved_record->as_formatted,
        $expected_record->as_formatted,
    );

    $saved_record->append_fields(
        MARC::Field->new( '250', '', '', 'a' => '251 bottles of beer on the wall' ),          # Appended
        MARC::Field->new( '500', '', '', 'a' => 'One cold bottle of beer in the fridge' ),    # Appended
    );

    ModBiblio( $saved_record, $biblionumber, '', { overlay_context => { 'source' => 'test' } } );

    my $updated_record = $biblio->get_from_storage->metadata->record;

    $expected_record = build_record(
        [
            # "250" field has been protected
            [ '250', 'a', '250 bottles of beer on the wall' ],
            [ '250', 'a', '256 bottles of beer on the wall' ],
            [ '500', 'a', 'One bottle of beer in the fridge' ],

            # "500" field has been appended
            [ '500', 'a', 'One cold bottle of beer in the fridge' ],
            [ '999', 'c', $biblionumber, 'd', $biblioitemnumber ],    # created by AddBiblio
        ]
    );

    # Remove timestamp from saved record when comparing
    $updated_record->delete_fields( $updated_record->field('005') );

    # Make sure leader is equal after ModBiblio
    $expected_record->leader( $updated_record->leader() );

    is(
        $updated_record->as_formatted,
        $expected_record->as_formatted,
    );

    # To trigger removal from search index etc
    DelBiblio($biblionumber);
};

# Explicitly delete rule to trigger clearing of cache
$rule->delete();

$schema->storage->txn_rollback;
