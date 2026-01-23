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
use Test::More tests => 6;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::ImportBatchProfiles;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();
my $dbh     = C4::Context->dbh;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'unauth access' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Patron without specific flag
    my $patron1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4 }
        }
    );

    # Patron with correct flag, but without specific permission
    my $patron2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4096 }
        }
    );

    my $uid = $patron1->userid;
    my $pwd = $patron1->password;
    $t->get_ok("//$uid:$pwd@/api/v1/import_batch_profiles?_order_by=+name")->status_is(403);

    $uid = $patron1->userid;
    $pwd = $patron1->password;
    $t->get_ok("//$uid:$pwd@/api/v1/import_batch_profiles?_order_by=+name")->status_is(403);

    $schema->storage->txn_rollback;
};

subtest 'list profiles' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    Koha::ImportBatchProfiles->search()->delete;

    my $ibp1 = $builder->build_object( { class => 'Koha::ImportBatchProfiles', value => { name => 'a_ibp' } } );
    my $ibp2 = $builder->build_object( { class => 'Koha::ImportBatchProfiles', value => { name => 'b_ibp' } } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4096 }
        }
    );

    my $sth = $dbh->prepare(
        "INSERT INTO user_permissions (borrowernumber, module_bit, code)
                        SELECT ?, bit, ?
                        FROM userflags
                        WHERE flag = ?"
    );
    $sth->execute( $patron->borrowernumber, 'stage_marc_import', 'tools' );

    my $pwd = 'thePassword123';
    $patron->set_password( { password => $pwd, skip_validation => 1 } );

    my $uid = $patron->userid;

    $t->get_ok("//$uid:$pwd@/api/v1/import_batch_profiles?_order_by=+name")
        ->status_is(200)
        ->json_is( '/0/name', $ibp1->name )
        ->json_is( '/1/name', $ibp2->name );

    $schema->storage->txn_rollback;

};

subtest 'add() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    Koha::ImportBatchProfiles->search()->delete;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4096 }
        }
    );

    my $sth = $dbh->prepare(
        "INSERT INTO user_permissions (borrowernumber, module_bit, code)
                        SELECT ?, bit, ?
                        FROM userflags
                        WHERE flag = ?"
    );
    $sth->execute( $patron->borrowernumber, 'stage_marc_import', 'tools' );

    my $pwd = 'thePassword123';
    $patron->set_password( { password => $pwd, skip_validation => 1 } );

    my $uid       = $patron->userid;
    my $post_data = {
        name           => 'profileName',
        overlay_action => 'overlay_action'
    };

    $t->post_ok( "//$uid:$pwd@/api/v1/import_batch_profiles", json => $post_data )
        ->status_is(201)
        ->json_has('/profile_id')
        ->json_is( '/name',           $post_data->{name} )
        ->json_is( '/overlay_action', $post_data->{overlay_action} )
        ->header_is( 'Location', '/api/v1/import_batch_profiles/' . $t->tx->res->json->{profile_id}, 'REST3.4.1' );

    $schema->storage->txn_rollback;

};

subtest 'edit profile' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    Koha::ImportBatchProfiles->search()->delete;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4096 }
        }
    );

    my $sth = $dbh->prepare(
        "INSERT INTO user_permissions (borrowernumber, module_bit, code)
                        SELECT ?, bit, ?
                        FROM userflags
                        WHERE flag = ?"
    );
    $sth->execute( $patron->borrowernumber, 'stage_marc_import', 'tools' );

    my $pwd = 'thePassword123';
    $patron->set_password( { password => $pwd, skip_validation => 1 } );

    my $uid = $patron->userid;

    my $ibp = $builder->build_object( { class => 'Koha::ImportBatchProfiles', value => { name => 'someProfile' } } );

    my $post_data = { name => 'theProfile' };

    $t->put_ok( "//$uid:$pwd@/api/v1/import_batch_profiles/" . $ibp->id, json => $post_data )
        ->status_is(200)
        ->json_is( '/profile_id', $ibp->id )
        ->json_is( '/name',       $post_data->{name} );

    $ibp->discard_changes;

    is( $ibp->name, $post_data->{name}, 'profile name should be the updated one' );

    $schema->storage->txn_rollback;

};

subtest 'delete profile' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::ImportBatchProfiles->search()->delete;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 4096 }
        }
    );

    my $sth = $dbh->prepare(
        "INSERT INTO user_permissions (borrowernumber, module_bit, code)
                        SELECT ?, bit, ?
                        FROM userflags
                        WHERE flag = ?"
    );
    $sth->execute( $patron->borrowernumber, 'stage_marc_import', 'tools' );

    my $pwd = 'thePassword123';
    $patron->set_password( { password => $pwd, skip_validation => 1 } );

    my $uid = $patron->userid;

    my $ibp = $builder->build_object( { class => 'Koha::ImportBatchProfiles' } );

    $t->delete_ok( "//$uid:$pwd@/api/v1/import_batch_profiles/" . $ibp->id )->status_is(204);

    my $search = Koha::ImportBatchProfiles->find( $ibp->id );

    is( $search, undef, 'profile should be erased' );

    $schema->storage->txn_rollback;

};
