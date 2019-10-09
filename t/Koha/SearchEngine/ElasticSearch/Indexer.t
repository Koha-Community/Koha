#!/usr/bin/perl
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

use Test::More tests => 1;
use Test::Exception;

use t::lib::Mocks;

use Test::MockModule;

use MARC::Record;
use Try::Tiny;

use Koha::SearchEngine::Elasticsearch;
use Koha::SearchEngine::Elasticsearch::Indexer;

subtest '_sanitise_records() tests' => sub {
    plan tests => 5;

    my $indexer;
    ok(
        $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new indexer object'
    );

    my $record1 = MARC::Record->new();
    $record1->append_fields(
        MARC::Field->new('999', '', '', 'c' => 1, 'd' => 2)
    );

    my $record2 = MARC::Record->new();
    $record2->append_fields(
        MARC::Field->new('999', '', '', 'c' => 3, 'd' => 4)
    );
    my $records = [$record1, $record2];

    my $biblionumbers = [5, 6];

    $indexer->_sanitise_records($biblionumbers, $records);

    is(
        $record1->subfield('999', 'c'),
        '5',
        'First record has 5 in 999c'
    );
    is(
        $record1->subfield('999', 'd'),
        '5',
        'First record has 5 in 999d'
    );

    is(
        $record2->subfield('999', 'c'),
        '6',
        'Second record has 6 in 999c'
    );
    is(
        $record2->subfield('999', 'd'),
        '6',
        'Second record has 6 in 999d'
    );
};