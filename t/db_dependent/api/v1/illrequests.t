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

use Test::More tests => 2;

use Test::MockModule;
use Test::MockObject;
use Test::Mojo;

use JSON qw(encode_json);

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Illrequests;
use Koha::DateUtils qw( format_sqldatetime );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list_legacy() tests' => sub {

    plan tests => 30;

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always('name', 'Mock');
    $backend->set_always('capabilities', sub { return 'bar'; } );
    $backend->mock(
        'metadata',
        sub {
            my ( $self, $rq ) = @_;
            return {
                ID => $rq->illrequest_id,
                Title => $rq->patron->borrowernumber
            }
        }
    );
    $backend->mock(
        'status_graph', sub {},
    );

    # Mock Koha::Illrequest::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::Illrequest');
    $illreqmodule->mock( 'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;

    # create an authorized user
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { flags => 2 ** 22 } # 22 => ill
    });
    my $password = 'thePassword123';
    $patron->set_password({ password => $password, skip_validation => 1 });
    my $userid = $patron->userid;

    ## Authorized user tests
    # No requests, so empty array should be returned
    $t->get_ok( "//$userid:$password@/api/v1/illrequests" )
      ->status_is(200)
      ->json_is( [] );

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    # Create an ILL request
    my $illrequest = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                backend        => 'Mock',
                biblio_id      => undef,
                branchcode     => $library->branchcode,
                borrowernumber => $patron_1->borrowernumber,
                status         => 'STATUS1',
            }
        }
    );

    # The api response is always augmented with the id_prefix
    my $response = $illrequest->unblessed;
    $response->{id_prefix} = $illrequest->id_prefix;

    my $req_formatted = add_formatted($response);

    # One illrequest created, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/illrequests" )
      ->status_is(200)
      ->json_is( [ $req_formatted ] );

    # One illrequest created, returned with augmented data
    $t->get_ok( "//$userid:$password@/api/v1/illrequests?embed=patron,library,capabilities,metadata,requested_partners" )
      ->status_is(200)
      ->json_has( '/0/patron', 'patron embedded' )
      ->json_is( '/0/patron/patron_id', $patron_1->borrowernumber, 'The right patron is embeded')
      ->json_has( '/0/requested_partners', 'requested_partners embedded' )
      ->json_has( '/0/capabilities', 'capabilities embedded' )
      ->json_has( '/0/library', 'library embedded'  )
      ->json_has( '/0/metadata', 'metadata embedded'  )
      ->json_hasnt( '/1', 'Only one request was created' );

    # Create another ILL request
    my $illrequest2 = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                backend        => 'Mock',
                biblio_id      => undef,
                branchcode     => $library->branchcode,
                borrowernumber => $patron_2->borrowernumber,
                status         => 'STATUS2',
            }
        }
    );

    # The api response is always augmented with the id_prefix
    my $response2 = $illrequest2->unblessed;
    $response2->{id_prefix} = $illrequest2->id_prefix;

    my $req2_formatted = add_formatted($response2);

    # Two illrequest created, should get returned
    $t->get_ok( "//$userid:$password@/api/v1/illrequests" )
      ->status_is(200)
      ->json_is( [ $req_formatted, $req2_formatted ] );

    # Warn on unsupported query parameter
    $t->get_ok( "//$userid:$password@/api/v1/illrequests?request_blah=blah" )
      ->status_is(400)
      ->json_is(
        [{ path => '/query/request_blah', message => 'Malformed query string'}]
    );

    # Test the borrowernumber parameter
    $t->get_ok( "//$userid:$password@/api/v1/illrequests?borrowernumber=" . $patron_2->borrowernumber )
      ->status_is(200)
      ->json_is( [ $response2 ] );

    # Test the ILLHiddenRequestStatuses syspref
    t::lib::Mocks::mock_preference( 'ILLHiddenRequestStatuses', 'STATUS1' );
    $t->get_ok( "//$userid:$password@/api/v1/illrequests" )
      ->status_is(200)
      ->json_is( [ $req2_formatted ] );

    t::lib::Mocks::mock_preference( 'ILLHiddenRequestStatuses', 'STATUS2' );
    $t->get_ok( "//$userid:$password@/api/v1/illrequests" )
      ->status_is(200)
      ->json_is( [ $req_formatted ] );

    $schema->storage->txn_rollback;
};

subtest 'list() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    Koha::Illrequests->search->delete;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 ** 22 } # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    $t->get_ok("//$userid:$password@/api/v1/ill_requests")
      ->status_is(200)
      ->json_is( [] );

    my $req_1 = $builder->build_object({ class => 'Koha::Illrequests', value => { biblio_id => undef, status => 'REQ' } });
    my $req_2 = $builder->build_object({ class => 'Koha::Illrequests', value => { biblio_id => undef, status => 'REQ' } } );
    my $ret   = $builder->build_object({ class => 'Koha::Illrequests', value => { biblio_id => undef, status => 'RET' } } );

    $t->get_ok("//$userid:$password@/api/v1/ill_requests")
      ->status_is(200)
      ->json_is( [ $req_1->to_api, $req_2->to_api, $ret->to_api ]);

    my $query = encode_json({ status => 'REQ' });

    # Filtering works
    $t->get_ok("//$userid:$password@/api/v1/ill_requests?q=$query" )
      ->status_is(200)
      ->json_is( [ $req_1->to_api, $req_2->to_api ]);

    $schema->storage->txn_rollback;
};

sub add_formatted {
    my $req = shift;
    my @format_dates = ( 'placed', 'updated', 'completed' );
    # We need to embellish the request with properties that the API
    # controller calculates on the fly
    # Create new "formatted" columns for each date column
    # that needs formatting
    foreach my $field(@format_dates) {
        if (defined $req->{$field}) {
            $req->{$field . "_formatted"} = format_sqldatetime(
                $req->{$field},
                undef,
                undef,
                1
            );
        }
    }
    return $req;
}
