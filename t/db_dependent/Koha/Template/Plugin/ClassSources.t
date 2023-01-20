#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;

use t::lib::Mocks;

BEGIN {
    use_ok('Koha::Template::Plugin::ClassSources');
}

my $schema  = Koha::Database->schema;

subtest 'all' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;
    $schema->resultset('ClassSource')->delete();
    $schema->resultset('ClassSource')->create({
        cn_source => 'anscr',
        description => 'ANSCR (Sound Recordings)',
        used => 0,
        class_sort_rule => 'generic',
        class_split_rule => 'generic',
    });
    $schema->resultset('ClassSource')->create({
        cn_source => 'ddc',
        description => 'Dewey Decimal Classification',
        used => 1,
        class_sort_rule => 'dewey',
        class_split_rule => 'dewey',
    });
    $schema->resultset('ClassSource')->create({
        cn_source => 'z',
        description => 'Other/Generic Classification Scheme',
        used => 0,
        class_sort_rule => 'generic',
        class_split_rule => 'generic',
    });

    t::lib::Mocks::mock_preference('DefaultClassificationSource', '');

    my $plugin = Koha::Template::Plugin::ClassSources->new();
    subtest 'when given no parameters' => sub {
        plan tests => 2;
        my @class_sources = $plugin->all();

        is(scalar @class_sources, 1, 'it returns only "used" class sources');
        is($class_sources[0]->used, 1, 'it returns only "used" class sources');
    };

    subtest 'when given parameter "selected"' => sub {
        plan tests => 1;
        my @class_sources = $plugin->all({ selected => 'anscr' });

        ok(scalar @class_sources == 2, 'it returns "used" class sources and the selected one');
    };

    subtest 'when DefaultClassificationSource is set to a not used class source' => sub {
        plan tests => 1;
        t::lib::Mocks::mock_preference('DefaultClassificationSource', 'anscr');
        my @class_sources = $plugin->all();

        ok(scalar @class_sources == 2, 'it returns "used" class sources and the default one');
    };

    subtest 'when DefaultClassificationSource is set and "selected" parameter is given' => sub {
        plan tests => 1;
        t::lib::Mocks::mock_preference('DefaultClassificationSource', 'anscr');
        my @class_sources = $plugin->all({ selected => 'z' });
        ok(scalar @class_sources == 3, 'it returns "used" class sources, the default one and the selected one');
    };

    $schema->storage->txn_rollback;
};
