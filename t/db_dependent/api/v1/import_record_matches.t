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

use Test::More tests => 1;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Import::Record::Matches;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'import record matches tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my ( $unauthorized_borrowernumber, $unauthorized_session_id ) =
      create_user_and_session( { authorized => 0 } );
    my ( $authorized_borrowernumber, $authorized_session_id ) =
      create_user_and_session( { authorized => 1 } );

    my $match_1 = $builder->build_object({
        class => 'Koha::Import::Record::Matches',
        value => {
            chosen => 0,
        }
    });
    my $match_2 = $builder->build_object({
        class => 'Koha::Import::Record::Matches',
        value => {
            import_record_id => $match_1->import_record_id,
            chosen => 1,
        }
    });
    my $del_match = $builder->build_object({ class => 'Koha::Import::Record::Matches' });
    my $del_import_batch_id = $del_match->import_record->import_batch_id;
    my $del_match_id = $del_match->import_record_id;

    # Unauthorized attempt to update
    my $tx = $t->ua->build_tx(
      PUT => "/api/v1/import_batches/".$match_1->import_record->import_batch_id."/records/".$match_1->import_record_id."/matches/chosen"=>
      json => {
          candidate_match_id => $match_1->candidate_match_id
      }
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $unauthorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(403);

    # Invalid attempt to allow match on a non-existent record
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/import_batches/".$del_import_batch_id."/records/".$del_match_id."/matches/chosen" =>
      json => {
          candidate_match_id => $match_1->candidate_match_id
      }
    );

    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $del_match->delete();
    $t->request_ok($tx)->status_is(404)
      ->json_is( '/error' => "Match not found" );

    # Valid, authorised update
    $tx = $t->ua->build_tx(
      PUT => "/api/v1/import_batches/".$match_1->import_record->import_batch_id."/records/".$match_1->import_record_id."/matches/chosen" =>
      json => {
          candidate_match_id => $match_1->candidate_match_id
      }
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(200);

    $match_1->discard_changes;
    $match_2->discard_changes;
    ok( $match_1->chosen,"Match 1 is correctly set to chosen");
    ok( !$match_2->chosen,"Match 2 correctly unset when match 1 is set");

    # Valid unsetting
    $tx = $t->ua->build_tx(
      DELETE => "/api/v1/import_batches/".$match_1->import_record->import_batch_id."/records/".$match_1->import_record_id."/matches/chosen" =>
      json => {
      }
    );
    $tx->req->cookies(
        { name => 'CGISESSID', value => $authorized_session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $t->request_ok($tx)->status_is(204);

    $match_1->discard_changes;
    $match_2->discard_changes;
    ok( !$match_1->chosen,"Match 1 is correctly unset to chosen");
    ok( !$match_2->chosen,"Match 2 is correctly unset to chosen");

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => 0
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
        $builder->build({
            source => 'UserPermission',
            value  => {
                borrowernumber => $user->{borrowernumber},
                module_bit     => 13,
                code           => 'manage_staged_marc',
            }
        });
    }

    return ( $user->{borrowernumber}, $session->id );
}

1;
