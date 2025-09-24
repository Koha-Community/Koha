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
use Test::More tests => 4;
use MARC::Record;
use MARC::Field;

BEGIN { use_ok('Koha::Util::MARC'); }

subtest 'set_marc_field' => sub {
    plan tests => 6;

    my $record = MARC::Record->new();

    Koha::Util::MARC::set_marc_field( $record, '999$9', 'foobar' );
    my @fields = $record->field('999');
    is( scalar @fields, 1, 'Created one field' );
    my @subfields = $fields[0]->subfield('9');
    is( scalar @subfields, 1,        'Created one subfield' );
    is( $subfields[0],     'foobar', 'Created subfield has correct value' );

    Koha::Util::MARC::set_marc_field( $record, '999$9', 'foobaz' );
    @fields = $record->field('999');
    is( scalar @fields, 1, 'No additional field created' );
    @subfields = $fields[0]->subfield('9');
    is( scalar @subfields, 1,        'No additional subfield created' );
    is( $subfields[0],     'foobaz', 'Subfield value has been changed' );
};

subtest 'find_marc_info, strip_orgcode, oclc_number' => sub {
    plan tests => 9;

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '003', 'some_data' ),
        MARC::Field->new( '035', '', '', a => '(test)123',  a => '(change)456' ),
        MARC::Field->new( '035', '', '', a => '(test) 567', a => '(change) 567' ),
    );
    is(
        scalar Koha::Util::MARC::find_marc_info(
            {
                record => $record, field => '003',
            }
        ),
        'some_data',
        'control field, scalar'
    );
    is(
        (
            Koha::Util::MARC::find_marc_info(
                {
                    record => $record, field => '003',
                }
            )
        )[0],
        'some_data',
        'control field, list'
    );

    is(
        scalar Koha::Util::MARC::find_marc_info(
            {
                record => $record, field => '035', subfield => 'a', match => qr/56/,
            }
        ),
        '(change)456',
        '035a, match, scalar'
    );
    my @list = Koha::Util::MARC::find_marc_info(
        {
            record => $record, field => '035', subfield => 'a', match => qr/c.*56/,
        }
    );
    is_deeply( \@list, [ '(change)456', '(change) 567' ], '035a, match, list' );

    @list = map { Koha::Util::MARC::strip_orgcode($_) } @list;
    is_deeply( \@list, [ '456', '567' ], 'strip the orgcodes' );
    @list = map { Koha::Util::MARC::strip_orgcode($_) } ( '() a', '(a)(b) c', '(abc', ' (a)b' );
    is_deeply( \@list, [ 'a', '(b) c', '(abc', ' (a)b' ], 'edge cases for strip_orgcode' );

    is( Koha::Util::MARC::oclc_number(), undef, 'No arg for oclc_number' );
    $record->append_fields(
        MARC::Field->new( '035', '', '', a => '(OCoLC) 678' ),
    );
    is( Koha::Util::MARC::oclc_number($record), '678', 'orgcode mixed case' );
    $record->insert_fields_ordered(
        MARC::Field->new( '035', '', '', a => '(ocolc) 789' ),
    );
    is( Koha::Util::MARC::oclc_number($record), '789', 'orgcode lower case' );

};
