
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
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'add() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ($club_with_enrollments, $club_without_enrollments, $item, @enrollments) = create_test_data();

    unauthorized_access_tests('POST', "/api/v1/clubs/".$club_with_enrollments->id."/holds", undef, {
        biblio_id => $item->biblionumber,
        pickup_library_id => $item->home_branch->branchcode
    });

    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {
        plan tests => 8;

        $schema->storage->txn_begin;

        my ($club_with_enrollments, $club_without_enrollments, $item, @enrollments) = create_test_data();

        my ( undef, $session_id ) = create_user_and_session({ authorized => 1 });
        my $data = {
            biblio_id => $item->biblionumber,
            pickup_library_id => $item->home_branch->branchcode
        };
        my $tx = $t->ua->build_tx(POST => "/api/v1/clubs/".$club_without_enrollments->id."/holds" => json => $data);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
            ->status_is(500)
            ->json_is('/error' => "Cannot place a hold on a club without patrons.");

        $tx = $t->ua->build_tx(POST => "/api/v1/clubs/".$club_with_enrollments->id."/holds" => json => $data);
        $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
        $t->request_ok($tx)
          ->status_is(201, 'Created Hold')
          ->json_has('/club_hold_id', 'got a club hold id')
          ->json_is( '/club_id' => $club_with_enrollments->id)
          ->json_is( '/biblio_id'    => $item->biblionumber);

        $schema->storage->txn_rollback;
    };
};

sub unauthorized_access_tests {
    my ($verb, $endpoint, $club_hold_id, $json) = @_;

    $endpoint .= ($club_hold_id) ? "/$club_hold_id" : '';

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
    my $flags = ( $args->{authorized} ) ? 64 : 0;

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

sub create_test_data {
    my $club_with_enrollments = $builder->build_object( { class => 'Koha::Clubs' } );
    my $club_without_enrollments = $builder->build_object( { class => 'Koha::Clubs' } );
    my $enrollment1 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef } } );
    my $enrollment2 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef } } );
    my $enrollment3 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef } } );
    my $enrollment4 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef } } );
    my $enrollment5 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef } } );
    my $enrollment6 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef } } );
    my $item        = $builder->build_sample_item();
    return ( $club_with_enrollments, $club_without_enrollments, $item, [ $enrollment1, $enrollment2, $enrollment3, $enrollment4, $enrollment5, $enrollment6 ] );
}