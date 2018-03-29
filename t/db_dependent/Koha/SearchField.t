#!/usr/bin/perl

# Copyright 2018 Biblibre
#
# This file is part of Koha
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

use Test::More tests => 8;

use Koha::Database;
use Koha::SearchFields;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference('marcflavour', 'marc21');

my $sf = $builder->build({
    source => 'SearchField',
});

my $smm = $builder->build({
    source => 'SearchMarcMap',
    value => {
        index_name  => 'biblios',
        marc_type   => 'marc21',
        marc_field  => '410abcdef'
    }
});

my $smtf = $builder->build({
    source => 'SearchMarcToField',
    value => {
        search_marc_map_id  => $smm->{id},
        search_field_id     => $sf->{id}
    }
});

my $smm2 = $builder->build({
    source => 'SearchMarcMap',
    value => {
        index_name  => 'biblios',
        marc_type   => 'unimarc',
        marc_field  => '410abcdef'
    }
});

my $smtf2 = $builder->build({
    source => 'SearchMarcToField',
    value => {
        search_marc_map_id  => $smm2->{id},
        search_field_id     => $sf->{id}
    }
});

my $search_field = Koha::SearchFields->find($sf->{id});
my @marc_map = $search_field->search_marc_maps;
is(scalar(@marc_map), 1, 'search_marc_maps should return 1 marc map');
is($marc_map[0]->index_name, 'biblios', 'Marc map index name is biblios');
is($marc_map[0]->marc_type, 'marc21', 'Marc map type is marc21');
is($marc_map[0]->marc_field, '410abcdef', 'Marc map field is 410abcdef');

ok($search_field->is_mapped_biblios, 'Search field 1 is mapped with biblios');

my $sf2 = $builder->build({
    source => 'SearchField',
});

my $smm3 = $builder->build({
    source => 'SearchMarcMap',
    value => {
        index_name  => 'authorities',
        marc_type   => 'marc21',
        marc_field  => '700a'
    }
});

my $smtf3 = $builder->build({
    source => 'SearchMarcToField',
    value => {
        search_marc_map_id  => $smm3->{id},
        search_field_id     => $sf2->{id}
    }
});

$search_field = Koha::SearchFields->find($sf2->{id});
ok(!$search_field->is_mapped_biblios, 'Search field is mapped with authorities only');

my $smm4 = $builder->build({
    source => 'SearchMarcMap',
    value => {
        index_name  => 'biblios',
        marc_type   => 'marc21',
        marc_field  => '200a'
    }
});

my $smtf4 = $builder->build({
    source => 'SearchMarcToField',
    value => {
        search_marc_map_id  => $smm4->{id},
        search_field_id     => $sf2->{id}
    }
});

$search_field = Koha::SearchFields->find($sf2->{id});
ok($search_field->is_mapped_biblios, 'Search field is mapped with authorities and biblios');

my $sf3 = $builder->build({
    source => 'SearchField',
});

$search_field = Koha::SearchFields->find($sf3->{id});
ok(!$search_field->is_mapped_biblios, 'Search field is not mapped');

$schema->storage->txn_rollback;