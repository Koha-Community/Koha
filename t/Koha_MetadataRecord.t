#!/usr/bin/perl

# Copyright 2013 C & P Bibliography Services
#
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
use Test::Warn;

use MARC::Record;

BEGIN {
    use_ok('Koha::MetadataRecord');
}

my $marcrecord = MARC::Record->new;

$marcrecord->add_fields(
        [ '001', '1234' ],
        [ '150', ' ', ' ', a => 'Cooking' ],
        [ '450', ' ', ' ', a => 'Cookery', z => 'Instructional manuals' ],
        );
my $record = Koha::MetadataRecord->new({ 'record' => $marcrecord, 'schema' => 'marc21' });

is(ref($record), 'Koha::MetadataRecord', 'Created valid Koha::MetadataRecord object');

my $samplehash = [
    {
        'value' => '1234',
        'tag'   => '001',
    },
    {
        'subfield' => [
            {
                'value'  => 'Cooking',
                'subtag' => 'a'
            }
        ],
        'indicator2' => ' ',
        'tag'        => 150,
        'indicator1' => ' ',
    },
    {
        'subfield' => [
            {
                'value'  => 'Cookery',
                'subtag' => 'a'
            },
            {
                'value'  => 'Instructional manuals',
                'subtag' => 'z'
            }
        ],
        'indicator2' => ' ',
        'tag'        => 450,
        'indicator1' => ' ',
    }
];

my $hash = $record->createMergeHash();
my %fieldkeys;
foreach my $field (@$hash) {
    $fieldkeys{delete $field->{'key'}}++;
    if (defined $field->{'subfield'}) {
        foreach my $subfield (@{$field->{'subfield'}}) {
            $fieldkeys{delete $subfield->{'subkey'}}++;
        }
    }
}

is_deeply($hash, $samplehash, 'Generated hash correctly');
my $dupkeys = grep { $_ > 1 } values %fieldkeys;
is($dupkeys, 0, 'No duplicate keys');


subtest "new() tests" => sub {

    plan tests => 14;

    # Test default values with a MARC::Record record
    my $record = MARC::Record->new();
    my $metadata_record;

    warning_is { $metadata_record = Koha::MetadataRecord->new({
                        record => $record }) }
               { carped => 'No schema passed' },
        "Metadata schema is mandatory, raise a carped warning if omitted";
    is( $metadata_record, undef, "Metadata schema is mandatory, return undef if omitted");

    $metadata_record = Koha::MetadataRecord->new({
        record => $record,
        schema => 'marc21'
    });

    is( ref($metadata_record), 'Koha::MetadataRecord', 'Type correct');
    is( ref($metadata_record->record), 'MARC::Record', 'Record type preserved');
    is( $metadata_record->schema, 'marc21', 'Metadata schema is set to marc21');
    is( $metadata_record->format, 'MARC', 'Serializacion format defaults to marc');
    is( $metadata_record->id, undef, 'id is optional, undef if unspecifid');

    # Test passed values, also no constraint on record type
    my $weird_record = {};
    bless $weird_record, 'Weird::Class';

    $metadata_record = Koha::MetadataRecord->new({
        record => $weird_record,
        schema => 'something',
        format => 'else',
        id     => 'an id'
    });

    is( ref($metadata_record), 'Koha::MetadataRecord', 'Type correct');
    is( ref($metadata_record->record), 'Weird::Class', 'Record type preserved');
    is( $metadata_record->schema, 'something', 'Metadata schema correctly set');
    is( $metadata_record->format, 'else', 'Serializacion format correctly set');
    is( $metadata_record->id, 'an id', 'The id correctly set');

    # Having a record object is mandatory
    warning_is { $metadata_record = Koha::MetadataRecord->new({
                                        record => undef,
                                        schema => 'something',
                                        format => 'else',
                                        id     => 'an id'
                                    }) }
                { carped => 'No record passed' },
                'Undefined record raises carped warning';

    is( $metadata_record, undef, 'record object mandatory')
};

subtest "stripWhitespaceChars() tests" => sub {
    plan tests => 2;

    # Test default values with a MARC::Record record
    my $record = MARC::Record->new();

    $record->add_fields(
        [ '001', '1234' ],
        [ '150', ' ', ' ', a => 'Test' ],
        [ '520', ' ', ' ', a => "This is\na test!\t" ],
        [ '521', ' ', ' ', a => "This is a\t test!\t" ],
    );

    $record = Koha::MetadataRecord::stripWhitespaceChars( $record );

    my $get520a = $record->subfield('520','a');
    is( $get520a, "This is a test!", "Whitespace characters are appropriately stripped or replaced with spaces" );

    my $get521a = $record->subfield('521','a');
    is( $get521a, "This is a\t test!", "Trailing tabs are stripped while inner tabs are kept" );
};
