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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;

use Test::MockModule;
use Test::MockObject;
use Test::Mojo;

use JSON qw(encode_json);

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::AuthorisedValueCategories;
use Koha::ILL::Requests;
use Koha::DateUtils qw( format_sqldatetime );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 34;

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always( 'name',         'Mock' );
    $backend->set_always( 'capabilities', sub { return 'bar'; } );
    $backend->mock(
        'metadata',
        sub {
            my ( $self, $rq ) = @_;
            return {
                ID    => $rq->illrequest_id,
                Title => $rq->patron->borrowernumber
            };
        }
    );
    $backend->mock(
        'status_graph', sub { },
    );

    # Mock Koha::ILL::Request::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::ILL::Request');
    $illreqmodule->mock(
        'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    $schema->storage->txn_begin;

    Koha::ILL::Requests->search->delete;

    # create an authorized user
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    # create an unauthorized user
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $patron->userid;

    # Make sure the ILL_STATUS_ALIAS authorised value category is defined
    unless ( Koha::AuthorisedValueCategories->search( { category_name => 'ILL_STATUS_ALIAS' } )->count > 0 ) {
        $builder->build_object(
            { class => 'Koha::AuthorisedValueCategories', value => { category_name => 'ILL_STATUS_ALIAS' } } );
    }

    my $tag     = "Print copy";
    my $av_code = "print_copy";
    my $av      = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => 'ILL_STATUS_ALIAS',
                authorised_value => $av_code,
                lib              => $tag,
            }
        }
    );

    # No requests, expect empty
    $t->get_ok("//$userid:$password@/api/v1/ill/requests")->status_is(200)->json_is( [] );

    # Prepare some expected response structure
    my $request_status = {
        code => "REQ",
        str  => "Requested"
    };

    my $response_status = {
        backend => $backend->name,
        code    => $request_status->{code},
        str     => $request_status->{str},
        type    => "ill_status"
    };

    my $response_status_av = {
        category => "ILL_STATUS_ALIAS",
        code     => $av_code,
        str      => $tag,
        type     => "av"
    };

    # Create some ILL requests
    my $req_1 = $builder->build_object(
        {
            class => 'Koha::ILL::Requests',
            value => {
                borrowernumber => $patron->borrowernumber,
                batch_id       => undef,
                status         => $request_status->{code},
                backend        => $backend->name,
                notesstaff     => '1'
            }
        }
    );
    my $req_2 = $builder->build_object(
        {
            class => 'Koha::ILL::Requests',
            value => {
                batch_id     => undef,
                status       => $request_status->{code},
                backend      => $backend->name,
                status_alias => $av->authorised_value,
                notesstaff   => '2'
            }

        }
    );
    my $ret = $builder->build_object( { class => 'Koha::ILL::Requests', value => { status => 'RET' } } );

    # Three requests exist, expect all three to be returned
    $t->get_ok("//$userid:$password@/api/v1/ill/requests")->status_is(200)->json_is(
        [
            $req_1->to_api( { user => $librarian } ), $req_2->to_api( { user => $librarian } ),
            $ret->to_api( { user => $librarian } )
        ]
    );

    my $status_query       = encode_json( { status    => 'REQ' } );
    my $status_alias_query = encode_json( { status_av => $av_code } );

    # x-koha-embed: +strings
    # Two requests exist with status 'REQ', expect them to be returned
    # One of which also has a status_alias, expect that to be in that request's body
    $t->get_ok( "//$userid:$password@/api/v1/ill/requests?q=$status_query" => { "x-koha-embed" => "+strings" } )
        ->status_is(200)
        ->json_is(
        [
            { _strings => { status => $response_status }, %{ $req_1->to_api( { user => $librarian } ) } },
            {
                _strings => { status => $response_status, status_av => $response_status_av },
                %{ $req_2->to_api( { user => $librarian } ) }
            }
        ]
        );

    # One request with status_alias 'print_copy' exists, expect that to be returned
    $t->get_ok( "//$userid:$password@/api/v1/ill/requests?q=$status_alias_query" => { "x-koha-embed" => "+strings" } )
        ->status_is(200)
        ->json_is(
        [
            {
                _strings => { status => $response_status, status_av => $response_status_av },
                %{ $req_2->to_api( { user => $librarian } ) }
            }
        ]
        );

    # x-koha-embed: patron
    my $patron_query = encode_json( { borrowernumber => $patron->borrowernumber } );

    # One request related to $patron, make sure it comes back
    $t->get_ok( "//$userid:$password@/api/v1/ill/requests" => { "x-koha-embed" => "patron" } )
        ->status_is(200)
        ->json_has( '/0/patron', $patron->to_api( { user => $librarian } ) );

    # x-koha-embed: comments
    # Create comment
    my $comment_text = "This is the comment";
    my $comment      = $builder->build_object(
        {
            class => 'Koha::ILL::Comments',
            value => {
                illrequest_id  => $req_1->illrequest_id, comment => $comment_text,
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    # Make sure comments come back
    $t->get_ok( "//$userid:$password@/api/v1/ill/requests" => { "x-koha-embed" => "comments" } )
        ->status_is(200)
        ->json_has( '/0/comments', $comment_text );

    # x-koha-embed: id_prefix
    # Mock ILL::Request::Config to return a static prefix
    my $id_prefix = 'ILL';
    my $config    = Test::MockObject->new;
    $config->set_isa('Koha::ILL::Request::Config::Mock');
    $config->set_always( 'getPrefixes', $id_prefix );

    # Make sure id_prefix comes back
    $t->get_ok( "//$userid:$password@/api/v1/ill/requests" => { "x-koha-embed" => "id_prefix" } )
        ->status_is(200)
        ->json_has( '/0/id_prefix', $id_prefix );

    # ILLHiddenRequestStatuses syspref
    # Hide 'REQ', expect to return just 1 'RET'
    t::lib::Mocks::mock_preference( 'ILLHiddenRequestStatuses', 'REQ' );
    $t->get_ok("//$userid:$password@/api/v1/ill/requests")
        ->status_is(200)
        ->json_is( [ $ret->to_api( { user => $librarian } ) ] );

    # Hide 'RET', expect to return 2 'REQ'
    t::lib::Mocks::mock_preference( 'ILLHiddenRequestStatuses', 'RET' );
    $t->get_ok("//$userid:$password@/api/v1/ill/requests?_order_by=staff_notes")
        ->status_is(200)
        ->json_is( [ $req_1->to_api( { user => $librarian } ), $req_2->to_api( { user => $librarian } ) ] );

    # Status code
    # Warn on unsupported query parameter
    $t->get_ok("//$userid:$password@/api/v1/ill/requests?request_blah=blah")
        ->status_is(400)
        ->json_is( [ { path => '/query/request_blah', message => 'Malformed query string' } ] );

    # Unauthorized attempt to list
    $t->get_ok("//$unauth_userid:$password@/api/v1/ill/requests")->status_is(403);

    # DELETE method not supported
    $t->delete_ok("//$unauth_userid:$password@/api/v1/ill/requests/1")->status_is(404);

    #TODO; test complex query on extended_attributes

    $schema->storage->txn_rollback;
};

subtest 'public_patron_list() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always( 'name', 'Mock' );
    $backend->mock(
        'status_graph', sub { },
    );

    # Mock Koha::ILL::Request::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::ILL::Request');
    $illreqmodule->mock(
        'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    my $password = 'thePassword123';

    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $patron_1_userid = $patron_1->userid;
    my $patron_1_id     = $patron_1->id;

    $patron_1->set_password( { password => $password, skip_validation => 1 } );

    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );

    $patron_2->set_password( { password => $password, skip_validation => 1 } );

    my $patron_2_userid = $patron_2->userid;
    my $patron_2_id     = $patron_2->id;

    # No requests yet, expect empty for both
    $t->get_ok("//$patron_1_userid:$password@/api/v1/public/patrons/$patron_1_id/ill/requests")
        ->status_is(200)
        ->json_is( [] );

    $t->get_ok("//$patron_2_userid:$password@/api/v1/public/patrons/$patron_2_id/ill/requests")
        ->status_is(200)
        ->json_is( [] );

    for ( 0 .. 25 ) {
        $builder->build_object(
            {
                class => 'Koha::ILL::Requests',
                value => {
                    borrowernumber => $patron_1_id,
                    batch_id       => undef,
                    status         => 'NEW',
                    backend        => $backend->name,
                    notesstaff     => 'secret staff notes'
                }
            }
        );
    }

    # Other user should not see anything
    $t->get_ok("//$patron_2_userid:$password@/api/v1/public/patrons/$patron_2_id/ill/requests")
        ->status_is(200)
        ->json_is( [] );

    # Staff notes hidden in the public API
    $t->get_ok("//$patron_1_userid:$password@/api/v1/public/patrons/$patron_1_id/ill/requests?_per_page=-1")
        ->status_is(200)
        ->json_is(
        '/0/staff_notes' => undef,
        );

    my $reqs = $t->tx->res->json;
    is( scalar @{$reqs}, 26, 'All ILL requests returned for the patron' );

    $schema->storage->txn_rollback;
};

subtest 'patron_list() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always( 'name', 'Mock' );
    $backend->mock(
        'status_graph', sub { },
    );

    # Mock Koha::ILL::Request::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::ILL::Request');
    $illreqmodule->mock(
        'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    my $password = 'thePassword123';

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );

    my $user_id   = $patron->userid;
    my $patron_id = $patron->id;

    $patron->set_password( { password => $password, skip_validation => 1 } );

    # No requests yet, expect empty for both
    $t->get_ok("//$user_id:$password@/api/v1/patrons/$patron_id/ill/requests")->status_is(200)->json_is( [] );

    my $secret_notes = 'secret staff notes';

    for ( 0 .. 25 ) {
        $builder->build_object(
            {
                class => 'Koha::ILL::Requests',
                value => {
                    borrowernumber => $patron_id,
                    batch_id       => undef,
                    status         => 'NEW',
                    backend        => $backend->name,
                    notesstaff     => $secret_notes,
                }
            }
        );
    }

    # Staff notes available in the staff endpoint
    $t->get_ok("//$user_id:$password@/api/v1/patrons/$patron_id/ill/requests?_per_page=-1")->status_is(200)->json_is(
        '/0/staff_notes' => $secret_notes,
    );

    my $reqs = $t->tx->res->json;
    is( scalar @{$reqs}, 26, 'All ILL requests returned for the patron' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # create an authorized user
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    # Create an ILL request
    my $illrequest = $builder->build_object(
        {
            class => 'Koha::ILL::Requests',
            value => {
                backend        => 'Mock',
                branchcode     => $library->branchcode,
                borrowernumber => $patron->borrowernumber,
                status         => 'STATUS1',
            }
        }
    );

    # Mock ILLBackend (as object)
    my $backend = Test::MockObject->new;
    $backend->set_isa('Koha::Illbackends::Mock');
    $backend->set_always( 'name', 'Mock' );

    $backend->mock(
        'metadata',
        sub {
            my ( $self, $rq ) = @_;
            return {
                ID    => $rq->illrequest_id,
                Title => $rq->patron->borrowernumber
            };
        }
    );
    $backend->mock(
        'status_graph', sub { },
    );

    # Mock Koha::ILL::Request::load_backend (to load Mocked Backend)
    my $illreqmodule = Test::MockModule->new('Koha::ILL::Request');
    $illreqmodule->mock(
        'load_backend',
        sub { my $self = shift; $self->{_my_backend} = $backend; return $self }
    );

    $illreqmodule->mock(
        '_backend',
        sub {
            my $self = shift;
            $self->{_my_backend} = $backend if ($backend);

            return $self;
        }
    );

    $illreqmodule->mock(
        'capabilities',
        sub {
            my ( $self, $name ) = @_;

            my $capabilities = {

                create_api => sub {
                    my ( $body, $request ) = @_;

                    my $api_req = $builder->build_object(
                        {
                            class => 'Koha::ILL::Requests',
                            value => {
                                borrowernumber => $patron->borrowernumber,
                                batch_id       => undef,
                                status         => 'NEW',
                                backend        => $backend->name,
                            }
                        }
                    );

                    return $api_req;
                }
            };

            return $capabilities->{$name};
        }
    );

    $schema->storage->txn_begin;

    Koha::ILL::Requests->search->delete;

    my $body = {
        ill_backend_id => 'Mock',
        patron_id      => $patron->borrowernumber,
        library_id     => $library->branchcode
    };

    ## Authorized user test
    $t->post_ok( "//$userid:$password@/api/v1/ill/requests" => json => $body )->status_is(201);

    $schema->storage->txn_rollback;
};
