#!/usr/bin/perl

# Copyright 2019 BibLibre
#
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

use Test::NoWarnings;
use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;
use MARC::Record;
use Data::Dumper;

use Koha::Database;
use C4::OAI::Sets qw( AddOAISet ModOAISet ModOAISetMappings CalcOAISetsBiblio );
use Koha::Biblios;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do('DELETE FROM oai_sets');
$dbh->do('DELETE FROM oai_sets_descriptions');
$dbh->do('DELETE FROM oai_sets_mappings');
$dbh->do('DELETE FROM oai_sets_biblios');

my $builder = t::lib::TestBuilder->new;

my $set1 = {
    'spec' => 'specSet1',
    'name' => 'nameSet1',
};
my $set1_id = AddOAISet($set1);

my $marcflavour = C4::Context->preference('marcflavour');
my $mapping1;

if ( $marcflavour eq 'UNIMARC' ) {
    $mapping1 = [
        {
            rule_order   => 1,
            marcfield    => '200',
            marcsubfield => 'a',
            operator     => 'equal',
            marcvalue    => 'myTitle'
        },
        {
            rule_order    => 2,
            rule_operator => 'and',
            marcfield     => '200',
            marcsubfield  => 'f',
            operator      => 'equal',
            marcvalue     => 'myAuthor'
        },
    ];
} else {
    $mapping1 = [
        {
            rule_order   => 1,
            marcfield    => '245',
            marcsubfield => 'a',
            operator     => 'equal',
            marcvalue    => 'myTitle'
        },
        {
            rule_order    => 2,
            rule_operator => 'and',
            marcfield     => '100',
            marcsubfield  => 'a',
            operator      => 'equal',
            marcvalue     => 'myAuthor'
        },
    ];
}

#Add 1st mapping for set1
ModOAISetMappings( $set1_id, $mapping1 );

my $biblio_1 = $builder->build_sample_biblio( { title => 'myTitle' } );
my $biblio_2 = $builder->build_sample_biblio( { title => 'myTitle', author => 'myAuthor' } );

my $biblionumber1 = $biblio_1->biblionumber;
my $biblionumber2 = $biblio_2->biblionumber;

my $record = $biblio_1->metadata->record;
my @setsEq = CalcOAISetsBiblio($record);
ok( !@setsEq, 'If only one condition is true, the record does not belong to the set' );

$record = $biblio_2->metadata->record;
@setsEq = CalcOAISetsBiblio($record);
is_deeply( @setsEq, $set1_id, 'If all conditions are true, the record belongs to the set' );

if ( $marcflavour eq 'UNIMARC' ) {
    $mapping1 = [
        {
            rule_order   => 1,
            marcfield    => '200',
            marcsubfield => 'a',
            operator     => 'equal',
            marcvalue    => 'myTitle'
        },
        {
            rule_order    => 2,
            rule_operator => 'or',
            marcfield     => '200',
            marcsubfield  => 'f',
            operator      => 'equal',
            marcvalue     => 'myAuthor'
        },
        {
            rule_order    => 3,
            rule_operator => 'and',
            marcfield     => '995',
            marcsubfield  => 'r',
            operator      => 'equal',
            marcvalue     => 'myItemType'
        },

    ];
} else {
    $mapping1 = [
        {
            rule_order   => 1,
            marcfield    => '245',
            marcsubfield => 'a',
            operator     => 'equal',
            marcvalue    => 'myTitle'
        },
        {
            rule_order    => 2,
            rule_operator => 'or',
            marcfield     => '100',
            marcsubfield  => 'a',
            operator      => 'equal',
            marcvalue     => 'myAuthor'
        },
        {
            rule_order    => 3,
            rule_operator => 'and',
            marcfield     => '942',
            marcsubfield  => 'c',
            operator      => 'equal',
            marcvalue     => 'myItemType'
        },
    ];
}

ModOAISetMappings( $set1_id, $mapping1 );

$biblio_1 = $builder->build_sample_biblio( { title  => 'myTitle' } );
$biblio_2 = $builder->build_sample_biblio( { author => 'myAuthor', itemtype => 'myItemType' } );

$biblionumber1 = $biblio_1->biblionumber;
$biblionumber2 = $biblio_2->biblionumber;

$record = $biblio_1->metadata->record;
@setsEq = CalcOAISetsBiblio($record);

is_deeply(
    @setsEq, $set1_id,
    'Boolean operators precedence is respected, the record with only the title belongs to the set'
);

$record = $biblio_2->metadata->record;
@setsEq = CalcOAISetsBiblio($record);
is_deeply(
    @setsEq, $set1_id,
    'Boolean operators precedence is respected, the record with author and itemtype belongs to the set'
);

$schema->storage->txn_rollback;
