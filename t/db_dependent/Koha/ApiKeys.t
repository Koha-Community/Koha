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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::MockModule;
use Test::Exception;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::ApiKeys');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $uuid_gen_client_id_counter = 0;
my $uuid_gen_secret_counter    = 0;

subtest 'store() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0;

    Koha::ApiKeys->search->delete;

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $description = 'Coral API key';
    my $api_key = Koha::ApiKey->new({ patron_id => $patron_1->id, description => $description })->store;

    # re-read from DB
    $api_key->discard_changes;

    is( ref($api_key), 'Koha::ApiKey' );
    is( $api_key->patron_id, $patron_1->id, 'FK is matched' );
    ok( defined $api_key->client_id
            && $api_key->client_id ne ''
            && length( $api_key->client_id ) > 1,
        'API client_id is generated'
    );
    ok( defined $api_key->secret
            && $api_key->secret ne ''
            && length( $api_key->secret ) > 1,
        'API secret is generated' );
    is( $api_key->description, $description, 'Description is correctly stored' );
    is( $api_key->active,      1,            'Key is active by default' );

    my $patron_to_delete = $builder->build_object( { class => 'Koha::Patrons' } );
    my $deleted_id = $patron_to_delete->id;
    $patron_to_delete->delete;

    throws_ok
        { Koha::ApiKey->new({ patron_id => $deleted_id })->store }
        'Koha::Exceptions::Object::FKConstraint',
        'Invalid patron ID raises exception';
    is( $@->message,   'Broken FK constraint', 'Exception message is correct' );
    is( $@->broken_fk, 'patron_id',            'Exception field is correct' );

    $schema->storage->txn_rollback;
};
