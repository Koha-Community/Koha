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
use Test::More;
use Test::MockModule;
use t::lib::Mocks;
use Data::Dumper;

# Check that all the modules we need are installed, or bail out
BEGIN {
    my $missing_lib;
    eval {
        require Test::DBIx::Class;
        1;
    } or do {
        $missing_lib = "Test::DBIx::Class";
    };

    eval {
        require SOAP::Lite;
        1;
    } or do {
        $missing_lib = "SOAP::Lite";
    };

    eval {
        require Crypt::GCrypt;
        1;
    } or do {
        $missing_lib = "Crypt::GCrypt";
    };

    eval {
        require Convert::BaseN;
        1;
    } or do {
        $missing_lib = "Convert::BaseN";
    };

    if ( $missing_lib ) {
        plan skip_all => $missing_lib . " is not available.";
    } else {
        # Everything good
        plan tests => 73;
    }
}

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'Borrower', 'BorrowerSync';

# Make the code in the module use our mocked Koha::Schema/Koha::Database
my $db = Test::MockModule->new('Koha::Database');
$db->mock(
    # Schema() gives us the DB connection set up by Test::DBIx::Class
    _new_schema => sub { return Schema(); }
);

fixtures_ok [
    'Borrower' => [
        [qw/firstname surname borrowernumber address city/],
        ['Test', 'Borrower', 1, 'Test road', 'Test city'],
        ['Test', 'Borrower', 2, 'Test road', 'Test city'],
        ['Test', 'Borrower', 3, 'Test road', 'Test city'],
        ['Test', 'Borrower', 4, 'Test road', 'Test city'],
    ],
    'BorrowerSync' => [
        [qw/borrowernumber sync syncstatus lastsync hashed_pin synctype/],
        [1, 1, 'new',    '2014-03-31T12:35:14', 'abc', 'norwegianpatrondb' ],
        [2, 1, 'edited', '2014-03-31T12:35:14', 'abc', 'norwegianpatrondb' ],
        [3, 1, 'new',    '2014-03-31T12:35:14', 'abc', 'norwegianpatrondb' ],
        [4, 1, 'new',    '2014-03-31T12:35:14', 'abc', 'norwegianpatrondb' ],
    ],
], 'installed some fixtures';

=head1 LOADING THE MODULE

=cut

BEGIN { use_ok( 'Koha::NorwegianPatronDB', ':all' ) }


=head1 UTILITY SUBROUTINES

=head2 NLCheckSysprefs

Relevant sysprefs:

=over 4

=item * NorwegianPatronDBEnable

=item * NorwegianPatronDBEndpoint

=item * NorwegianPatronDBUsername

=item * NorwegianPatronDBPassword

=back

=cut

BEGIN {
    t::lib::Mocks::mock_config('nlkey',        'key');
    t::lib::Mocks::mock_config('nlvendoruser', 'user');
    t::lib::Mocks::mock_config('nlvendorpass', 'pass');
}
t::lib::Mocks::mock_preference('NorwegianPatronDBEnable',   0);
t::lib::Mocks::mock_preference('NorwegianPatronDBEndpoint', '');
t::lib::Mocks::mock_preference('NorwegianPatronDBUsername', '');
t::lib::Mocks::mock_preference('NorwegianPatronDBPassword', '');

ok( my $result = NLCheckSysprefs(), 'call NLCheckSysprefs() ok' );
is( $result->{ 'error' },     1, 'error detected' );
is( $result->{ 'nlenabled' }, 0, 'NL is not enabled' );
is( $result->{ 'endpoint' },  0, 'an endpoint is not specified' );
is( $result->{ 'userpass' },  0, 'username and/or password is missing' );

t::lib::Mocks::mock_preference('NorwegianPatronDBEnable',   1);
ok( $result = NLCheckSysprefs(), 'call NLCheckSysprefs() ok' );
is( $result->{ 'error' },     1, 'error detected' );
is( $result->{ 'nlenabled' }, 1, 'NL is enabled' );
is( $result->{ 'endpoint' },  0, 'an endpoint is not specified' );
is( $result->{ 'userpass' },  0, 'username and/or password is missing' );

t::lib::Mocks::mock_preference('NorwegianPatronDBEnable',   0);
t::lib::Mocks::mock_preference('NorwegianPatronDBUsername', 'user');
t::lib::Mocks::mock_preference('NorwegianPatronDBPassword', 'pass');
ok( $result = NLCheckSysprefs(), 'call NLCheckSysprefs() ok' );
is( $result->{ 'error' },     1, 'error detected' );
is( $result->{ 'nlenabled' }, 0, 'NL is not enabled' );
is( $result->{ 'endpoint' },  0, 'an endpoint is not specified' );
is( $result->{ 'userpass' },  1, 'username and/or password is present' );

t::lib::Mocks::mock_preference('NorwegianPatronDBEnable',   1);
t::lib::Mocks::mock_preference('NorwegianPatronDBEndpoint', 'http://example.com/');
ok( $result = NLCheckSysprefs(), 'call NLCheckSysprefs() ok' );
is( $result->{ 'error' },     0, 'no error detected' );
is( $result->{ 'nlenabled' }, 1, 'NL is enabled' );
is( $result->{ 'endpoint' },  1, 'an endpoint is specified' );
is( $result->{ 'userpass' },  1, 'username and/or password is present' );

=head2 NLGetFirstname and NLGetSurname

=cut

my $firstname = 'Firstname';
my $surname   = 'Surname';
my $fullname  = "$surname, $firstname";
my $wrongname = "$surname $firstname";

is( NLGetFirstname( $fullname  ), $firstname, 'can get firstname from name' );
is( NLGetSurname(   $fullname  ), $surname,   'can get surname from name' );
is( NLGetFirstname( $wrongname ), $wrongname, 'returns full string when name misses comma' );
is( NLGetSurname(   $wrongname ), $wrongname, 'returns full string when name misses comma' );

=head2 NLDecodePin and NLEncryptPIN

=cut

my $pin  = '1234';
my $hash = NLEncryptPIN( $pin );

is( NLEncryptPIN( $pin ), $hash, 'NLEncryptPIN works' );
is( NLDecodePin( $hash ), $pin, 'NLDecodePin works' );

=head2 NLUpdateHashedPIN

=cut

is ( BorrowerSync->find({ 'borrowernumber' => 1 })->get_column('hashed_pin'), 'abc', 'hashed_pin is "abc"' );
# Set a new pin
my $new_pin = 'bcd';
ok( NLUpdateHashedPIN( 1, $new_pin ), 'NLUpdateHashedPIN runs ok' );
# Hash the new pin and compare it to the one stored in the database
my $hashed_pin = Koha::NorwegianPatronDB::_encrypt_pin( $new_pin );
is ( BorrowerSync->find({ 'borrowernumber' => 1 })->get_column('hashed_pin'), $hashed_pin, 'hashed_pin was updated' );

=head2 NLMarkForDeletion

=cut

is ( BorrowerSync->find({ 'borrowernumber' => 3 })->get_column('syncstatus'), 'new', 'syncstatus is "new"' );
ok( NLMarkForDeletion( 3 ), 'NLMarkForDeletion runs ok' );
# Check that the syncstatus was updated. Note: We will use this status later, to check syncing of deleted borrowers
is ( BorrowerSync->find({ 'borrowernumber' => 3 })->get_column('syncstatus'), 'delete', 'syncstatus is "delete"' );

=head2 NLGetSyncDataFromBorrowernumber

=cut

ok( my $sync_data = NLGetSyncDataFromBorrowernumber( 1 ), 'NLGetSyncDataFromBorrowernumber runs ok' );
isa_ok( $sync_data, 'Koha::Schema::Result::BorrowerSync' );
is( $sync_data->sync, 1, 'the sync is on' );
is( $sync_data->syncstatus, 'new', 'syncstatus is "new"' );
is( $sync_data->lastsync, '2014-03-31T12:35:14', 'lastsync is ok' );
is( $sync_data->hashed_pin, $hashed_pin, 'hashed_pin is ok' );

=head1 SUBROUTINES THAT TALK TO SOAP

=head2 NLSearch

=cut

my $lite = Test::MockModule->new('SOAP::Lite');

# Mock a successfull call to the "hent" method
$lite->mock(
    hent => sub { return SOAP::Deserializer->deserialize( hent_success() )->result; }
);
ok( my $res = NLSearch( '12345678910' ), 'successfull call to NLSearch' );
is( $res->{'antall_poster_returnert'}, 1, 'got 1 record' );
isa_ok( $res, "Resultat" );
isa_ok( $res->{'respons_poster'}, "LaanerListe" );
isa_ok( $res->{'respons_poster'}[0], "Laaner" );

# Mock an unsuccessfull call to the "hent" method
$lite->mock(
    hent => sub { return SOAP::Deserializer->deserialize( hent_failure() )->result; }
);
ok( $res = NLSearch( '12345678910' ), 'call to NLSearch with an illegal argument' );
is( $res->{'antall_poster_returnert'}, 0, 'got 0 records' );
isa_ok( $res, "Resultat" );
like( $res->{'melding'}, qr/Ulovlig argument: hverken LNR eller FNR_HASH/, "got expected error message for an illegal identifier" );

=head2 NLSync

=head3 New patron

=cut

my $borrower = Borrower->find({ 'borrowernumber' => 1 });
$lite->mock(
    nyPost => sub { return SOAP::Deserializer->deserialize( nyPost_success() )->result; }
);
is ( BorrowerSync->find({ 'borrowernumber' => 1 })->get_column('syncstatus'), 'new', 'patron is new' );
ok ( $result = NLSync({ 'patron' => $borrower }), 'successfull call to NLSync via patron ("nyPost")' );
is ( BorrowerSync->find({ 'borrowernumber' => 1 })->get_column('syncstatus'), 'synced', 'patron is synced' );

# Now do the same test, but pass in a borrowernumber, not a Koha::Schema::Result::Borrower
is ( BorrowerSync->find({ 'borrowernumber' => 4 })->get_column('syncstatus'), 'new', 'patron is new' );
ok ( $result = NLSync({ 'borrowernumber' => 4 }), 'successfull call to NLSync via borrowernumber ("nyPost")' );
is ( BorrowerSync->find({ 'borrowernumber' => 4 })->get_column('syncstatus'), 'synced', 'patron is synced' );

=head3 Edited patron

=cut

ok ( $borrower = Borrower->find({ 'borrowernumber' => 2 }), 'find our "edited" mock patron' );
$lite->mock(
    endre => sub { return SOAP::Deserializer->deserialize( endre_success() )->result; }
);
is ( BorrowerSync->find({ 'borrowernumber' => 2 })->get_column('syncstatus'), 'edited', 'patron is edited' );
ok ( $result = NLSync({ 'patron' => $borrower }), 'successfull call to NLSync ("endre")' );
is ( BorrowerSync->find({ 'borrowernumber' => 2 })->get_column('syncstatus'), 'synced', 'patron is synced' );

=head3 Deleted patron

=cut

ok ( $borrower = Borrower->find({ 'borrowernumber' => 3 }), 'find our "deleted" mock patron' );
$lite->mock(
    slett => sub { return SOAP::Deserializer->deserialize( endre_success() )->result; }
);
is ( BorrowerSync->find({ 'borrowernumber' => 3 })->get_column('syncstatus'), 'delete', 'patron is marked for deletion' );
ok ( $result = NLSync({ 'patron' => $borrower }), 'successfull call to NLSync ("slett")' );
is ( BorrowerSync->find({ 'borrowernumber' => 3 })->get_column('sync'), 0, 'sync is now disabled' );

=head2 NLGetChanged

=cut

# Mock a successfull call to the "soekEndret" method
$lite->mock(
    soekEndret => sub { return SOAP::Deserializer->deserialize( soekEndret_success() ); }
);
ok( $res = NLGetChanged(), 'successfull call to NLGetChanged - 2 results' );
is( $res->{'melding'}, 'OK', 'got "OK"' );
is( $res->{'antall_poster_returnert'}, 2, 'got 2 records' );
isa_ok( $res, "Resultat" );
isa_ok( $res->{'respons_poster'}, "LaanerListe" );
isa_ok( $res->{'respons_poster'}[0], "Laaner" );


# Mock a successfull call to the "soekEndret" method, but with zero new records
$lite->mock(
    soekEndret => sub { return SOAP::Deserializer->deserialize( soekEndret_zero_new() ); }
);
ok( $res = NLGetChanged(), 'successfull call to NLGetChanged - 0 results' );
is( $res->{'melding'}, 'ingen treff', 'got "ingen treff"' );
is( $res->{'antall_poster_returnert'}, 0, 'got 0 records' );
is( $res->{'antall_treff'}, 0, 'got 0 records' );

=head1 SAMPLE SOAP XML RESPONSES

These responses can be gathered by setting "outputxml()" to true on the SOAP
client:

    my $client = SOAP::Lite
        ->on_action( sub { return '""';})
        ->uri('http://lanekortet.no')
        ->proxy('https://fl.lanekortet.no/laanekort/fl_test.php')
        ->outputxml(1);
    my $response = $client->slett( $x );
    say $response;

Pretty formatting can be achieved by piping the output from a test script
through xmllint:

    perl my_test_script.pl > xmllint --format -

=cut

sub slett_success {

    return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://lanekortet.no" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns1:slettResponse>
      <return xsi:type="ns1:Svar">
        <status xsi:type="xsd:boolean">true</status>
        <melding xsi:type="xsd:string">Test Testersen (1973-08-11) er slettet fra registeret</melding>
        <lnr xsi:type="xsd:string">N000106188</lnr>
        <server_tid xsi:type="xsd:string">2014-06-02T16:51:58</server_tid>
      </return>
    </ns1:slettResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
ENDRESPONSE

}

sub endre_success {

    return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://lanekortet.no" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns1:endreResponse>
      <return xsi:type="ns1:Svar">
        <status xsi:type="xsd:boolean">true</status>
        <melding xsi:type="xsd:string">Oppdaterte felt: navn, p_adresse1, p_postnr, p_sted, p_land, fdato, fnr_hash, kjonn, pin, sist_endret, sist_endret_av</melding>
        <lnr xsi:type="xsd:string">N000106188</lnr>
        <server_tid xsi:type="xsd:string">2014-06-02T16:42:32</server_tid>
      </return>
    </ns1:endreResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
ENDRESPONSE

}

sub nyPost_success {

    return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://lanekortet.no" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns1:nyPostResponse>
      <return xsi:type="ns1:Svar">
        <status xsi:type="xsd:boolean">true</status>
        <melding xsi:type="xsd:string">Ny post er opprettet</melding>
        <lnr xsi:type="xsd:string">N000106188</lnr>
        <server_tid xsi:type="xsd:string">2014-06-02T14:10:09</server_tid>
      </return>
    </ns1:nyPostResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
ENDRESPONSE

}

sub soekEndret_success {

return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns1="http://lanekortet.no"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns1:soekEndretResponse>
      <return xsi:type="ns1:Resultat">
        <status xsi:type="xsd:boolean">true</status>
        <melding xsi:type="xsd:string">OK</melding>
        <antall_treff xsi:type="xsd:int">2</antall_treff>
        <antall_poster_returnert xsi:type="xsd:int">2</antall_poster_returnert>
        <neste_indeks xsi:type="xsd:int">0</neste_indeks>
        <respons_poster SOAP-ENC:arrayType="ns1:Laaner[2]" xsi:type="ns1:LaanerListe">
          <item xsi:type="ns1:Laaner">
            <lnr xsi:type="xsd:string">N000106186</lnr>
            <navn xsi:type="xsd:string">Hansen, Hanne</navn>
            <p_adresse1 xsi:type="xsd:string"/>
            <p_adresse2 xsi:type="xsd:string"/>
            <p_postnr xsi:type="xsd:string"/>
            <p_sted xsi:type="xsd:string">BØDØ</p_sted>
            <p_land xsi:type="xsd:string">no</p_land>
            <p_sjekk xsi:type="xsd:string">0</p_sjekk>
            <m_adresse1 xsi:type="xsd:string"/>
            <m_adresse2 xsi:type="xsd:string"/>
            <m_postnr xsi:type="xsd:string"/>
            <m_sted xsi:type="xsd:string"/>
            <m_land xsi:type="xsd:string"/>
            <m_sjekk xsi:type="xsd:string">0</m_sjekk>
            <m_gyldig_til xsi:type="xsd:string">0000-00-00</m_gyldig_til>
            <tlf_hjemme xsi:type="xsd:string"/>
            <tlf_jobb xsi:type="xsd:string"/>
            <tlf_mobil xsi:type="xsd:string"/>
            <epost xsi:type="xsd:string"/>
            <epost_sjekk xsi:type="xsd:string"/>
            <prim_kontakt xsi:type="xsd:string"/>
            <hjemmebibliotek xsi:type="xsd:string">5180401</hjemmebibliotek>
            <fdato xsi:type="xsd:string">1994-04-08</fdato>
            <fnr_hash xsi:type="xsd:string">11087395628</fnr_hash>
            <kjonn xsi:type="xsd:string">F</kjonn>
            <pin xsi:type="xsd:string">89308dfc85ee7a5826ae14e2d8efad1e</pin>
            <passord xsi:type="xsd:string"/>
            <feide xsi:type="xsd:string">0</feide>
            <opprettet xsi:type="xsd:string">2014-04-28T15:20:38</opprettet>
            <opprettet_av xsi:type="xsd:string">5180401</opprettet_av>
            <sist_endret xsi:type="xsd:string">2014-04-28T15:20:38</sist_endret>
            <sist_endret_av xsi:type="xsd:string">5180401</sist_endret_av>
            <folkeregsjekk_dato xsi:type="xsd:string">0000-00-00</folkeregsjekk_dato>
          </item>
          <item xsi:type="ns1:Laaner">
            <lnr xsi:type="xsd:string">N000106184</lnr>
            <navn xsi:type="xsd:string">Enger, Magnus</navn>
            <p_adresse1 xsi:type="xsd:string">Svarthammarveien 633333</p_adresse1>
            <p_adresse2 xsi:type="xsd:string"/>
            <p_postnr xsi:type="xsd:string">8015</p_postnr>
            <p_sted xsi:type="xsd:string">Bodø</p_sted>
            <p_land xsi:type="xsd:string">no</p_land>
            <p_sjekk xsi:type="xsd:string">0</p_sjekk>
            <m_adresse1 xsi:type="xsd:string"/>
            <m_adresse2 xsi:type="xsd:string"/>
            <m_postnr xsi:type="xsd:string"/>
            <m_sted xsi:type="xsd:string"/>
            <m_land xsi:type="xsd:string">no</m_land>
            <m_sjekk xsi:type="xsd:string">0</m_sjekk>
            <m_gyldig_til xsi:type="xsd:string">0000-00-00</m_gyldig_til>
            <tlf_hjemme xsi:type="xsd:string">95158548</tlf_hjemme>
            <tlf_jobb xsi:type="xsd:string"/>
            <tlf_mobil xsi:type="xsd:string"/>
            <epost xsi:type="xsd:string">magnus@enger.priv.no</epost>
            <epost_sjekk xsi:type="xsd:string"/>
            <prim_kontakt xsi:type="xsd:string"/>
            <hjemmebibliotek xsi:type="xsd:string">5180401</hjemmebibliotek>
            <fdato xsi:type="xsd:string">1973-08-11</fdato>
            <fnr_hash xsi:type="xsd:string">11087345795</fnr_hash>
            <kjonn xsi:type="xsd:string">M</kjonn>
            <pin xsi:type="xsd:string">a632c504b8c4fba3149115cb07e0796c</pin>
            <passord xsi:type="xsd:string"/>
            <feide xsi:type="xsd:string">0</feide>
            <opprettet xsi:type="xsd:string">2014-04-28T14:52:02</opprettet>
            <opprettet_av xsi:type="xsd:string">5180401</opprettet_av>
            <sist_endret xsi:type="xsd:string">2014-05-13T11:01:33</sist_endret>
            <sist_endret_av xsi:type="xsd:string">5180401</sist_endret_av>
            <folkeregsjekk_dato xsi:type="xsd:string">0000-00-00</folkeregsjekk_dato>
          </item>
        </respons_poster>
        <server_tid xsi:type="xsd:string">2014-05-16T14:44:44</server_tid>
      </return>
    </ns1:soekEndretResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
ENDRESPONSE
}

sub soekEndret_zero_new {
    return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
    <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://lanekortet.no" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <SOAP-ENV:Body>
        <ns1:soekEndretResponse>
          <return xsi:type="ns1:Resultat">
            <status xsi:type="xsd:boolean">false</status>
            <melding xsi:type="xsd:string">ingen treff</melding>
            <antall_treff xsi:type="xsd:int">0</antall_treff>
            <antall_poster_returnert xsi:type="xsd:int">0</antall_poster_returnert>
            <neste_indeks xsi:type="xsd:int">0</neste_indeks>
            <respons_poster SOAP-ENC:arrayType="ns1:Laaner[0]" xsi:type="ns1:LaanerListe"/>
            <server_tid xsi:type="xsd:string">2014-05-20T13:02:02</server_tid>
          </return>
        </ns1:soekEndretResponse>
      </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>
ENDRESPONSE
}

sub hent_failure {
    return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns1="http://lanekortet.no"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns1:hentResponse>
      <return xsi:type="ns1:Resultat">
        <status xsi:type="xsd:boolean">false</status>
        <melding xsi:type="xsd:string">hent: Ulovlig argument: hverken LNR eller FNR_HASH</melding>
        <antall_treff xsi:type="xsd:int">0</antall_treff>
        <antall_poster_returnert xsi:type="xsd:int">0</antall_poster_returnert>
        <neste_indeks xsi:type="xsd:int">0</neste_indeks>
        <respons_poster SOAP-ENC:arrayType="ns1:Laaner[0]" xsi:type="ns1:LaanerListe"/>
        <server_tid xsi:type="xsd:string">2014-05-15T10:56:24</server_tid>
      </return>
    </ns1:hentResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
ENDRESPONSE

}

sub hent_success {

return <<'ENDRESPONSE';
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:ns1="http://lanekortet.no"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
    SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <SOAP-ENV:Body>
    <ns1:hentResponse>
      <return xsi:type="ns1:Resultat">
        <status xsi:type="xsd:boolean">true</status>
        <melding xsi:type="xsd:string">OK</melding>
        <antall_treff xsi:type="xsd:int">1</antall_treff>
        <antall_poster_returnert xsi:type="xsd:int">1</antall_poster_returnert>
        <neste_indeks xsi:type="xsd:int">0</neste_indeks>
        <respons_poster SOAP-ENC:arrayType="ns1:Laaner[1]" xsi:type="ns1:LaanerListe">
          <item xsi:type="ns1:Laaner">
            <lnr xsi:type="xsd:string">N000123456</lnr>
            <navn xsi:type="xsd:string">Test, Testersen</navn>
            <p_adresse1 xsi:type="xsd:string">Bibliotekveien 6</p_adresse1>
            <p_adresse2 xsi:type="xsd:string"/>
            <p_postnr xsi:type="xsd:string">1234</p_postnr>
            <p_sted xsi:type="xsd:string">Lillevik</p_sted>
            <p_land xsi:type="xsd:string">no</p_land>
            <p_sjekk xsi:type="xsd:string">0</p_sjekk>
            <m_adresse1 xsi:type="xsd:string"/>
            <m_adresse2 xsi:type="xsd:string"/>
            <m_postnr xsi:type="xsd:string"/>
            <m_sted xsi:type="xsd:string"/>
            <m_land xsi:type="xsd:string">no</m_land>
            <m_sjekk xsi:type="xsd:string">0</m_sjekk>
            <m_gyldig_til xsi:type="xsd:string">0000-00-00</m_gyldig_til>
            <tlf_hjemme xsi:type="xsd:string"/>
            <tlf_jobb xsi:type="xsd:string"/>
            <tlf_mobil xsi:type="xsd:string">12345678</tlf_mobil>
            <epost xsi:type="xsd:string">test@example.com</epost>
            <epost_sjekk xsi:type="xsd:string">0</epost_sjekk>
            <prim_kontakt xsi:type="xsd:string"/>
            <hjemmebibliotek xsi:type="xsd:string">2060000</hjemmebibliotek>
            <fdato xsi:type="xsd:string">1964-05-22</fdato>
            <fnr_hash xsi:type="xsd:string">22056412345</fnr_hash>
            <kjonn xsi:type="xsd:string">F</kjonn>
            <pin xsi:type="xsd:string">g345abc123dab567abc78900abc123ab</pin>
            <passord xsi:type="xsd:string"/>
            <feide xsi:type="xsd:string"/>
            <opprettet xsi:type="xsd:string">2005-10-20</opprettet>
            <opprettet_av xsi:type="xsd:string">2060000</opprettet_av>
            <sist_endret xsi:type="xsd:string">2013-05-13T13:51:24</sist_endret>
            <sist_endret_av xsi:type="xsd:string">2060000</sist_endret_av>
            <gyldig_til xsi:type="xsd:string"/>
            <folkeregsjekk_dato xsi:type="xsd:string">0000-00-00</folkeregsjekk_dato>
          </item>
        </respons_poster>
        <server_tid xsi:type="xsd:string">2014-01-07T14:43:18</server_tid>
      </return>
    </ns1:hentResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
ENDRESPONSE

}
