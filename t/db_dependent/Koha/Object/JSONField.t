#!/usr/bin/perl

# Copyright 2022 Koha Development team
#
# This file is part of Koha
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

use utf8;

use Test::More tests => 1;
use Test::Exception;

use Koha::Auth::Identity::Providers;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'decode_json_field() and set_encoded_json_field() tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $idp = $builder->build_object( { class => 'Koha::Auth::Identity::Providers' } );

    my $data = { some => 'data' };

    $idp->set_encoded_json_field( { data => $data, field => 'config' } );

    is_deeply( $idp->_json->decode( $idp->config ),              $data, 'decode what we sent' );
    is_deeply( $idp->decode_json_field( { field => 'config' } ), $data, 'check with decode_json_field' );

    # Let's get some Unicode stuff into the game
    $data = { favorite_Chinese => [ '葑', '癱' ], latin_dancing => [ '¢', '¥', 'á', 'û' ] };
    $idp->set_encoded_json_field( { data => $data, field => 'config' } )->store;

    $idp->discard_changes;    # refresh
    is_deeply( $idp->decode_json_field( { field => 'config' } ), $data, 'Deep compare with Unicode data' );

    # To convince you even more
    is(
        ord( $idp->decode_json_field( { field => 'config' } )->{favorite_Chinese}->[0] ), 33873,
        'We still found Unicode \x8451'
    );
    is(
        ord( $idp->decode_json_field( { field => 'config' } )->{latin_dancing}->[0] ), 162,
        'We still found the equivalent of Unicode \x00A2'
    );

    # Testing with sending encoded data (which we normally shouldn't do)
    my $utf8_data;
    foreach my $k ( 'favorite_Chinese', 'latin_dancing' ) {
        foreach my $c ( @{ $data->{$k} } ) {
            push @{ $utf8_data->{$k} }, Encode::encode( 'UTF-8', $c );
        }
    }
    $idp->set_encoded_json_field( { data => $utf8_data, field => 'config' } )->store;
    $idp->discard_changes;    # refresh
    is_deeply( $idp->decode_json_field( { field => 'config' } ), $utf8_data, 'Deep compare with utf8_data' );

    # Need more evidence?
    is(
        ord( $idp->decode_json_field( { field => 'config' } )->{favorite_Chinese}->[0] ), 232,
        'We still found a UTF8 encoded byte'
    );                        # ord does not need substr here

    # pathological use cases

    throws_ok { $idp->set_encoded_json_field( { data => $data } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown on missing parameter';
    is( $@->parameter, 'field', 'Correct parameter reported (field)' );

    throws_ok { $idp->set_encoded_json_field( { data => $data, field => undef } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown on missing parameter';
    is( $@->parameter, 'field', 'Correct parameter reported (field)' );

    throws_ok { $idp->set_encoded_json_field( { field => 'something' } ); }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown on missing parameter';
    is( $@->parameter, 'data', 'Correct parameter reported (data)' );

    $idp->set_encoded_json_field( { data => undef, field => 'config' } );
    is( $idp->config, undef, 'undef is undef' );

    # set invalid data
    $idp->config('{');
    throws_ok { $idp->decode_json_field( { field => 'config' } ) }
    'Koha::Exceptions::Object::BadValue',
        'Exception thrown';
    like( "$@", qr/Error reading JSON data/ );

    $schema->storage->txn_rollback;
};
