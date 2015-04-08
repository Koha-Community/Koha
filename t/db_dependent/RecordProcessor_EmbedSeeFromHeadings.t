#!/usr/bin/perl

# Copyright 2012 C & P Bibliography Services
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

use strict;
use warnings;
use File::Spec;
use MARC::Record;
use Koha::Authority;

use Test::More;
use Test::MockModule;

BEGIN {
        use_ok('Koha::RecordProcessor');
}

my $module = new Test::MockModule('MARC::Record');
$module->mock('new_from_xml', sub {
    my $record = MARC::Record->new;

    $record->add_fields(
        [ '001', '1234' ],
        [ '150', ' ', ' ', a => 'Cooking' ],
        [ '450', ' ', ' ', a => 'Cookery' ],
        );

    return $record;
});

my $bib = MARC::Record->new;
$bib->add_fields(
    [ '245', '0', '4', a => 'The Ifrane cookbook' ],
    [ '650', ' ', ' ', a => 'Cooking', 9 => '1234' ]
    );

my $resultbib = MARC::Record->new;
$resultbib->add_fields(
    [ '245', '0', '4', a => 'The Ifrane cookbook' ],
    [ '650', ' ', ' ', a => 'Cooking', 9 => '1234' ],
    [ '650', 'z', ' ', a => 'Cookery' ]
    );

my $processor = Koha::RecordProcessor->new( { filters => ( 'EmbedSeeFromHeadings' ) } );
is(ref($processor), 'Koha::RecordProcessor', 'Created record processor');

my $result = $processor->process($bib);

is_deeply($result, $resultbib, 'Inserted see-from heading to record');

done_testing();
