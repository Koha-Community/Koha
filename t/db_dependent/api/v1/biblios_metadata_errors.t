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

use Test::More tests => 2;
use Test::NoWarnings;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Biblio::Metadata::Error;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'delete() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $password = 'thePassword123';

    my $unauthorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $unauthorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $unauth_userid = $unauthorized_patron->userid;

    my $authorized_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    $authorized_patron->set_password( { password => $password, skip_validation => 1 } );
    my $auth_userid = $authorized_patron->userid;

    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $authorized_patron->borrowernumber,
                module_bit     => 9,
                code           => 'edit_catalogue',
            },
        }
    );

    my $biblio      = $builder->build_sample_biblio;
    my $metadata_id = $biblio->metadata->id;

    my $error = Koha::Biblio::Metadata::Error->new(
        {
            metadata_id => $metadata_id,
            error_type  => 'nonxml_stripped',
            message     => '245$a: invalid char value 31 (U+001F) at position 5',
        }
    )->store;
    my $error_id = $error->id;

    # Unauthenticated
    $t->delete_ok( "/api/v1/biblios/" . $biblio->biblionumber . "/metadata/errors/$error_id" )
        ->status_is( 401, 'Unauthenticated request returns 401' );

    # Unauthorized (no permission)
    $t->delete_ok(
        "//$unauth_userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/metadata/errors/$error_id" )
        ->status_is( 403, 'Missing permission returns 403' );

    # Biblio not found
    $t->delete_ok("//$auth_userid:$password@/api/v1/biblios/0/metadata/errors/$error_id")
        ->status_is( 404, 'Non-existent biblio returns 404' );

    # Error not found (wrong error_id for this biblio)
    my $other_biblio = $builder->build_sample_biblio;
    my $other_error  = Koha::Biblio::Metadata::Error->new(
        {
            metadata_id => $other_biblio->metadata->id,
            error_type  => 'nonxml_stripped',
            message     => '245$a: invalid char value 31 (U+001F) at position 5',
        }
    )->store;

    $t->delete_ok(
        "//$auth_userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/metadata/errors/" . $other_error->id )
        ->status_is( 404, 'Error belonging to a different biblio returns 404' );

    # Successful delete
    $t->delete_ok( "//$auth_userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/metadata/errors/$error_id" )
        ->status_is( 204, 'Authorized delete of existing error returns 204' )
        ->content_is( '', 'No response body on successful delete' );

    # Already deleted / not found
    $t->delete_ok( "//$auth_userid:$password@/api/v1/biblios/" . $biblio->biblionumber . "/metadata/errors/$error_id" )
        ->status_is( 404, 'Deleting an already-deleted error returns 404' );

    $schema->storage->txn_rollback;
};
