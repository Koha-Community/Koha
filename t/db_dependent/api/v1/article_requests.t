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

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'cancel() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password(
        { password => $password, skip_validation => 1 } );
    my $userid = $authorized_patron->userid;

    my $deleted_article_requet =
      $builder->build_object( { class => 'Koha::ArticleRequests' } );
    my $deleted_article_requet_id = $deleted_article_requet->id;
    $deleted_article_requet->delete;

    $t->delete_ok(
"//$userid:$password@/api/v1/article_requests/$deleted_article_requet_id"
    )->status_is(404)->json_is( { error => "Article request not found" } );

    my $article_request =
      $builder->build_object( { class => 'Koha::ArticleRequests' } );

    my $reason = 'A reason';
    my $notes  = 'Some notes';

    $t->delete_ok( "//$userid:$password@/api/v1/article_requests/"
          . $article_request->id
          . "?cancellation_reason=$reason&notes=$notes" )
      ->status_is( 204, 'SWAGGER3.2.4' )->content_is( q{}, 'SWAGGER3.2.4' );

    # refresh object
    $article_request->discard_changes;

    is( $article_request->cancellation_reason,
        $reason, 'Reason stored correctly' );
    is( $article_request->notes, $notes, 'Notes stored correctly' );

    $schema->storage->txn_rollback;
};

subtest 'patron_cancel() tests' => sub {

    plan tests => 10;

    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { privacy_guarantor_checkouts => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid    = $patron->userid;
    my $patron_id = $patron->borrowernumber;

    my $deleted_article_requet = $builder->build_object( { class => 'Koha::ArticleRequests' } );
    my $deleted_article_requet_id = $deleted_article_requet->id;
    $deleted_article_requet->delete;

    my $another_patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $another_patron_id = $another_patron->id;

    $t->delete_ok("//$userid:$password@/api/v1/public/patrons/$another_patron_id/article_requests/$deleted_article_requet_id")
      ->status_is(403);

    $t->delete_ok("//$userid:$password@/api/v1/public/patrons/$patron_id/article_requests/$deleted_article_requet_id")
      ->status_is(404)
      ->json_is( { error => "Article request not found" } );

    my $article_request = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { borrowernumber => $patron->id }
        }
    );

    my $reason = 'A reason';
    my $notes  = 'Some notes';

    $t->delete_ok(
        "//$userid:$password@/api/v1/public/patrons/$patron_id/article_requests/"
          . $article_request->id
          . "?cancellation_reason=$reason&notes=$notes" )
      ->status_is( 204, 'SWAGGER3.2.4' )
      ->content_is( q{}, 'SWAGGER3.2.4' );

    # refresh object
    $article_request->discard_changes;

    is( $article_request->cancellation_reason, $reason, 'Reason stored correctly' );
    is( $article_request->notes, $notes, 'Notes stored correctly' );

    $schema->storage->txn_rollback;
};
