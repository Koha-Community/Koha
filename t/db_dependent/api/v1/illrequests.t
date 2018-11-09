#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 1;
use Test::MockModule;
use Test::MockObject;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Illrequests;
use Koha::DateUtils qw( format_sqldatetime );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 18;

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
    # ill => 22 (userflags.sql)
    my ( $borrowernumber, $session_id ) = create_user_and_session({ authorized => 22 });

    ## Authorized user tests
    # No requests, so empty array should be returned
    my $tx = $t->ua->build_tx( GET => '/api/v1/illrequests' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [] );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );

    # Create an ILL request
    my $illrequest = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                backend        => 'Mock',
                branchcode     => $library->branchcode,
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    # The api response is always augmented with the id_prefix
    my $response = $illrequest->unblessed;
    $response->{id_prefix} = $illrequest->id_prefix;

    my $req_formatted = add_formatted($illrequest);

    # One illrequest created, should get returned
    $tx = $t->ua->build_tx( GET => '/api/v1/illrequests' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)->json_is( [ $req_formatted ] );

    # One illrequest created, returned with augmented data
    $tx = $t->ua->build_tx( GET =>
          '/api/v1/illrequests?embed=patron,library,capabilities,metadata' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)
        ->json_has( '/0/patron', 'patron embedded' )
        ->json_has( '/0/capabilities', 'capabilities embedded' )
        ->json_has( '/0/library', 'library embedded'  )
        ->json_has( '/0/metadata', 'metadata embedded'  );

    # Create another ILL request
    my $illrequest2 = $builder->build_object(
        {
            class => 'Koha::Illrequests',
            value => {
                backend        => 'Mock',
                branchcode     => $library->branchcode,
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    # The api response is always augmented with the id_prefix
    my $response2 = $illrequest2->unblessed;
    $response2->{id_prefix} = $illrequest2->id_prefix;

    my $req2_formatted = add_formatted($illrequest2);

    # Two illrequest created, should get returned
    $tx = $t->ua->build_tx( GET => '/api/v1/illrequests' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200)
      ->json_is( [ $req_formatted, $req2_formatted ] );

    # Warn on unsupported query parameter
    $tx = $t->ua->build_tx( GET => '/api/v1/illrequests?request_blah=blah' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(400)->json_is(
        [{ path => '/query/request_blah', message => 'Malformed query string'}]
    );

    $schema->storage->txn_rollback;
};

sub add_formatted {
    my $req = shift;
    my @format_dates = ( 'placed', 'updated' );
    # We need to embellish the request with properties that the API
    # controller calculates on the fly
    my $req_unblessed = $req->unblessed;
    # Create new "formatted" columns for each date column
    # that needs formatting
    foreach my $field(@format_dates) {
        if (defined $req_unblessed->{$field}) {
            $req_unblessed->{$field . "_formatted"} = format_sqldatetime(
                $req_unblessed->{$field},
                undef,
                undef,
                1
            );
        }
    }
    return $req_unblessed;
}

sub create_user_and_session {

    my $args = shift;
    my $dbh  = C4::Context->dbh;

    my $flags = ( $args->{authorized} ) ? 2**$args->{authorized} : 0;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags
            }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->{borrowernumber} );
    $session->param( 'id',       $user->{userid} );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    return ( $user->{borrowernumber}, $session->id );
}

1;
