#!/usr/bin/env perl

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

use utf8;
use Encode;

use Test::More tests => 5;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Mojo::JSON qw(encode_json);

use C4::Auth;

use Koha::Authorities;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'get() tests' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $authority = $builder->build_object({ 'class' => 'Koha::Authorities', value => {
      marcxml => q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|
    } });

    $t->get_ok("//$userid:$password@/api/v1/authorities/" . $authority->id)
      ->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                => { Accept => 'application/weird+format' } )
      ->status_is(400);

    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                 => { Accept => 'application/json' } )
      ->status_is(200)
      ->json_is( '/authority_id', $authority->id )
      ->json_is( '/framework_id', $authority->authtypecode );

    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                 => { Accept => 'application/marcxml+xml' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                 => { Accept => 'application/marc-in-json' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                 => { Accept => 'application/marc' } )
      ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                 => { Accept => 'text/plain' } )
      ->status_is(200)
      ->content_is(q|LDR 00079     2200049   4500
001     1001
110    _9102
       _aMy Corporation|);

    $authority->delete;
    $t->get_ok( "//$userid:$password@/api/v1/authorities/" . $authority->id
                 => { Accept => 'application/marc' } )
      ->status_is(404)
      ->json_is( '/error', 'Object not found.' );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 } # no permissions
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $authority = $builder->build_object({ 'class' => 'Koha::Authorities', value => {
      marcxml => q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|
    } });

    $t->delete_ok("//$userid:$password@/api/v1/authorities/".$authority->id)
      ->status_is(403, 'Not enough permissions makes it return the right code');

    $patron->flags( 2 ** 14 )->store; # 14 => editauthorities userflag

    $t->delete_ok("//$userid:$password@/api/v1/authorities/".$authority->id)
      ->status_is(204, 'SWAGGER3.2.4')
      ->content_is('', 'SWAGGER3.3.4');

    $t->delete_ok("//$userid:$password@/api/v1/authorities/".$authority->id)
      ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'post() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    my $authorities_mock = Test::MockModule->new('C4::AuthoritiesMarc');
    $authorities_mock->mock( 'FindDuplicateAuthority', sub { return 1234; } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 } # no permissions
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $marcxml = q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|;

    my $mij = '{"fields":[{"001":"1001"},{"110":{"subfields":[{"9":"102"},{"a":"My Corporation"}],"ind1":" ","ind2":" "}}],"leader":"                        "}';
    my $marc = '00079     2200049   45000010005000001100024000051001  9102aMy Corporation';
    my $json = {
      authtypecode => "CORPO_NAME",
      marcxml      => $marcxml
    };

    $t->post_ok("//$userid:$password@/api/v1/authorities")
      ->status_is(403, 'Not enough permissions makes it return the right code');

    # Add permissions
    $patron->flags( 2 ** 14 )->store; # 14 => editauthorities userflag

    # x-koha-override passed to make sure it goes through
    $t->post_ok("//$userid:$password@/api/v1/authorities" => {'Content-Type' => 'application/marcxml+xml', 'x-authority-type' => 'CORPO_NAME', 'x-koha-override' => 'any' } => $marcxml)
      ->status_is(201)
      ->json_is(q{})
      ->header_like(
          Location => qr|^\/api\/v1\/authorities/\d*|,
          'SWAGGER3.4.1'
      );

    # x-koha-override not passed to force block because duplicate
    $t->post_ok("//$userid:$password@/api/v1/authorities" => {'Content-Type' => 'application/marc-in-json', 'x-authority-type' => 'CORPO_NAME' } => $mij)
      ->status_is(409)
      ->header_exists_not( 'Location', 'Location header is only set when the new resource is created' )
      ->json_like( '/error' => qr/Duplicate record (\d*)/ )
      ->json_is( '/error_code' => q{duplicate} );

    $t->post_ok("//$userid:$password@/api/v1/authorities" => {'Content-Type' => 'application/marc-in-json', 'x-authority-type' => 'CORPO_NAME', 'x-koha-override' => 'duplicate' } => $mij)
      ->status_is(201)
      ->json_is(q{})
      ->header_like(
          Location => qr|^\/api\/v1\/authorities/\d*|,
          'SWAGGER3.4.1'
      );

    $t->post_ok("//$userid:$password@/api/v1/authorities" => {'Content-Type' => 'application/marc', 'x-authority-type' => 'CORPO_NAME', 'x-koha-override' => 'duplicate' } => $marc)
      ->status_is(201)
      ->json_is(q{})
      ->header_like(
          Location => qr|^\/api\/v1\/authorities/\d*|,
          'SWAGGER3.4.1'
      );

    $schema->storage->txn_rollback;
};

subtest 'put() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    Koha::Authorities->delete;

    my $record;
    my $subfield_a;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 } # no permissions
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $authority = $builder->build_object({ 'class' => 'Koha::Authorities', value => {
      marcxml => q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|
    } });

    my $authid       = $authority->id;
    my $authtypecode = $authority->authtypecode;

    my $marcxml = q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">MARCXML</subfield>
    </datafield>
</record>|;

    my $mij = '{"fields":[{"001":"1001"},{"110":{"subfields":[{"9":"102"},{"a":"MIJ"}],"ind1":" ","ind2":" "}}],"leader":"                        "}';
    my $marc = '00079     2200049   45000010005000001100024000051001  9102aUSMARCFormated';

    $t->put_ok("//$userid:$password@/api/v1/authorities/$authid")
      ->status_is(403, 'Not enough permissions makes it return the right code');

    # Add permissions
    $patron->flags( 2 ** 14 )->store; # 14 => editauthorities userflag

    $t->put_ok("//$userid:$password@/api/v1/authorities/$authid" => {'Content-Type' => 'application/marcxml+xml', 'x-authority-type' => $authtypecode} => $marcxml)
      ->status_is(200)
      ->json_has('/id');

    $authority = Koha::Authorities->find($authid);
    $record = $authority->record;
    $subfield_a = $record->subfield('110', 'a');

    is($subfield_a, 'MARCXML');

    $t->put_ok("//$userid:$password@/api/v1/authorities/$authid" => {'Content-Type' => 'application/marc-in-json', 'x-authority-type' => $authtypecode} => $mij)
      ->status_is(200)
      ->json_has('/id');

    $authority = Koha::Authorities->find($authid);
    $record = $authority->record;
    $subfield_a = $record->subfield('110', 'a');

    is($subfield_a, 'MIJ');

    $t->put_ok("//$userid:$password@/api/v1/authorities/$authid" => {'Content-Type' => 'application/marc', 'x-authority-type' => $authtypecode} => $marc)
      ->status_is(200)
      ->json_has('/id');

    $authority = Koha::Authorities->find($authid);
    $record = $authority->record;
    $subfield_a = $record->subfield('110', 'a');

    is($subfield_a, 'USMARCFormated');

    $schema->storage->txn_rollback;
};



subtest 'list() tests' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $auth_id_1 = $builder->build_object({ 'class' => 'Koha::Authorities', value => {
      marcxml => q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|
    } })->authid;

    my $auth_id_2 = $builder->build_object({ 'class' => 'Koha::Authorities', value => {
      marcxml => q|<?xml version="1.0" encoding="UTF-8"?>
<record xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/MARC21/slim" xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
    <controlfield tag="001">1001</controlfield>
    <datafield tag="110" ind1=" " ind2=" ">
        <subfield code="9">102</subfield>
        <subfield code="a">My Corporation</subfield>
    </datafield>
</record>|
    } })->authid;

    my $query = encode_json( [ { authority_id => $auth_id_1 }, { authority_id => $auth_id_2 } ] );

    $t->get_ok("//$userid:$password@/api/v1/authorities?q=$query")->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/authorities?q=$query" => { Accept => 'application/weird+format' } )
        ->status_is(400);

    $t->get_ok( "//$userid:$password@/api/v1/authorities?q=$query" => { Accept => 'application/json' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities?q=$query" => { Accept => 'application/marcxml+xml' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities?q=$query" => { Accept => 'application/marc-in-json' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities?q=$query" => { Accept => 'application/marc' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/authorities?q=$query" => { Accept => 'text/plain' } )->status_is(200);

    $schema->storage->txn_rollback;
};
