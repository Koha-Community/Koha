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
use Test::More tests => 5;
use Test::MockModule;
use Test::Exception;
use Test::Warn;

use t::lib::TestBuilder;

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

    plan tests => 2;

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
