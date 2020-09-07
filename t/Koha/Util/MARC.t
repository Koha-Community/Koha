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

use Test::More tests => 2;

BEGIN { use_ok('Koha::Util::MARC'); }

subtest 'set_marc_field' => sub {
    plan tests => 6;

    my $record = MARC::Record->new();

    Koha::Util::MARC::set_marc_field($record, '999$9', 'foobar');
    my @fields = $record->field('999');
    is(scalar @fields, 1, 'Created one field');
    my @subfields = $fields[0]->subfield('9');
    is(scalar @subfields, 1, 'Created one subfield');
    is($subfields[0], 'foobar', 'Created subfield has correct value');

    Koha::Util::MARC::set_marc_field($record, '999$9', 'foobaz');
    @fields = $record->field('999');
    is(scalar @fields, 1, 'No additional field created');
    @subfields = $fields[0]->subfield('9');
    is(scalar @subfields, 1, 'No additional subfield created');
    is($subfields[0], 'foobaz', 'Subfield value has been changed');
};
