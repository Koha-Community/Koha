#!/usr/bin/perl

# Copyright 2024 BibLibre
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
use Test::More tests => 9;
use Test::Exception;

use t::lib::TestBuilder;
use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;
use HTTP::OAI::Record;
use HTTP::OAI::Encapsulation;
use Koha::Database;
use Koha::OaiServer;
use Koha::OaiServers;
use Koha::OAI::Client::Harvester;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $new_oai_1 = Koha::OaiServer->new(
    {
        endpoint   => 'my_host1.org',
        oai_set    => 'set1',
        servername => 'my_test_1',
        dataformat => 'oai_dc',
        recordtype => 'biblio',
        add_xslt   => '',
    }
)->store;

my $harvester = Koha::OAI::Client::Harvester->new( { server => $new_oai_1, verbose => 1, days => 1, force => 1 } );

my $record =
    '<metadata xmlns="http://www.openarchives.org/OAI/2.0/"><oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"><dc:title>Pièces diverses </dc:title><dc:identifier>ARCH/0320 [cote]</dc:identifier><dc:relation>FR-920509801 [RCR établissement]</dc:relation><dc:relation>Central obrera boliviana [Fonds ou collection]</dc:relation><dc:format>1 carton</dc:format><dc:date>1971/2000</dc:date><dc:type>Archives et manuscrits</dc:type></oai_dc:dc></metadata>';

my $r = HTTP::OAI::Record->new();
$r->metadata( HTTP::OAI::Metadata->new( dom => $record ) );

my $status = $harvester->processRecord($r);
is( $status, 'skipped', 'Record with no identifier is skipped' );

$r->header->identifier('oai:myarchive.org:oid-233');
$status = $harvester->processRecord($r);
is( $status, 'added', 'Record with no date is added' );

$status = $harvester->processRecord($r);
is( $status, 'updated', 'Record with no date is updated' );

$status = $harvester->processRecord($r);
is( $status, 'updated', 'Record with no date is updated even without force' );

$r->header->identifier('oai:myarchive.org:oid-234');
$r->header->datestamp('2017-05-10T09:18:13Z');

$status = $harvester->processRecord($r);
is( $status, 'added', 'Record is added' );

$status = $harvester->processRecord($r);
is( $status, 'updated', 'When force is used, record is updated' );

$harvester = Koha::OAI::Client::Harvester->new( { server => $new_oai_1, verbose => 1, days => 1, force => 0 } );
$status    = $harvester->processRecord($r);
is( $status, 'skipped', 'When force is not used, record is skipped (already up to date)' );

$r->header->datestamp('2018-05-10T09:18:13Z');
$status = $harvester->processRecord($r);
is( $status, 'updated', 'When force is not used, record is updated if newer' );

my $imported_record = Koha::Import::Oaipmh::Biblios->find( { identifier => 'oai:myarchive.org:oid-234' } );
my $added_datestamp = $imported_record->datestamp;
$r->header->datestamp(undef);
$status          = $harvester->processRecord($r);
$imported_record = Koha::Import::Oaipmh::Biblios->find( { identifier => 'oai:myarchive.org:oid-234' } );
my $updated_datestamp = $imported_record->datestamp;
isnt(
    $added_datestamp, $updated_datestamp,
    'local datestamp is updated even if there is no datestamp in incoming record'
);

$schema->storage->txn_rollback;
