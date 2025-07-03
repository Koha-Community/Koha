#!/usr/bin/perl

# Copyright Tamil s.a.r.l. 2016
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::Deep     qw( cmp_deeply re );
use Test::MockTime qw/set_fixed_time set_relative_time restore_time/;

use Test::NoWarnings;
use Test::More tests => 36;
use DateTime;
use File::Basename;
use File::Spec;
use Test::MockModule;
use Test::Warn;
use XML::Simple;
use YAML::XS;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio qw( AddBiblio ModBiblio DelBiblio );
use C4::Context;
use C4::OAI::Sets qw(AddOAISet);

use Koha::Biblios;
use Koha::Biblio::Metadatas;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

BEGIN {
    use_ok('Koha::OAI::Server::DeletedRecord');
    use_ok('Koha::OAI::Server::Description');
    use_ok('Koha::OAI::Server::GetRecord');
    use_ok('Koha::OAI::Server::Identify');
    use_ok('Koha::OAI::Server::ListBase');
    use_ok('Koha::OAI::Server::ListIdentifiers');
    use_ok('Koha::OAI::Server::ListMetadataFormats');
    use_ok('Koha::OAI::Server::ListRecords');
    use_ok('Koha::OAI::Server::ListSets');
    use_ok('Koha::OAI::Server::Record');
    use_ok('Koha::OAI::Server::Repository');
    use_ok('Koha::OAI::Server::ResumptionToken');
}

use constant NUMBER_OF_MARC_RECORDS => 10;

# Mocked CGI module in order to be able to send CGI parameters to OAI Server
my %param;
my $module = Test::MockModule->new('CGI');
$module->mock( 'Vars', sub { %param; } );

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do("SET time_zone='+00:00'");
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM biblio');
$dbh->do('DELETE FROM deletedbiblio');
$dbh->do('DELETE FROM deletedbiblioitems');
$dbh->do('DELETE FROM deleteditems');
$dbh->do('DELETE FROM oai_sets');

set_fixed_time( CORE::time() );

my $base_datetime = dt_from_string( undef, undef, 'UTC' );
my $date_added    = $base_datetime->ymd . ' ' . $base_datetime->hms . 'Z';
my $date_to       = substr( $date_added, 0, 10 ) . 'T23:59:59Z';
my ( @header, @marcxml, @oaidc, @marcxml_transformed );
my $sth      = $dbh->prepare('UPDATE biblioitems     SET timestamp=? WHERE biblionumber=?');
my $sth2     = $dbh->prepare('UPDATE biblio_metadata SET timestamp=? WHERE biblionumber=?');
my $first_bn = 0;

# Add biblio records
foreach my $index ( 0 .. NUMBER_OF_MARC_RECORDS - 1 ) {
    my $record = MARC::Record->new();
    if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        $record->append_fields( MARC::Field->new( '101', '', '', 'a' => "lng" ) );
        $record->append_fields( MARC::Field->new( '200', '', '', 'a' => "Title $index" ) );
        $record->append_fields( MARC::Field->new( '952', '', '', 'a' => "Code" ) );
    } else {
        $record->append_fields( MARC::Field->new( '008', '                                   lng' ) );
        $record->append_fields( MARC::Field->new( '245', '', '', 'a' => "Title $index" ) );
        $record->append_fields( MARC::Field->new( '952', '', '', 'a' => "Code" ) );
    }
    my ($biblionumber) = AddBiblio( $record, '' );
    $first_bn = $biblionumber unless $first_bn;
    my $timestamp = $base_datetime->ymd . ' ' . $base_datetime->hms;
    $sth->execute( $timestamp, $biblionumber );
    $sth2->execute( $timestamp, $biblionumber );
    $timestamp .= 'Z';
    $timestamp =~ s/ /T/;
    my $biblio = Koha::Biblios->find($biblionumber);
    $record = $biblio->metadata_record;
    my $record_transformed = $record->clone;
    $record_transformed->delete_fields( $record_transformed->field('952') );
    $record_transformed = XMLin( $record_transformed->as_xml_record );
    $record             = XMLin( $record->as_xml_record );
    push @header, { datestamp => $timestamp, identifier => "TEST:$biblionumber" };
    my $dc = {
        'dc:title'           => "Title $index",
        'dc:language'        => "lng",
        'dc:type'            => {},
        'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:oai_dc'       => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
        'xmlns:dc'           => 'http://purl.org/dc/elements/1.1/',
        'xsi:schemaLocation' =>
            'http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
    };
    if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        $dc->{'dc:identifier'} = $biblionumber;
    }
    push @oaidc, {
        header   => $header[$index],
        metadata => {
            'oai_dc:dc' => $dc,
        },
    };
    push @marcxml, {
        header   => $header[$index],
        metadata => {
            record => $record,
        },
    };

    push @marcxml_transformed, {
        header   => $header[$index],
        metadata => {
            record => $record_transformed,
        },
    };
}

my $syspref = {
    'LibraryName'           => 'My Library',
    'OAI::PMH'              => 1,
    'OAI-PMH:archiveID'     => 'TEST',
    'OAI-PMH:ConfFile'      => '',
    'OAI-PMH:MaxCount'      => 3,
    'OAI-PMH:DeletedRecord' => 'persistent',
};
while ( my ( $name, $value ) = each %$syspref ) {
    t::lib::Mocks::mock_preference( $name => $value );
}

sub test_query {
    my ( $test, $param, $expected ) = @_;

    %param = %$param;
    my %full_expected = (
        %$expected,
        (
            request              => 'http://localhost',
            xmlns                => 'http://www.openarchives.org/OAI/2.0/',
            'xmlns:xsi'          => 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:schemaLocation' =>
                'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd',
        )
    );

    my $response;
    {
        my $stdout;
        local *STDOUT;
        open STDOUT, '>', \$stdout;
        Koha::OAI::Server::Repository->new();
        $response = XMLin($stdout);
    }

    delete $response->{responseDate};
    unless ( cmp_deeply( $response, \%full_expected, $test ) ) {
        diag "PARAM:"
            . YAML::XS::Dump($param)
            . "EXPECTED:"
            . YAML::XS::Dump( \%full_expected )
            . "RESPONSE:"
            . YAML::XS::Dump($response);
    }
}

test_query(
    'ListMetadataFormats',
    { verb => 'ListMetadataFormats' },
    {
        ListMetadataFormats => {
            metadataFormat => [
                {
                    metadataNamespace => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                    metadataPrefix    => 'oai_dc',
                    schema            => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
                },
                {
                    metadataNamespace =>
                        'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim',
                    metadataPrefix => 'marc21',
                    schema         => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
                },
                {
                    metadataNamespace =>
                        'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim',
                    metadataPrefix => 'marcxml',
                    schema         => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
                },
            ],
        },
    }
);

test_query(
    'ListIdentifiers without metadataPrefix',
    { verb => 'ListIdentifiers' },
    {
        error => {
            code    => 'badArgument',
            content => "Required argument 'metadataPrefix' was undefined",
        },
    }
);

test_query(
    'ListIdentifiers',
    { verb => 'ListIdentifiers', metadataPrefix => 'marcxml' },
    {
        ListIdentifiers => {
            header          => [ @header[ 0 .. 2 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/3////0/0/\d+$}),
                cursor  => 3,
            },
        },
    }
);

test_query(
    'ListIdentifiers',
    { verb => 'ListIdentifiers', metadataPrefix => 'marcxml' },
    {
        ListIdentifiers => {
            header          => [ @header[ 0 .. 2 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/3////0/0/\d+$}),
                cursor  => 3,
            },
        },
    }
);

test_query(
    'ListIdentifiers with resumptionToken 1',
    {
        verb            => 'ListIdentifiers',
        resumptionToken => "marcxml/3/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 3 )
    },
    {
        ListIdentifiers => {
            header          => [ @header[ 3 .. 5 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0/\d+$}),
                cursor  => 6,
            },
        },
    },
);

test_query(
    'ListIdentifiers with resumptionToken 2',
    {
        verb            => 'ListIdentifiers',
        resumptionToken => "marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 6 )
    },
    {
        ListIdentifiers => {
            header          => [ @header[ 6 .. 8 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0/\d+$}),
                cursor  => 9,
            },
        },
    },
);

test_query(
    'ListIdentifiers with resumptionToken 3, response without resumption',
    {
        verb            => 'ListIdentifiers',
        resumptionToken => "marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 9 )
    },
    {
        ListIdentifiers => {
            header => $header[9],
        },
    },
);

test_query(
    'ListRecords marcxml without metadataPrefix',
    { verb => 'ListRecords' },
    {
        error => {
            code    => 'badArgument',
            content => "Required argument 'metadataPrefix' was undefined",
        },
    }
);

test_query(
    'ListRecords marcxml',
    { verb => 'ListRecords', metadataPrefix => 'marcxml' },
    {
        ListRecords => {
            record          => [ @marcxml[ 0 .. 2 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/3////0/0/\d+$}),
                cursor  => 3,
            },
        },
    }
);

test_query(
    'ListRecords marcxml with resumptionToken 1',
    { verb => 'ListRecords', resumptionToken => "marcxml/3////0/0/" . ( $first_bn + 3 ) },
    {
        ListRecords => {
            record          => [ @marcxml[ 3 .. 5 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/6////0/0/\d+$}),
                cursor  => 6,
            },
        },
    }
);

test_query(
    'ListRecords marcxml with resumptionToken 2',
    { verb => 'ListRecords', resumptionToken => "marcxml/6/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 6 ) },
    {
        ListRecords => {
            record          => [ @marcxml[ 6 .. 8 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0/\d+$}),
                cursor  => 9,
            },
        },
    }
);

# Last record, so no resumption token
test_query(
    'ListRecords marcxml with resumptionToken 3, response without resumption',
    { verb => 'ListRecords', resumptionToken => "marcxml/9/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 9 ) },
    {
        ListRecords => {
            record => $marcxml[9],
        },
    }
);

test_query(
    'ListRecords oai_dc',
    { verb => 'ListRecords', metadataPrefix => 'oai_dc' },
    {
        ListRecords => {
            record          => [ @oaidc[ 0 .. 2 ] ],
            resumptionToken => {
                content => re(qr{^oai_dc/3////0/0/\d+$}),
                cursor  => 3,
            },
        },
    }
);

test_query(
    'ListRecords oai_dc with resumptionToken 1',
    { verb => 'ListRecords', resumptionToken => "oai_dc/3////0/0/" . ( $first_bn + 3 ) },
    {
        ListRecords => {
            record          => [ @oaidc[ 3 .. 5 ] ],
            resumptionToken => {
                content => re(qr{^oai_dc/6////0/0/\d+$}),
                cursor  => 6,
            },
        },
    }
);

test_query(
    'ListRecords oai_dc with resumptionToken 2',
    { verb => 'ListRecords', resumptionToken => "oai_dc/6/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 6 ) },
    {
        ListRecords => {
            record          => [ @oaidc[ 6 .. 8 ] ],
            resumptionToken => {
                content => re(qr{^oai_dc/9/1970-01-01T00:00:00Z/$date_to//0/0/\d+$}),
                cursor  => 9,
            },
        },
    }
);

# Last record, so no resumption token
test_query(
    'ListRecords oai_dc with resumptionToken 3, response without resumption',
    { verb => 'ListRecords', resumptionToken => "oai_dc/9/1970-01-01T00:00:00Z/$date_to//0/0/" . ( $first_bn + 9 ) },
    {
        ListRecords => {
            record => $oaidc[9],
        },
    }
);

#  List records, but now transformed by XSLT
t::lib::Mocks::mock_preference( "OAI-PMH:ConfFile" => File::Spec->rel2abs( dirname(__FILE__) ) . "/oaiconf.yaml" );
test_query(
    'ListRecords marcxml with xsl transformation',
    { verb => 'ListRecords', metadataPrefix => 'marcxml' },
    {
        ListRecords => {
            record          => [ @marcxml_transformed[ 0 .. 2 ] ],
            resumptionToken => {
                content => re(qr{^marcxml/3////0/0/\d+$}),
                cursor  => 3,
            }
        },
    }
);
t::lib::Mocks::mock_preference( "OAI-PMH:ConfFile" => '' );

restore_time();

subtest 'Bug 19725: OAI-PMH ListRecords and ListIdentifiers should use biblio_metadata.timestamp' => sub {
    plan tests => 1;

    # Wait 1 second to be sure no timestamp will be equal to $from defined below
    sleep 1;

    # Modify record to trigger auto update of timestamp
    ( my $biblionumber = $marcxml[0]->{header}->{identifier} ) =~ s/^.*:(.*)/$1/;
    my $biblio = Koha::Biblios->find($biblionumber);
    my $record = $biblio->metadata_record;
    $record->append_fields( MARC::Field->new( 999, '', '', z => '_' ) );
    ModBiblio( $record, $biblionumber );
    my $from_dt = dt_from_string(
        Koha::Biblio::Metadatas->find( { biblionumber => $biblionumber, format => 'marcxml', schema => 'MARC21' } )
            ->timestamp );
    my $from = $from_dt->ymd . 'T' . $from_dt->hms . 'Z';
    $oaidc[0]->{header}->{datestamp} = $from;

    test_query(
        'ListRecords oai_dc with parameter from',
        { verb => 'ListRecords', metadataPrefix => 'oai_dc', from => $from },
        {
            ListRecords => {
                record => $oaidc[0],
            },
        }
    );
};

subtest 'Bug 20665: OAI-PMH Provider should reset the MySQL connection time zone' => sub {
    plan tests => 2;

    # Set time zone to SYSTEM so that it can be checked later
    $dbh->do("SET time_zone='SYSTEM'");

    test_query(
        'ListIdentifiers without metadataPrefix',
        { verb => 'ListIdentifiers' },
        {
            error => {
                code    => 'badArgument',
                content => "Required argument 'metadataPrefix' was undefined",
            },
        }
    );

    my $sth = C4::Context->dbh->prepare('SELECT @@session.time_zone');
    $sth->execute();
    my ($tz) = $sth->fetchrow();

    ok( $tz eq 'SYSTEM', 'MySQL connection time zone is SYSTEM' );
};

$schema->storage->txn_rollback;

subtest 'ListSets tests' => sub {

    plan tests => 3;

    t::lib::Mocks::mock_preference( 'OAI::PMH'         => 1 );
    t::lib::Mocks::mock_preference( 'OAI-PMH:MaxCount' => 3 );

    $schema->storage->txn_begin;

    $dbh->do('DELETE FROM oai_sets');

    # Add a bunch of sets
    my @first_page_sets = ();
    for my $i ( 1 .. 3 ) {

        AddOAISet(
            {
                'spec' => "setSpec_$i",
                'name' => "setName_$i",
            }
        );
        push @first_page_sets, { setSpec => "setSpec_$i", setName => "setName_$i" };
    }

    # Add more to force pagination
    my @second_page_sets = ();
    for my $i ( 4 .. 6 ) {

        AddOAISet(
            {
                'spec' => "setSpec_$i",
                'name' => "setName_$i",
            }
        );
        push @second_page_sets, { setSpec => "setSpec_$i", setName => "setName_$i" };
    }

    AddOAISet(
        {
            'spec' => "setSpec_7",
            'name' => "setName_7",
        }
    );

    test_query(
        'ListSets',
        { verb => 'ListSets' },
        {
            ListSets => {
                resumptionToken => {
                    content => re(qr{^/3////1/0/4$}),
                    cursor  => 3,
                },
                set => \@first_page_sets
            }
        }
    );

    test_query(
        'ListSets',
        { verb => 'ListSets', resumptionToken => '/3////1/0/4' },
        {
            ListSets => {
                resumptionToken => {
                    content => re(qr{^/6////1/0/7$}),
                    cursor  => 6,
                },
                set => \@second_page_sets
            }
        }
    );

    test_query(
        'ListSets',
        { verb     => 'ListSets', resumptionToken => "/6////1/0/7" },
        { ListSets => { set => { setSpec => "setSpec_7", setName => "setName_7" } } }
    );

    $schema->storage->txn_rollback;
};

subtest 'Tests for OpacHiddenItems' => sub {

    plan tests => 4;

    t::lib::Mocks::mock_preference( 'OAI::PMH'         => 1 );
    t::lib::Mocks::mock_preference( 'OAI-PMH:MaxCount' => 3 );
    t::lib::Mocks::mock_preference(
        'OAI-PMH:ConfFile' => File::Spec->rel2abs( dirname(__FILE__) ) . '/oaiconf_items.yaml' );
    $schema->storage->txn_begin;
    my $builder       = t::lib::TestBuilder->new;
    my $item          = $builder->build_sample_item();
    my $biblio        = $item->biblio;
    my $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    my $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';

    my $get_items = {
        verb           => 'GetRecord',
        metadataPrefix => 'marc21',
        identifier     => 'TEST:' . $item->biblionumber
    };
    my $list_items = {
        verb           => 'ListRecords',
        metadataPrefix => 'marc21',
        from           => $utc_timestamp
    };
    my $expected = {
        record => {
            header => {
                datestamp  => $utc_timestamp,
                identifier => 'TEST:' . $item->biblionumber
            },
            metadata => {
                record =>
                    XMLin( $biblio->metadata_record( { embed_items => 1, interface => 'opac' } )->as_xml_record() )
            }
        }
    };
    my $expected_hidden = {
        record => {
            header => {
                datestamp  => $utc_timestamp,
                identifier => 'TEST:' . $item->biblionumber,
                status     => 'deleted'
            },
        }
    };
    test_query(
        'GetRecord - biblio with a single item',
        $get_items,
        { GetRecord => $expected }
    );
    test_query(
        'ListRecords - biblio with a single item',
        $list_items,
        { ListRecords => $expected }
    );

    my $opachiddenitems = "
        itemnumber: ['" . $item->itemnumber . "']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems' => $opachiddenitems );

    test_query(
        'GetRecord - biblio with a single item hidden by OpacHiddenItems returns as deleted',
        $get_items,
        { GetRecord => $expected_hidden }
    );
    test_query(
        'ListRecords - biblio with a single item hidden by OpacHiddenItems returns as deleted',
        $list_items,
        { ListRecords => $expected_hidden }
    );

    $schema->storage->txn_rollback;
};

subtest 'Tests for timestamp handling' => sub {

    plan tests => 28;

    t::lib::Mocks::mock_preference( 'OAI::PMH'         => 1 );
    t::lib::Mocks::mock_preference( 'OAI-PMH:MaxCount' => 3 );
    t::lib::Mocks::mock_preference(
        'OAI-PMH:ConfFile' => File::Spec->rel2abs( dirname(__FILE__) ) . '/oaiconf_items.yaml' );

    $schema->storage->txn_begin;

    my $sth_metadata     = $dbh->prepare('UPDATE biblio_metadata SET timestamp=? WHERE biblionumber=?');
    my $sth_del_metadata = $dbh->prepare('UPDATE deletedbiblio_metadata SET timestamp=? WHERE biblionumber=?');
    my $sth_item         = $dbh->prepare('UPDATE items SET timestamp=? WHERE itemnumber=?');
    my $sth_del_item     = $dbh->prepare('UPDATE deleteditems SET timestamp=? WHERE itemnumber=?');

    my $builder = t::lib::TestBuilder->new;

    set_fixed_time( CORE::time() );

    my $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    my $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';
    my $timestamp     = $utc_datetime;

    # Test a bib with one item
    my $biblio1 = $builder->build_sample_biblio;
    Koha::Biblios->find( $biblio1->biblionumber )->timestamp('1970-05-07 13:36:23')->store;

    $sth_metadata->execute( $timestamp, $biblio1->biblionumber );
    my $item1 = $builder->build_sample_item( { biblionumber => $biblio1->biblionumber } );
    $sth_item->execute( $timestamp, $item1->itemnumber );

    my $list_items = {
        verb           => 'ListRecords',
        metadataPrefix => 'marc21',
        from           => $utc_timestamp
    };
    my $list_no_items = {
        verb           => 'ListRecords',
        metadataPrefix => 'marcxml',
        from           => $utc_timestamp
    };

    my $get_items = {
        verb           => 'GetRecord',
        metadataPrefix => 'marc21',
        identifier     => 'TEST:' . $biblio1->biblionumber
    };
    my $get_no_items = {
        verb           => 'GetRecord',
        metadataPrefix => 'marcxml',
        identifier     => 'TEST:' . $biblio1->biblionumber
    };

    my $expected = {
        record => {
            header => {
                datestamp  => $utc_timestamp,
                identifier => 'TEST:' . $biblio1->biblionumber
            },
            metadata => {
                record =>
                    XMLin( $biblio1->metadata_record( { embed_items => 1, interface => 'opac' } )->as_xml_record() )
            }
        }
    };
    my $expected_no_items = {
        record => {
            header => {
                datestamp  => $utc_timestamp,
                identifier => 'TEST:' . $biblio1->biblionumber
            },
            metadata => { record => XMLin( $biblio1->metadata_record( { interface => 'opac' } )->as_xml_record() ) }
        }
    };

    test_query(
        'ListRecords - biblio with a single item',
        $list_items,
        { ListRecords => $expected }
    );
    test_query(
        'ListRecords - biblio with a single item (items not returned)',
        $list_no_items,
        { ListRecords => $expected_no_items }
    );
    test_query(
        'GetRecord - biblio with a single item',
        $get_items,
        { GetRecord => $expected }
    );
    test_query(
        'GetRecord - biblio with a single item (items not returned)',
        $get_no_items,
        { GetRecord => $expected_no_items }
    );
    t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'root@localhost' );
    test_query(
        'Identify - earliestDatestamp in the right format',
        { verb => 'Identify' },
        {
            Identify => {
                adminEmail        => 'root@localhost',
                baseURL           => 'http://localhost',
                compression       => 'gzip',
                deletedRecord     => 'persistent',
                earliestDatestamp => '1970-05-07T13:36:23Z',
                granularity       => 'YYYY-MM-DDThh:mm:ssZ',
                protocolVersion   => '2.0',
                repositoryName    => 'My Library',
            }
        }
    );

    # Add an item 10 seconds later and check results
    set_relative_time(10);

    $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';
    $timestamp     = $utc_datetime;

    my $item2 = $builder->build_sample_item( { biblionumber => $biblio1->biblionumber } );
    $sth_item->execute( $timestamp, $item2->itemnumber );

    $expected->{record}{header}{datestamp} = $utc_timestamp;
    $expected->{record}{metadata}{record} =
        XMLin( $biblio1->metadata_record( { embed_items => 1, interface => 'opac' } )->as_xml_record() );

    test_query(
        'ListRecords - biblio with two items',
        $list_items,
        { ListRecords => $expected }
    );
    test_query(
        'ListRecords - biblio with two items (items not returned)',
        $list_no_items,
        { ListRecords => $expected_no_items }
    );
    test_query(
        'GetRecord - biblio with a two items',
        $get_items,
        { GetRecord => $expected }
    );
    test_query(
        'GetRecord - biblio with a two items (items not returned)',
        $get_no_items,
        { GetRecord => $expected_no_items }
    );

    # Set biblio timestamp 10 seconds later and check results
    set_relative_time(10);
    $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';
    $timestamp     = $utc_datetime;

    $sth_metadata->execute( $timestamp, $biblio1->biblionumber );

    $expected->{record}{header}{datestamp}          = $utc_timestamp;
    $expected_no_items->{record}{header}{datestamp} = $utc_timestamp;

    test_query(
        "ListRecords - biblio with timestamp higher than item's",
        $list_items,
        { ListRecords => $expected }
    );
    test_query(
        "ListRecords - biblio with timestamp higher than item's (items not returned)",
        $list_no_items,
        { ListRecords => $expected_no_items }
    );
    test_query(
        "GetRecord - biblio with timestamp higher than item's",
        $get_items,
        { GetRecord => $expected }
    );
    test_query(
        "GetRecord - biblio with timestamp higher than item's (items not returned)",
        $get_no_items,
        { GetRecord => $expected_no_items }
    );

    # Delete an item 10 seconds later and check results
    set_relative_time(10);
    $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';

    $item1->safe_delete( { skip_record_index => 1 } );
    $sth_del_item->execute( $timestamp, $item1->itemnumber );

    $expected->{record}{header}{datestamp} = $utc_timestamp;
    $expected->{record}{metadata}{record} =
        XMLin( $biblio1->metadata_record( { embed_items => 1, interface => 'opac' } )->as_xml_record() );

    test_query(
        'ListRecords - biblio with existing and deleted item',
        $list_items,
        { ListRecords => $expected }
    );
    test_query(
        'ListRecords - biblio with existing and deleted item (items not returned)',
        $list_no_items,
        { ListRecords => $expected_no_items }
    );
    test_query(
        'GetRecord - biblio with existing and deleted item',
        $get_items,
        { GetRecord => $expected }
    );
    test_query(
        'GetRecord - biblio with existing and deleted item (items not returned)',
        $get_no_items,
        { GetRecord => $expected_no_items }
    );

    # Delete also the second item and verify results
    $item2->safe_delete( { skip_record_index => 1 } );
    $sth_del_item->execute( $timestamp, $item2->itemnumber );

    $expected->{record}{metadata}{record} =
        XMLin( $biblio1->metadata_record( { embed_items => 1, interface => 'opac' } )->as_xml_record() );

    test_query(
        'ListRecords - biblio with two deleted items',
        $list_items,
        { ListRecords => $expected }
    );
    test_query(
        'ListRecords - biblio with two deleted items (items not returned)',
        $list_no_items,
        { ListRecords => $expected_no_items }
    );
    test_query(
        'GetRecord - biblio with two deleted items',
        $get_items,
        { GetRecord => $expected }
    );
    test_query(
        'GetRecord - biblio with two deleted items (items not returned)',
        $get_no_items,
        { GetRecord => $expected_no_items }
    );

    # Delete the biblio 10 seconds later and check results
    set_relative_time(10);
    $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';
    $timestamp     = dt_from_string( undef, 'sql' );

    is( undef, DelBiblio( $biblio1->biblionumber, { skip_record_index => 1 } ), 'Biblio deleted' );
    $sth_del_metadata->execute( $timestamp, $biblio1->biblionumber );

    my $expected_header = {
        record => {
            header => {
                datestamp  => $utc_timestamp,
                identifier => 'TEST:' . $biblio1->biblionumber,
                status     => 'deleted'
            }
        }
    };

    test_query(
        'ListRecords - deleted biblio with two deleted items',
        $list_items,
        { ListRecords => $expected_header }
    );
    test_query(
        'ListRecords - deleted biblio with two deleted items (items not returned)',
        $list_no_items,
        { ListRecords => $expected_header }
    );
    test_query(
        'GetRecord - deleted biblio with two deleted items',
        $get_items,
        { GetRecord => $expected_header }
    );
    test_query(
        'GetRecord - deleted biblio with two deleted items (items not returned)',
        $get_no_items,
        { GetRecord => $expected_header }
    );

    # Add a second biblio 10 seconds later and check that both are returned properly
    set_relative_time(10);
    $utc_datetime  = dt_from_string( undef, undef, 'UTC' );
    $utc_timestamp = $utc_datetime->ymd . 'T' . $utc_datetime->hms . 'Z';
    $timestamp     = dt_from_string( undef, 'sql' );

    my $biblio2 = $builder->build_sample_biblio();
    $sth_metadata->execute( $timestamp, $biblio2->biblionumber );

    my $expected2 = {
        record => [
            $expected_header->{record},
            {
                header => {
                    datestamp  => $utc_timestamp,
                    identifier => 'TEST:' . $biblio2->biblionumber
                },
                metadata => {
                    record => XMLin(
                        $biblio2->metadata_record( { embed_items => 1, interface => 'opac' } )->as_xml_record()
                    )
                }
            }
        ]
    };
    my $expected2_no_items = {
        record => [
            $expected_header->{record},
            {
                header => {
                    datestamp  => $utc_timestamp,
                    identifier => 'TEST:' . $biblio2->biblionumber
                },
                metadata => { record => XMLin( $biblio2->metadata_record( { interface => 'opac' } )->as_xml_record() ) }
            }
        ]
    };

    test_query(
        'ListRecords - deleted biblio and normal biblio',
        $list_items,
        { ListRecords => $expected2 }
    );
    test_query(
        'ListRecords - deleted biblio and normal biblio (items not returned)',
        $list_no_items,
        { ListRecords => $expected2_no_items }
    );

    restore_time();

    $schema->storage->txn_rollback;
};

subtest 'ListSets() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # initial cleanup
    $schema->resultset('OaiSet')->delete;

    test_query(
        'ListSets - no sets should return a noSetHierarchy exception',
        { verb => 'ListSets' },
        {
            error => {
                code    => 'noSetHierarchy',
                content => 'There are no OAI sets defined',
            }
        }
    );

    # Add a couple sets
    AddOAISet( { spec => 'set_1', name => 'Set 1' } );
    AddOAISet( { spec => 'set_2', name => 'Set 2' } );

    test_query(
        'ListSets - no sets should return a noSetHierarchy exception',
        { verb => 'ListSets' },
        {
            ListSets => {
                set => [
                    { setSpec => 'set_1', setName => 'Set 1' },
                    { setSpec => 'set_2', setName => 'Set 2' },
                ]
            }
        }
    );

    $schema->storage->txn_rollback;
};
