#!/usr/bin/perl

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
use Test::More tests => 7;
use Test::MockModule;
use Test::Exception;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('Koha::ApiKeys');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0;

    Koha::ApiKeys->search->delete;

    my $patron_1    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $description = 'Coral API key';

    my $api_key = Koha::ApiKey->new(
        {
            patron_id   => $patron_1->id,
            description => $description
        }
    )->store;

    # re-read from DB
    $api_key->discard_changes;

    is( ref($api_key), 'Koha::ApiKey' );
    is( $api_key->patron_id, $patron_1->id, 'FK is matched' );
    ok(
               defined $api_key->client_id
            && $api_key->client_id ne ''
            && length( $api_key->client_id ) > 1,
        'API client_id is generated'
    );
    ok(
               defined $api_key->secret
            && $api_key->secret ne ''
            && length( $api_key->secret ) > 1,
        'API secret is generated'
    );
    is( $api_key->description, $description, 'Description is correctly stored' );
    is( $api_key->active,      1,            'Key is active by default' );

    # revoke, to call store
    my $original_api_key = $api_key->unblessed;
    $api_key->active(0)->store;
    $api_key->discard_changes;

    is( $api_key->client_id, $original_api_key->{client_id}, '->store() preserves the client_id' );
    is( $api_key->secret,    $original_api_key->{secret},    '->store() preserves the secret' );
    is( $api_key->patron_id, $original_api_key->{patron_id}, '->store() preserves the patron_id' );
    is( $api_key->active,    0,                              '->store() preserves the active value' );

    $api_key->set( { client_id => 'NewID!' } );

    throws_ok {
        $api_key->store
    }
    'Koha::Exceptions::Object::ReadOnlyProperty',
        'Read-only attribute overwrite attempt raises exception';

    is( $@->property, 'client_id', 'Correct attribute reported back' );

    $api_key->discard_changes;

    # set a writeable attribute
    $api_key->set( { description => 'Hey' } );
    lives_ok { $api_key->store } 'Updating a writeable attribute works';

    my $patron_to_delete = $builder->build_object( { class => 'Koha::Patrons' } );
    my $deleted_id       = $patron_to_delete->id;
    $patron_to_delete->delete;

    warning_like(
        sub {
            throws_ok {
                Koha::ApiKey->new( { patron_id => $deleted_id, description => 'a description' } )->store
            }
            'Koha::Exceptions::Object::FKConstraint',
                'Invalid patron ID raises exception';
        },
        qr{a foreign key constraint fails}
    );
    is( $@->message,   'Broken FK constraint', 'Exception message is correct' );
    is( $@->broken_fk, 'patron_id',            'Exception field is correct' );

    $schema->storage->txn_rollback;
};

subtest 'validate_secret() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $api_key = Koha::ApiKey->new(
        {
            patron_id   => $patron->id,
            description => 'The description'
        }
    )->store;

    my $secret = $api_key->plain_text_secret;

    is( $api_key->validate_secret($secret),        1, 'Valid secret returns true' );
    is( $api_key->validate_secret('Wrong secret'), 0, 'Invalid secret returns false' );

    # Test CREATE logging when ApiKeyLog is enabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 1 );
    my $test_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'CREATE' } )->count;
    my $logged_key  = Koha::ApiKey->new( { description => 'logged', patron_id => $test_patron->id } )->store;
    my $logs_after  = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'CREATE' } )->count;
    is( $logs_after, $logs_before + 1, 'CREATE action logged when ApiKeyLog enabled' );

    # Verify log entry parameters
    my $log_entry = $schema->resultset('ActionLog')->search(
        { module   => 'APIKEYS', action => 'CREATE', object => $test_patron->id },
        { order_by => { -desc => 'action_id' } }
    )->first;
    ok( $log_entry, 'CREATE log entry found' );
    is( $log_entry->object, $test_patron->id, 'Log object is patron_id' );
    like( $log_entry->info, qr/logged/, 'Log info contains description' );

    # Test no CREATE logging when ApiKeyLog is disabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 0 );
    $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'CREATE' } )->count;
    my $unlogged_key = Koha::ApiKey->new( { description => 'unlogged', patron_id => $test_patron->id } )->store;
    $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'CREATE' } )->count;
    is( $logs_after, $logs_before, 'CREATE action not logged when ApiKeyLog disabled' );

    # Test DELETE logging when ApiKeyLog is enabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 1 );
    $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'DELETE' } )->count;
    my $client_id_to_delete = $logged_key->client_id;
    $logged_key->delete;
    $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'DELETE' } )->count;
    is( $logs_after, $logs_before + 1, 'DELETE action logged when ApiKeyLog enabled' );

    # Verify DELETE log entry parameters
    my $delete_log = $schema->resultset('ActionLog')->search(
        { module   => 'APIKEYS', action => 'DELETE', object => $test_patron->id },
        { order_by => { -desc => 'action_id' } }
    )->first;
    ok( $delete_log, 'DELETE log entry found' );
    is( $delete_log->object, $test_patron->id, 'DELETE log object is patron_id' );

    # DELETE logs pass undef for info field, object is in diff field
    is( $delete_log->info, undef, 'DELETE log info is undef as expected' );

    # Test no DELETE logging when ApiKeyLog is disabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 0 );
    $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'DELETE' } )->count;
    $unlogged_key->delete;
    $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'DELETE' } )->count;
    is( $logs_after, $logs_before, 'DELETE action not logged when ApiKeyLog disabled' );

    $schema->storage->txn_rollback;
};

subtest 'plain_text_secret() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    # generate a fresh API key
    my $api_key           = Koha::ApiKey->new( { description => 'blah', patron_id => $patron->id } )->store;
    my $plain_text_secret = $api_key->plain_text_secret;

    ok( defined $plain_text_secret, 'A fresh API key carries its plain text secret' );
    ok( $plain_text_secret ne q{},  'Plain text secret is not an empty string' );

    $schema->storage->txn_rollback;
};

subtest 'revoke() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $api_key = Koha::ApiKey->new( { description => 'test', patron_id => $patron->id } )->store;

    # Test successful revoke
    is( $api_key->active, 1, 'API key starts as active' );
    $api_key->revoke;
    is( $api_key->active, 0, 'API key is revoked' );

    # Test exception when already revoked
    throws_ok { $api_key->revoke } 'Koha::Exceptions::ApiKey::AlreadyRevoked',
        'Exception thrown when trying to revoke already revoked key';

    # Test logging when ApiKeyLog is enabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 1 );
    my $api_key2 = Koha::ApiKey->new( { description => 'test2', patron_id => $patron->id } )->store;

    my $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'REVOKE' } )->count;
    my $client_id_to_revoke = $api_key2->client_id;
    $api_key2->revoke;
    my $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'REVOKE' } )->count;
    is( $logs_after, $logs_before + 1, 'REVOKE action logged when ApiKeyLog enabled' );

    # Verify REVOKE log entry parameters
    my $revoke_log = $schema->resultset('ActionLog')->search(
        { module   => 'APIKEYS', action => 'REVOKE', object => $patron->id },
        { order_by => { -desc => 'action_id' } }
    )->first;
    ok( $revoke_log, 'REVOKE log entry found' );
    is( $revoke_log->object, $patron->id, 'REVOKE log object is patron_id' );
    like(
        $revoke_log->info, qr/$client_id_to_revoke.*test2/s,
        'REVOKE log info contains client_id and description'
    );

    # Test no logging when ApiKeyLog is disabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 0 );
    my $api_key3 = Koha::ApiKey->new( { description => 'test3', patron_id => $patron->id } )->store;

    $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'REVOKE' } )->count;
    $api_key3->revoke;
    $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'REVOKE' } )->count;
    is( $logs_after, $logs_before, 'REVOKE action not logged when ApiKeyLog disabled' );

    $schema->storage->txn_rollback;
};

subtest 'activate() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $api_key = Koha::ApiKey->new( { description => 'test', patron_id => $patron->id } )->store;
    $api_key->active(0)->store;    # Start as revoked

    # Test successful activate
    is( $api_key->active, 0, 'API key starts as revoked' );
    $api_key->activate;
    is( $api_key->active, 1, 'API key is activated' );

    # Test exception when already active
    throws_ok { $api_key->activate } 'Koha::Exceptions::ApiKey::AlreadyActive',
        'Exception thrown when trying to activate already active key';

    # Test logging when ApiKeyLog is enabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 1 );
    my $api_key2 = Koha::ApiKey->new( { description => 'test2', patron_id => $patron->id } )->store;
    $api_key2->active(0)->store( { skip_log => 1 } );    # Start as revoked

    my $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'ACTIVATE' } )->count;
    my $client_id_to_activate = $api_key2->client_id;
    $api_key2->activate;
    my $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'ACTIVATE' } )->count;
    is( $logs_after, $logs_before + 1, 'ACTIVATE action logged when ApiKeyLog enabled' );

    # Verify ACTIVATE log entry parameters
    my $activate_log = $schema->resultset('ActionLog')->search(
        { module   => 'APIKEYS', action => 'ACTIVATE', object => $patron->id },
        { order_by => { -desc => 'action_id' } }
    )->first;
    ok( $activate_log, 'ACTIVATE log entry found' );
    is( $activate_log->object, $patron->id, 'ACTIVATE log object is patron_id' );
    like(
        $activate_log->info, qr/$client_id_to_activate.*test2/s,
        'ACTIVATE log info contains client_id and description'
    );

    # Test no logging when ApiKeyLog is disabled
    t::lib::Mocks::mock_preference( 'ApiKeyLog', 0 );
    my $api_key3 = Koha::ApiKey->new( { description => 'test3', patron_id => $patron->id } )->store;
    $api_key3->active(0)->store( { skip_log => 1 } );    # Start as revoked

    $logs_before = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'ACTIVATE' } )->count;
    $api_key3->activate;
    $logs_after = $schema->resultset('ActionLog')->search( { module => 'APIKEYS', action => 'ACTIVATE' } )->count;
    is( $logs_after, $logs_before, 'ACTIVATE action not logged when ApiKeyLog disabled' );

    $schema->storage->txn_rollback;
};
