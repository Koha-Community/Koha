#!/usr/bin/perl

# Copyright Tamil s.a.r.l. 2015
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
use C4::Context;
use C4::Biblio;
use Test::More tests => 13;
use Test::MockModule;
use Test::Warn;
use DateTime;
use XML::Simple;
use t::lib::Mocks;


BEGIN {
    use_ok('Koha::OAI::Server::DeletedRecord');
    use_ok('Koha::OAI::Server::Description');
    use_ok('Koha::OAI::Server::GetRecord');
    use_ok('Koha::OAI::Server::Identify');
    use_ok('Koha::OAI::Server::ListIdentifiers');
    use_ok('Koha::OAI::Server::ListMetadataFormats');
    use_ok('Koha::OAI::Server::ListRecords');
    use_ok('Koha::OAI::Server::ListSets');
    use_ok('Koha::OAI::Server::Record');
    use_ok('Koha::OAI::Server::Repository');
    use_ok('Koha::OAI::Server::ResumptionToken');
}


# Mocked CGI module in order to be able to send CGI parameters to OAI Server
my %param;
my $module = Test::MockModule->new('CGI');
$module->mock('Vars', sub { %param; });

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM biblio');
$dbh->do('DELETE FROM biblioitems');
$dbh->do('DELETE FROM items');

# Add 10 biblio records
my @bibs = map {
    my $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new('245', '', '', 'a' => "Title $_" ) );
    my ($biblionumber) = AddBiblio($record, '');
    $biblionumber;
} (1..10);

t::lib::Mocks::mock_preference('LibraryName', 'My Library');
t::lib::Mocks::mock_preference('OAI::PMH', 1);
t::lib::Mocks::mock_preference('OAI-PMH:archiveID', 'TEST');
t::lib::Mocks::mock_preference('OAI-PMH:ConfFile', '' );
t::lib::Mocks::mock_preference('OAI-PMH:MaxCount', 3);
t::lib::Mocks::mock_preference('OAI-PMH:DeletedRecord', 'persistent');

%param = ( verb => 'ListMetadataFormats' );
my $response;
my $get_response = sub {
    my $stdout;
    local *STDOUT;
    open STDOUT, '>', \$stdout;
    Koha::OAI::Server::Repository->new();
    $response = XMLin($stdout);
};
$get_response->();
my $now = DateTime->now . 'Z';
my $expected = {
    request => 'http://localhost',
    responseDate => $now,
    xmlns => 'http://www.openarchives.org/OAI/2.0/',
    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
    'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd',
    ListMetadataFormats => {
        metadataFormat => [
            {
                metadataNamespace => 'http://www.openarchives.org/OAI/2.0/oai_dc/',
                metadataPrefix=> 'oai_dc',
                schema => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
            },
            {
                metadataNamespace => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim',
                metadataPrefix => 'marcxml',
                schema => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
            },
        ],
    },
};
is_deeply($response, $expected, "ListMetadataFormats");

%param = ( verb => 'ListIdentifiers' );
$get_response->();
$now = DateTime->now . 'Z';
$expected = {
    request => 'http://localhost',
    responseDate => $now,
    xmlns => 'http://www.openarchives.org/OAI/2.0/',
    'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
    'xsi:schemaLocation' => 'http://www.openarchives.org/OAI/2.0/ http://www.openarchives.org/OAI/2.0/OAI-PMH.xsd',
    error => {
        code => 'badArgument',
        content => "Required argument 'metadataPrefix' was undefined",
    },
};
is_deeply($response, $expected, "ListIdentifiers without metadaPrefix argument");

$dbh->rollback;
