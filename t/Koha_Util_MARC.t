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

# Note that at present this test is almost identical to the one testing
# the encapsulating method in Koha::MetadataRecord.

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
        use_ok('Koha::Util::MARC');
}

my $marcrecord = MARC::Record->new;

$marcrecord->add_fields(
        [ '001', '1234' ],
        [ '150', ' ', ' ', a => 'Cooking' ],
        [ '450', ' ', ' ', a => 'Cookery', z => 'Instructional manuals' ],
        );
my $samplehash = [
    {
        'field' => [
            {
                'value' => '1234',
                'tag'   => '001',
            }
        ]
    },
    {
        'field' => [
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
            }
        ]
    },
    {
        'field' => [
            {
                'subfield' => [
                    {
                        'value'  => 'Cookery',
                        'subtag' => 'a'
                    },
                    {
                        'value' => 'Instructional manuals',
                        'subtag' => 'z'
                    }
                ],
                'indicator2' => ' ',
                'tag'        => 450,
                'indicator1' => ' ',
            }
        ]
    }
];

my $hash = Koha::Util::MARC::createMergeHash($marcrecord);
my %fieldkeys;
foreach my $field (@$hash) {
    $fieldkeys{delete $field->{'field'}->[0]->{'key'}}++;
    if (defined $field->{'field'}->[0]->{'subfield'}) {
        foreach my $subfield (@{$field->{'field'}->[0]->{'subfield'}}) {
            $fieldkeys{delete $subfield->{'subkey'}}++;
        }
    }
}

is_deeply($hash, $samplehash, 'Generated hash correctly');
my $dupkeys = grep { $_ > 1 } values %fieldkeys;
is($dupkeys, 0, 'No duplicate keys');

is(Koha::Util::MARC::getAuthorityAuthorizedHeading($marcrecord, 'marc21'), 'Cooking', 'Routine for retrieving authorized heading works');
