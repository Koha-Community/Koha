
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
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use C4::Context;
use Koha::Database;
use Koha::Holds;
use Koha::Patrons;
use JSON qw( decode_json );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'add() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my ($club_with_enrollments, $club_without_enrollments, $item, @enrollments) = create_test_data();

    unauthorized_access_tests(
        'POST',
        "/api/v1/clubs/" . $club_with_enrollments->id . "/holds",
        undef,
        {
            biblio_id         => $item->biblionumber,
            pickup_library_id => $item->home_branch->branchcode
        }
    );

    $schema->storage->txn_rollback;

    subtest 'librarian access tests' => sub {

        plan tests => 20;

        $schema->storage->txn_begin;

        my ($club_with_enrollments, $club_without_enrollments, $item, @enrollments) = create_test_data();
        my $club_with_enrollments_id = $club_with_enrollments->id;

        my $librarian = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 2 ** 6 }    # reserveforothers flag = 6
            }
        );
        my $password = 'thePassword123';
        $librarian->set_password( { password => $password, skip_validation => 1 } );
        my $userid = $librarian->userid;

        my $non_existent_item   = $builder->build_sample_item;
        my $non_existent_biblio = $non_existent_item->biblio;

        my $non_existent_item_id   = $non_existent_item->id;
        my $non_existent_biblio_id = $non_existent_biblio->id;
        my $non_existent_item_homebranch =
          $non_existent_item->home_branch->branchcode;

        $non_existent_item->delete;
        $non_existent_biblio->delete;

        my $biblio = $builder->build_sample_biblio;

        $t->post_ok(
                "//$userid:$password@/api/v1/clubs/"
              . $club_with_enrollments->id
              . "/holds" => json => {
                biblio_id         => $biblio->id,
                item_id           => $item->id,
                pickup_library_id => $item->home_branch->branchcode
              }
        )->status_is(400)
          ->json_is( '/error' => "Item "
              . $item->id
              . " doesn't belong to biblio "
              . $biblio->id );

        $t->post_ok(
                "//$userid:$password@/api/v1/clubs/"
              . $club_with_enrollments->id
              . "/holds" => json => {
                pickup_library_id => $non_existent_item_homebranch
              }
        )->status_is(400)
          ->json_is(
            '/error' => 'At least one of biblio_id, item_id should be given' );

        $t->post_ok(
                "//$userid:$password@/api/v1/clubs/"
              . $club_with_enrollments->id
              . "/holds" => json => {
                biblio_id         => $non_existent_biblio_id,
                pickup_library_id => $non_existent_item_homebranch
              }
        )->status_is(404)->json_is( '/error' => 'Bibliographic record not found' );

        $t->post_ok(
                "//$userid:$password@/api/v1/clubs/"
              . $club_with_enrollments->id
              . "/holds" => json => {
                item_id           => $non_existent_item_id,
                pickup_library_id => $non_existent_item_homebranch
              }
        )->status_is(404)->json_is( '/error' => 'Item not found' );

        my $data = {
            biblio_id         => $item->biblionumber,
            pickup_library_id => $item->home_branch->branchcode
        };

        $t->post_ok( "//$userid:$password@/api/v1/clubs/"
              . $club_without_enrollments->id
              . "/holds" => json => $data )
          ->status_is(409)
          ->json_is( '/error' => "Cannot place a hold on a club without patrons." );

        $t->post_ok( "//$userid:$password@/api/v1/clubs/"
              . $club_with_enrollments->id
              . "/holds" => json => $data )
          ->status_is( 201, 'Created Hold' )
          ->json_has( '/club_hold_id', 'got a club hold id' )
          ->json_is( '/club_id'   => $club_with_enrollments->id )
          ->json_is( '/biblio_id' => $item->biblionumber );

        $schema->storage->txn_rollback;
    };
};

subtest "default patron home" => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my ($club_with_enrollments, $club_without_enrollments, $item, @enrollments) = create_test_data();
    my $club_with_enrollments_id = $club_with_enrollments->id;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**6 }    # reserveforothers flag = 6
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $data = {
        biblio_id           => $item->biblionumber,
        pickup_library_id   => $item->home_branch->branchcode,
        default_patron_home => 1
    };

    $t->post_ok( "//$userid:$password@/api/v1/clubs/"
          . $club_with_enrollments->id
          . "/holds" => json => $data )
      ->status_is( 201, 'Created Hold' );

    my $json_response = decode_json $t->tx->res->content->get_body_chunk;

    my $sth = $dbh->prepare(
        "select patron_id, hold_id from club_holds_to_patron_holds where club_hold_id = ?"
    );
    $sth->execute($json_response->{club_hold_id});
    while (my $test = $sth->fetchrow_hashref()) {
        my $hold = Koha::Holds->find($test->{hold_id});
        my $patron = Koha::Patrons->find($test->{patron_id});
        is($hold->branchcode, $patron->branchcode, 'Pickup location should be patrons home branch');
    }
    $schema->storage->txn_rollback;
};

sub unauthorized_access_tests {
    my ($verb, $endpoint, $club_hold_id, $json) = @_;

    $endpoint .= ($club_hold_id) ? "/$club_hold_id" : '';

    subtest 'unauthorized access tests' => sub {
        plan tests => 5;

        my $verb_ok = lc($verb) . '_ok';

        $t->$verb_ok($endpoint => json => $json)
          ->status_is(401);

        my $unauthorized_patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { flags => 0 }
            }
        );
        my $password = "thePassword123!";
        $unauthorized_patron->set_password(
            { password => $password, skip_validation => 1 } );
        my $unauth_userid = $unauthorized_patron->userid;

        $t->$verb_ok( "//$unauth_userid:$password\@$endpoint" => json => $json )
          ->status_is(403)
          ->json_has('/required_permissions');
    };
}

sub create_test_data {
    my $club_with_enrollments = $builder->build_object( { class => 'Koha::Clubs' } );
    my $club_without_enrollments = $builder->build_object( { class => 'Koha::Clubs' } );
    my $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib->branchcode}});
    my $enrollment1 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef, borrowernumber => $patron->borrowernumber } } );
    $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    $patron = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib->branchcode}});
    my $enrollment2 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef, borrowernumber => $patron->borrowernumber } } );
    $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    $patron = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib->branchcode}});
    my $enrollment3 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef, borrowernumber => $patron->borrowernumber } } );
    $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    $patron = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib->branchcode}});
    my $enrollment4 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef, borrowernumber => $patron->borrowernumber } } );
    $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    $patron = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib->branchcode}});
    my $enrollment5 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef, borrowernumber => $patron->borrowernumber } } );
    $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    $patron = $builder->build_object({ class => 'Koha::Patrons', value => {branchcode => $lib->branchcode}});
    my $enrollment6 = $builder->build_object( { class => 'Koha::Club::Enrollments', value => { club_id => $club_with_enrollments->id, date_canceled => undef, borrowernumber => $patron->borrowernumber } } );
    $lib = $builder->build_object({ class => 'Koha::Libraries', value => {pickup_location => 1}});
    my $item        = $builder->build_sample_item({homebranch => $lib->branchcode});
    return ( $club_with_enrollments, $club_without_enrollments, $item, [ $enrollment1, $enrollment2, $enrollment3, $enrollment4, $enrollment5, $enrollment6 ] );
}
