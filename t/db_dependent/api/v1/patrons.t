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

use Test::More tests => 5;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Database;
use Koha::Patron::Debarments qw/AddDebarment/;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('GET', undef, undef);
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 13;

        $schema->storage->txn_begin;

        Koha::Patrons->search->delete;

        my ( $patron_id, $session_id ) = create_user_and_session({ authorized => 1 });
        my $patron = Koha::Patrons->find($patron_id);

        my $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
        $t->request_ok($tx)
          ->status_is(200);

        $tx = $t->ua->build_tx(GET => '/api/v1/patrons?cardnumber=' . $patron->cardnumber);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/0/cardnumber' => $patron->cardnumber);

        $tx = $t->ua->build_tx(GET => '/api/v1/patrons?address2='.
                                  $patron->address2);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/0/address2' => $patron->address2);

        my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
        AddDebarment({ borrowernumber => $patron_2->id });
        # re-read from DB
        $patron_2->discard_changes;
        my $ub = $patron_2->unblessed;

        $tx = $t->ua->build_tx( GET => '/api/v1/patrons?restricted=' . Mojo::JSON->true );
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
        $t->request_ok($tx)
          ->status_is(200)
          ->json_has('/0/restricted')
          ->json_is( '/0/restricted' => Mojo::JSON->true )
          ->json_hasnt('/1');

        $schema->storage->txn_rollback;
    };
};

subtest 'get() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    unauthorized_access_tests('GET', -1, undef);
    $schema->storage->txn_rollback;

    subtest 'access own object tests' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        my ( $patron_id, $session_id ) = create_user_and_session({ authorized => 0 });

        # Access patron's own data even though they have no borrowers flag
        my $tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $patron_id);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
        $t->request_ok($tx)
          ->status_is(200);

        my $guarantee = $builder->build_object({
            class => 'Koha::Patrons',
            value => {
                guarantorid => $patron_id,
            }
        });

        # Access guarantee's data even though guarantor has no borrowers flag
        $tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $guarantee->id );
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
        $t->request_ok($tx)
          ->status_is(200);

        $schema->storage->txn_rollback;
    };

    subtest 'librarian access tests' => sub {
        plan tests => 6;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my ( undef, $session_id ) = create_user_and_session({ authorized => 1 });

        my $tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $patron->id);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(200)
          ->json_is('/patron_id'        => $patron->id)
          ->json_is('/category_id'      => $patron->categorycode )
          ->json_is('/surname'          => $patron->surname)
          ->json_is('/patron_card_lost' => Mojo::JSON->false );

        $schema->storage->txn_rollback;
    };
};

subtest 'add() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = Koha::REST::V1::Patrons::_to_api(
        $builder->build_object( { class => 'Koha::Patrons' } )->TO_JSON );

    unauthorized_access_tests('POST', undef, $patron);

    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 20;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my $newpatron = Koha::REST::V1::Patrons::_to_api( $patron->TO_JSON );
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};

        # Create a library just to make sure its ID doesn't exist on the DB
        my $library_to_delete = $builder->build_object({ class => 'Koha::Libraries' });
        my $deleted_library_id = $library_to_delete->id;
        # Delete library
        $library_to_delete->delete;

        my ( undef, $session_id ) = create_user_and_session({ authorized => 1 });

        $newpatron->{library_id} = $deleted_library_id;
        my $tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron );
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        warning_like {
            $t->request_ok($tx)
              ->status_is(409)
              ->json_is('/error' => "Duplicate ID"); }
            qr/^DBD::mysql::st execute failed: Duplicate entry/;

        $newpatron->{library_id} = $patron->branchcode;

        # Create a library just to make sure its ID doesn't exist on the DB
        my $category_to_delete = $builder->build_object({ class => 'Koha::Patron::Categories' });
        my $deleted_category_id = $category_to_delete->id;
        # Delete library
        $category_to_delete->delete;

        $newpatron->{category_id} = $deleted_category_id; # Test invalid patron category
        $tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(400)
          ->json_is('/error' => "Given category_id does not exist");
        $newpatron->{category_id} = $patron->categorycode;

        $newpatron->{falseproperty} = "Non existent property";
        $tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(400);
        delete $newpatron->{falseproperty};

        my $patron_to_delete = $builder->build_object({ class => 'Koha::Patrons' });
        $newpatron = Koha::REST::V1::Patrons::_to_api($patron_to_delete->TO_JSON);
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};
        $patron_to_delete->delete;

        $tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(201, 'Patron created successfully')
          ->json_has('/patron_id', 'got a patron_id')
          ->json_is( '/cardnumber' => $newpatron->{ cardnumber })
          ->json_is( '/surname'    => $newpatron->{ surname })
          ->json_is( '/firstname'  => $newpatron->{ firstname });

        $tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        warning_like {
            $t->request_ok($tx)
              ->status_is(409)
              ->json_has( '/error', 'Fails when trying to POST duplicate cardnumber' )
              ->json_has( '/conflict', 'cardnumber' ); }
            qr/^DBD::mysql::st execute failed: Duplicate entry '(.*?)' for key 'cardnumber'/;

        $schema->storage->txn_rollback;
    };
};

subtest 'update() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('PUT', 123, {email => 'nobody@example.com'});
    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 22;

        $schema->storage->txn_begin;

        t::lib::Mocks::mock_preference('minPasswordLength', 1);
        my ( $patron_id_1, $session_id ) = create_user_and_session({ authorized => 1 });
        my ( $patron_id_2, undef )       = create_user_and_session({ authorized => 0 });

        my $patron_1  = Koha::Patrons->find($patron_id_1);
        my $patron_2  = Koha::Patrons->find($patron_id_2);
        my $newpatron = Koha::REST::V1::Patrons::_to_api($patron_2->TO_JSON);
        # delete RO attributes
        delete $newpatron->{patron_id};
        delete $newpatron->{restricted};

        my $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/-1" => json => $newpatron );
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        $t->request_ok($tx)
          ->status_is(404)
          ->json_has('/error', 'Fails when trying to PUT nonexistent patron');

        # Create a library just to make sure its ID doesn't exist on the DB
        my $category_to_delete = $builder->build_object({ class => 'Koha::Patron::Categories' });
        my $deleted_category_id = $category_to_delete->id;
        # Delete library
        $category_to_delete->delete;

        $newpatron->{category_id} = $deleted_category_id;
        $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/$patron_id_2" => json => $newpatron );
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        $t->request_ok($tx)
          ->status_is(400)
          ->json_is('/error' => "Given category_id does not exist");
        $newpatron->{category_id} = $patron_2->categorycode;

        # Create a library just to make sure its ID doesn't exist on the DB
        my $library_to_delete = $builder->build_object({ class => 'Koha::Libraries' });
        my $deleted_library_id = $library_to_delete->id;
        # Delete library
        $library_to_delete->delete;

        $newpatron->{library_id} = $deleted_library_id;
        $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $patron_2->id => json => $newpatron );
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        warning_like {
            $t->request_ok($tx)
              ->status_is(400)
              ->json_is('/error' => "Given library_id does not exist"); }
            qr/^DBD::mysql::st execute failed: Cannot add or update a child row: a foreign key constraint fails/;
        $newpatron->{library_id} = $patron_2->branchcode;

        $newpatron->{falseproperty} = "Non existent property";
        $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $patron_2->id => json => $newpatron );
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        $t->request_ok($tx)
          ->status_is(400)
          ->json_is('/errors/0/message' =>
                    'Properties not allowed: falseproperty.');
        delete $newpatron->{falseproperty};

        # Set both cardnumber and userid to already existing values
        $newpatron->{cardnumber} = $patron_1->cardnumber;
        $newpatron->{userid}     = $patron_1->userid;

        $tx = $t->ua->build_tx( PUT => "/api/v1/patrons/" . $patron_2->id => json => $newpatron );
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        warning_like {
            $t->request_ok($tx)
              ->status_is(409)
              ->json_has( '/error' => "Fails when trying to update to an existing cardnumber or userid")
              ->json_is(  '/conflict', 'cardnumber' ); }
            qr/^DBD::mysql::st execute failed: Duplicate entry '(.*?)' for key 'cardnumber'/;

        $newpatron->{ cardnumber } = $patron_id_1.$patron_id_2;
        $newpatron->{ userid }     = "user".$patron_id_1.$patron_id_2;
        $newpatron->{ surname }    = "user".$patron_id_1.$patron_id_2;

        $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $patron_2->id => json => $newpatron);
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        $t->request_ok($tx)
          ->status_is(200, 'Patron updated successfully')
          ->json_has($newpatron);
        is(Koha::Patrons->find( $patron_2->id )->cardnumber,
           $newpatron->{ cardnumber }, 'Patron is really updated!');

        $schema->storage->txn_rollback;
    };
};

subtest 'delete() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    unauthorized_access_tests('DELETE', 123, undef);
    $schema->storage->txn_rollback;

    subtest 'librarian access test' => sub {
        plan tests => 4;

        $schema->storage->txn_begin;

        my ( undef, $session_id ) = create_user_and_session({ authorized => 1 });
        my ( $patron_id, undef )  = create_user_and_session({ authorized => 0 });

        my $tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/-1");
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(404, 'Patron not found');

        $tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/$patron_id");
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(200, 'Patron deleted successfully');

        $schema->storage->txn_rollback;
    };
};

# Centralized tests for 401s and 403s assuming the endpoint requires
# borrowers flag for access
sub unauthorized_access_tests {
    my ($verb, $patron_id, $json) = @_;

    my $endpoint = '/api/v1/patrons';
    $endpoint .= ($patron_id) ? "/$patron_id" : '';

    subtest 'unauthorized access tests' => sub {
        plan tests => 5;

        my $tx = $t->ua->build_tx($verb => $endpoint => json => $json);
        $t->request_ok($tx)
          ->status_is(401);

        my ($borrowernumber, $session_id) = create_user_and_session({
            authorized => 0 });

        $tx = $t->ua->build_tx($verb => $endpoint => json => $json);
        $tx->req->cookies({name => 'CGISESSID', value => $session_id});
        $t->request_ok($tx)
          ->status_is(403)
          ->json_has('/required_permissions');
    };
}

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 16 : 0;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags,
                gonenoaddress => 0,
                lost => 0,
                email => 'nobody@example.com',
                emailpro => 'nobody@example.com',
                B_email => 'nobody@example.com'
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
