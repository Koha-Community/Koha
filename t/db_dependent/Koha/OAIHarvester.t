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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 29;
use Test::Exception;
use File::Temp   qw/tempfile/;
use Scalar::Util qw//;

use t::lib::TestBuilder;
use t::lib::Mocks;

use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;
use HTTP::OAI::Record;
use HTTP::OAI::Encapsulation;
use Koha::Database;
use Koha::OAIServer;
use Koha::OAIServers;
use Koha::OAI::Client::Harvester;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $new_oai_biblio = Koha::OAIServer->new(
    {
        endpoint   => ( $ENV{KOHA_OPAC_URL} || C4::Context->preference('OPACBaseURL') ) . '/cgi-bin/koha/oai.pl',
        oai_set    => '',
        servername => 'my_test_1',
        dataformat => 'oai_dc',
        recordtype => 'biblio',
        add_xslt   => '',
    }
)->store;

C4::Context->set_preference( 'OAI-PMH', 1 );
t::lib::Mocks::mock_preference(
    'OAI-PMH:HarvestEmailReport',
    C4::Context->preference('KohaAdminEmailAddress')
);

my $harvester = Koha::OAI::Client::Harvester->new( { server => $new_oai_biblio, verbose => 1, days => 1, force => 1 } );

my $init_results = $harvester->init();

like(
    $init_results->{metadata_formats},
    qr/oai_dc marc21 marcxml/,
    'Got list of supported metadata formats'
);
is( $init_results->{is_error}, undef, 'ListRecords request worked' );
ok( Scalar::Util::looks_like_number( $init_results->{total} ), 'Total records fetched' );
isnt( $init_results->{letter_message_id}, undef, 'Report has been enqueued' );

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

$harvester = Koha::OAI::Client::Harvester->new( { server => $new_oai_biblio, verbose => 1, days => 1, force => 0 } );
$status    = $harvester->processRecord($r);
is(
    $status, 'skipped',
    'When force is not used, record is skipped (already up to date)'
);

$r->header->datestamp('2018-05-10T09:18:13Z');
$status = $harvester->processRecord($r);
is( $status, 'updated', 'When force is not used, record is updated if newer' );

my $imported_record = Koha::Import::OAI::Biblios->find( { identifier => 'oai:myarchive.org:oid-234' } );
my $added_datestamp = '2017-05-10T09:18:13Z';
$imported_record->update(
    {
        datestamp => $added_datestamp,
    }
);

$r->header->datestamp(undef);
$status          = $harvester->processRecord($r);
$imported_record = Koha::Import::OAI::Biblios->find( { identifier => 'oai:myarchive.org:oid-234' } );
my $updated_datestamp = $imported_record->datestamp;
isnt(
    $added_datestamp, $updated_datestamp,
    'local datestamp is updated even if there is no datestamp in incoming record'
);

$r->header->status('deleted');
$status = $harvester->processRecord($r);
is(
    $status, 'deleted',
    'When a record is marked to be deleted, status is deleted'
);

$imported_record = Koha::Import::OAI::Biblios->find( { identifier => 'oai:myarchive.org:oid-234' } );
is( $imported_record, undef, 'Record has been deleted' );

$status = $harvester->processRecord($r);
is( $status, 'skipped', 'Status is skipped for already deleted record' );

# Authorities
my $file         = xsl_file();
my $new_oai_auth = Koha::OAIServer->new(
    {
        endpoint   => 'my_host1.org',
        oai_set    => 'set1',
        servername => 'my_test_1',
        dataformat => 'oai_dc',
        recordtype => 'authority',
        add_xslt   => $file,
    }
)->store;

$harvester = Koha::OAI::Client::Harvester->new( { server => $new_oai_auth, verbose => 1, days => 1, force => 1 } );

my $auth =
    '<metadata xmlns="http://www.openarchives.org/OAI/2.0/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:dc="http://purl.org/dc/elements/1.1/" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd"><dc:FamilyName>Emerson</dc:FamilyName><dc:GivenName>Everett H.</dc:GivenName></oai_dc:dc></metadata>';

$r = HTTP::OAI::Record->new();
$r->metadata( HTTP::OAI::Metadata->new( dom => $auth ) );

$status = $harvester->processRecord($r);
is( $status, 'skipped', 'Authority with no identifier is skipped' );

$r->header->identifier('oai:myarchive.org:oid-161');
$status = $harvester->processRecord($r);
is( $status, 'added', 'Authority with no date is added' );

$status = $harvester->processRecord($r);
is( $status, 'updated', 'Authority with no date is updated' );

$status = $harvester->processRecord($r);
is(
    $status, 'updated',
    'Authority with no date is updated even without force'
);

$r->header->identifier('oai:myarchive.org:oid-162');
$r->header->datestamp('2017-05-10T09:18:13Z');

$status = $harvester->processRecord($r);
is( $status, 'added', 'Authority is added' );

$status = $harvester->processRecord($r);
is( $status, 'updated', 'When force is used, authority is updated' );

$harvester = Koha::OAI::Client::Harvester->new( { server => $new_oai_auth, verbose => 1, days => 1, force => 0 } );
$status    = $harvester->processRecord($r);
is(
    $status, 'skipped',
    'When force is not used, authority is skipped (already up to date)'
);

$r->header->datestamp('2018-05-10T09:18:13Z');
$status = $harvester->processRecord($r);
is(
    $status, 'updated',
    'When force is not used, authority is updated if newer'
);

my $imported_authority = Koha::Import::OAI::Authorities->find( { identifier => 'oai:myarchive.org:oid-162' } );
$imported_authority->update(
    {
        datestamp => $added_datestamp,
    }
);

$r->header->datestamp(undef);

$status             = $harvester->processRecord($r);
$imported_authority = Koha::Import::OAI::Authorities->find( { identifier => 'oai:myarchive.org:oid-162' } );
$updated_datestamp  = $imported_authority->datestamp;
isnt(
    $added_datestamp, $updated_datestamp,
    'local datestamp is updated even if there is no datestamp in incoming authority'
);

$r->header->status('deleted');
$status = $harvester->processRecord($r);
is(
    $status, 'deleted',
    'When an authority is marked to be deleted, status is deleted'
);

$imported_record = Koha::Import::OAI::Biblios->find( { identifier => 'oai:myarchive.org:oid-162' } );
is( $imported_record, undef, 'Authority has been deleted' );

$status = $harvester->processRecord($r);
is( $status, 'skipped', 'Status is skipped for already deleted authority' );

$schema->storage->txn_rollback;

sub xsl_file {
    return mytempfile(
        q{<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/1.1"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/
        http://www.openarchives.org/OAI/2.0/oai_dc.xsd"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.loc.gov/MARC21/slim"  exclude-result-prefixes="dc dcterms oai_dc">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <collection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd" >
            <xsl:apply-templates />
        </collection>
    </xsl:template>

    <xsl:template match="oai_dc:dc">
        <record>

            <xsl:variable name="FamilyName" select="dc:FamilyName"/>
            <xsl:variable name="GivenName" select="dc:GivenName"/>

            <datafield tag="100" ind1="0" ind2=" ">
                <subfield code="a">
                    <xsl:value-of select="concat($FamilyName,', ',$GivenName)"/>
                </subfield>
            </datafield>

        </record>
   </xsl:template>

</xsl:stylesheet>
            }
    );
}

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.xsl', UNLINK => 1 );
    print $fh $_[0] // '';
    close $fh;
    return $fn;
}
