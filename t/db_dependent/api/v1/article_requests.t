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
use Test::More tests => 3;
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
            value => { flags => 2**1 }    # circulate flag = 1
        }
    );
    my $password = 'thePassword123';
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $authorized_patron->userid;

    my $deleted_article_request    = $builder->build_object( { class => 'Koha::ArticleRequests' } );
    my $deleted_article_request_id = $deleted_article_request->id;
    $deleted_article_request->delete;

    $t->delete_ok("//$userid:$password@/api/v1/article_requests/$deleted_article_request_id")
        ->status_is(404)
        ->json_is( '/error_code' => 'not_found' );

    my $article_request = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { debit_id => undef }
        }
    );

    my $reason = 'A reason';
    my $notes  = 'Some notes';

    $t->delete_ok( "//$userid:$password@/api/v1/article_requests/"
            . $article_request->id
            . "?cancellation_reason=$reason&notes=$notes" )
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( q{}, 'REST3.2.4' );

    # refresh object
    $article_request->discard_changes;

    is(
        $article_request->cancellation_reason,
        $reason, 'Reason stored correctly'
    );
    is( $article_request->notes, $notes, 'Notes stored correctly' );

    $schema->storage->txn_rollback;
};

subtest 'patron_cancel() tests' => sub {

    plan tests => 17;

    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );
    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid    = $patron->userid;
    my $patron_id = $patron->borrowernumber;

    my $deleted_article_request =
        $builder->build_object( { class => 'Koha::ArticleRequests', value => { borrowernumber => $patron_id } } );
    my $deleted_article_request_id = $deleted_article_request->id;
    $deleted_article_request->delete;

    # delete non existent article request
    $t->delete_ok("//$userid:$password@/api/v1/public/patrons/$patron_id/article_requests/$deleted_article_request_id")
        ->status_is(404)
        ->json_is( '/error_code' => 'not_found' );

    my $another_patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $another_patron_id = $another_patron->id;

    my $article_request_2 = $builder->build_object(
        { class => 'Koha::ArticleRequests', value => { borrowernumber => $another_patron_id } } );

    # delete another patron's request when unauthorized
    $t->delete_ok( "/api/v1/public/patrons/$another_patron_id/article_requests/" . $article_request_2->id )
        ->status_is(401)
        ->json_is( '/error' => "Authentication failure." );

    # delete another patron's request
    $t->delete_ok(
        "//$userid:$password@/api/v1/public/patrons/$another_patron_id/article_requests/" . $article_request_2->id )
        ->status_is(403)
        ->json_is( '/error' => "Unprivileged user cannot access another user's resources" );

    my $another_article_request = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { borrowernumber => $another_patron->id }
        }
    );

    $t->delete_ok(
        "//$userid:$password@/api/v1/public/patrons/$patron_id/article_requests/" . $another_article_request->id )
        ->status_is(404)
        ->json_is( '/error_code' => 'not_found' );

    my $article_request = $builder->build_object(
        {
            class => 'Koha::ArticleRequests',
            value => { borrowernumber => $patron->id, debit_id => undef }
        }
    );

    my $reason = 'A reason';
    my $notes  = 'Some notes';

    $t->delete_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/article_requests/"
            . $article_request->id
            . "?cancellation_reason=$reason&notes=$notes" )
        ->status_is( 204, 'REST3.2.4' )
        ->content_is( q{}, 'REST3.2.4' );

    # refresh object
    $article_request->discard_changes;

    is( $article_request->cancellation_reason, $reason, 'Reason stored correctly' );
    is( $article_request->notes,               $notes,  'Notes stored correctly' );

    $schema->storage->txn_rollback;
};
