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
use Koha::Libraries;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    # Create test context
    my $library = $builder->build( { source => 'Branch' } );
    my $another_library = { %$library };   # create a copy of $library but make
    delete $another_library->{branchcode}; # sure branchcode will be regenerated
    $another_library = $builder->build(
        { source => 'Branch', value => $another_library } );
    my ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 0 } );

    ## Authorized user tests
    my $count_of_libraries = Koha::Libraries->search->count;
    # Make sure we are returned with the correct amount of libraries
    my $tx = $t->ua->build_tx( GET => '/api/v1/libraries' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_has('/'.($count_of_libraries-1).'/branchcode')
      ->json_hasnt('/'.($count_of_libraries).'/branchcode');

    subtest 'query parameters' => sub {
        my @fields = qw(
        branchname       branchaddress1 branchaddress2 branchaddress3
        branchzip        branchcity     branchstate    branchcountry
        branchphone      branchfax      branchemail    branchreplyto
        branchreturnpath branchurl      issuing        branchip
        branchprinter    branchnotes    opac_info
        );
        plan tests => scalar(@fields)*3;

        foreach my $field (@fields) {
            $tx = $t->ua->build_tx( GET =>
                         "/api/v1/libraries?$field=$library->{$field}" );
            $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
            $tx->req->env( { REMOTE_ADDR => $remote_address } );
            my $result =
            $t->request_ok($tx)
              ->status_is(200)
              ->json_has( [ $library, $another_library ] );
        }
    };

    # Warn on unsupported query parameter
    $tx = $t->ua->build_tx( GET => '/api/v1/libraries?library_blah=blah' );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is( [{ path => '/query/library_blah', message => 'Malformed query string'}] );

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $library = $builder->build( { source => 'Branch' } );
    my ( $borrowernumber, $session_id ) =
      create_user_and_session( { authorized => 0 } );

    my $tx = $t->ua->build_tx( GET => "/api/v1/libraries/" . $library->{branchcode} );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is($library);

    my $non_existent_code = 'non_existent'.int(rand(10000));
    $tx = $t->ua->build_tx( GET => "/api/v1/libraries/" . $non_existent_code );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(404)
      ->json_is( '/error' => 'Library not found' );

    $schema->storage->txn_rollback;
};

subtest 'add() tests' => sub {
    plan tests => 31;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );
    my $library = {
        branchcode       => "LIBRARYBR1",
        branchname       => "Library Name",
        branchaddress1   => "Library Address1",
        branchaddress2   => "Library Address2",
        branchaddress3   => "Library Address3",
        branchzip        => "Library Zipcode",
        branchcity       => "Library City",
        branchstate      => "Library State",
        branchcountry    => "Library Country",
        branchphone      => "Library Phone",
        branchfax        => "Library Fax",
        branchemail      => "Library Email",
        branchreplyto    => "Library Reply-To",
        branchreturnpath => "Library Return-Path",
        branchurl        => "http://library.url",
        issuing          => undef,                  # unused in Koha
        branchip         => "127.0.0.1",
        branchprinter    => "Library Printer",      # unused in Koha
        branchnotes      => "Library Notes",
        opac_info        => "<p>Library OPAC info</p>",
    };

    # Unauthorized attempt to write
    my $tx = $t->ua->build_tx( POST => "/api/v1/libraries" => json => $library );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = { %$library };
    $library_with_invalid_field->{'branchinvalid'} = 'Library invalid';

    $tx = $t->ua->build_tx(
        POST => "/api/v1/libraries" => json => $library_with_invalid_field );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: branchinvalid.",
                path    => "/body"
            }
        ]
    );

    # Authorized attempt to write
    $tx = $t->ua->build_tx( POST => "/api/v1/libraries" => json => $library );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    my $branchcode = $t->request_ok($tx)
      ->status_is(201)
      ->json_is( '/branchname'       => $library->{branchname} )
      ->json_is( '/branchaddress1'   => $library->{branchaddress1} )
      ->json_is( '/branchaddress2'   => $library->{branchaddress2} )
      ->json_is( '/branchaddress3'   => $library->{branchaddress3} )
      ->json_is( '/branchzip'        => $library->{branchzip} )
      ->json_is( '/branchcity'       => $library->{branchcity} )
      ->json_is( '/branchstate'      => $library->{branchstate} )
      ->json_is( '/branchcountry'    => $library->{branchcountry} )
      ->json_is( '/branchphone'      => $library->{branchphone} )
      ->json_is( '/branchfax'        => $library->{branchfax} )
      ->json_is( '/branchemail'      => $library->{branchemail} )
      ->json_is( '/branchreplyto'    => $library->{branchreplyto} )
      ->json_is( '/branchreturnpath' => $library->{branchreturnpath} )
      ->json_is( '/branchurl'        => $library->{branchurl} )
      ->json_is( '/branchip'        => $library->{branchip} )
      ->json_is( '/branchnotes'      => $library->{branchnotes} )
      ->json_is( '/opac_info'        => $library->{opac_info} )
      ->header_is(Location => "/api/v1/libraries/$library->{branchcode}")
      ->tx->res->json->{branchcode};

    # Authorized attempt to create with null id
    $library->{branchcode} = undef;
    $tx = $t->ua->build_tx(
        POST => "/api/v1/libraries" => json => $library );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_has('/errors');

    # Authorized attempt to create with existing id
    $library->{branchcode} = $branchcode;
    $tx = $t->ua->build_tx(
        POST => "/api/v1/libraries" => json => $library );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is('/error' => 'Library already exists');

    $schema->storage->txn_rollback;
};

subtest 'update() tests' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx( PUT => "/api/v1/libraries/$branchcode"
        => json => { branchname => 'New unauthorized name change' } );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    # Attempt partial update on a PUT
    my $library_with_missing_field = {
        branchaddress1 => "New library address",
    };

    $tx = $t->ua->build_tx( PUT => "/api/v1/libraries/$branchcode" =>
                            json => $library_with_missing_field );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_has( "/errors" =>
          [ { message => "Missing property.", path => "/body/branchaddress2" } ]
      );

    # Full object update on PUT
    my $library_with_updated_field = {
        branchcode       => "LIBRARYBR2",
        branchname       => "Library Name",
        branchaddress1   => "Library Address1",
        branchaddress2   => "Library Address2",
        branchaddress3   => "Library Address3",
        branchzip        => "Library Zipcode",
        branchcity       => "Library City",
        branchstate      => "Library State",
        branchcountry    => "Library Country",
        branchphone      => "Library Phone",
        branchfax        => "Library Fax",
        branchemail      => "Library Email",
        branchreplyto    => "Library Reply-To",
        branchreturnpath => "Library Return-Path",
        branchurl        => "http://library.url",
        issuing          => undef,                  # unused in Koha
        branchip         => "127.0.0.1",
        branchprinter    => "Library Printer",      # unused in Koha
        branchnotes      => "Library Notes",
        opac_info        => "<p>Library OPAC info</p>",
    };

    $tx = $t->ua->build_tx(
        PUT => "/api/v1/libraries/$branchcode" => json => $library_with_updated_field );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is( '/branchname' => 'Library Name' );

    # Authorized attempt to write invalid data
    my $library_with_invalid_field = { %$library_with_updated_field };
    $library_with_invalid_field->{'branchinvalid'} = 'Library invalid';

    $tx = $t->ua->build_tx(
        PUT => "/api/v1/libraries/$branchcode" => json => $library_with_invalid_field );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is(
        "/errors" => [
            {
                message => "Properties not allowed: branchinvalid.",
                path    => "/body"
            }
        ]
    );

    my $non_existent_code = 'nope'.int(rand(10000));
    $tx =
      $t->ua->build_tx( PUT => "/api/v1/libraries/$non_existent_code" => json =>
          $library_with_updated_field );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(404);

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};

    # Unauthorized attempt to delete
    my $tx = $t->ua->build_tx( DELETE => "/api/v1/libraries/$branchcode" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx( DELETE => "/api/v1/libraries/$branchcode" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(204)
      ->content_is('');

    $tx = $t->ua->build_tx( DELETE => "/api/v1/libraries/$branchcode" );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)
      ->status_is(404);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

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

    if ( $args->{authorized} ) {
        $dbh->do( "
            INSERT INTO user_permissions (borrowernumber,module_bit,code)
            VALUES (?,3,'parameters_remaining_permissions')", undef,
            $user->{borrowernumber} );
    }

    return ( $user->{borrowernumber}, $session->id );
}

1;
