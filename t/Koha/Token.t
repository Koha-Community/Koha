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

use Test::More tests => 4;
use Test::NoWarnings;
use Test::Exception;

use MIME::Base64 qw( encode_base64url );
use Mojo::JSON   qw( encode_json );
use Mojo::JWT;

use t::lib::Mocks::Logger;

use Koha::Token;

subtest 'encode_claims() and decode_claims() tests' => sub {

    plan tests => 19;

    my $tokenizer = Koha::Token->new;

    # Simple hashref
    my $claims = { foo => 'bar', count => 42, enabled => 1 };
    my $jwt    = $tokenizer->encode_claims($claims);

    ok( $jwt, 'encode_claims returns a token' );
    like(
        $jwt, qr/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/,
        'Token looks like a JWT (3 dot-separated segments)'
    );

    # Decode and verify
    my $decoded = $tokenizer->decode_claims($jwt);

    is( ref($decoded),       'HASH', 'decode_claims returns a hashref' );
    is( $decoded->{foo},     'bar',  'String claim preserved' );
    is( $decoded->{count},   42,     'Numeric claim preserved' );
    is( $decoded->{enabled}, 1,      'Boolean claim preserved' );

    # Complex nested structure
    my $complex = {
        module      => 'checkin',
        permissions => { exempt_fine => 1, writeoff => 0 },
        list        => [ 'a', 'b', 'c' ],
    };

    my $jwt2     = $tokenizer->encode_claims($complex);
    my $decoded2 = $tokenizer->decode_claims($jwt2);

    is_deeply( $decoded2->{permissions}, { exempt_fine => 1, writeoff => 0 }, 'Nested hashref preserved' );
    is_deeply( $decoded2->{list},        [ 'a', 'b', 'c' ],                   'Array claim preserved' );

    # Invalid input
    throws_ok { $tokenizer->encode_claims(q{not a hashref}) }
    q{Koha::Exceptions::WrongParameter},
        q{encode_claims throws on a non-hashref};

    my $logger = t::lib::Mocks::Logger->new;

    is( $tokenizer->decode_claims(undef), undef, q{undef token returns undef} );
    is( $tokenizer->decode_claims(q{}),   undef, q{empty token returns undef} );
    is( $logger->count,                   0,     q{undefined or empty tokens are not logged} );

    is( $tokenizer->decode_claims(q{garbage}), undef, q{garbage returns undef} );

    # Tampered payload, original signature
    my ( $header, undef, $signature ) = split /\./, $jwt;
    my $forged_payload = encode_base64url( encode_json( { %$claims, count => 1000 } ) );
    is(
        $tokenizer->decode_claims( join( q{.}, $header, $forged_payload, $signature ) ), undef,
        q{tampered payload returns undef}
    );

    # Signed with another key
    my $other_key = Mojo::JWT->new( claims => $claims, secret => q{not the koha secret} )->encode;
    is( $tokenizer->decode_claims($other_key), undef, q{token signed with another key returns undef} );

    # alg:none, with and without a signature
    my $none = Mojo::JWT->new( claims => $claims, algorithm => q{none} )->encode;
    is( $tokenizer->decode_claims($none),                undef, q{alg:none token returns undef} );
    is( $tokenizer->decode_claims( $none . $signature ), undef, q{alg:none token with a signature returns undef} );

    # Expired
    my $expired = $tokenizer->encode_claims( $claims, { expires => time - 5 } );
    is( $tokenizer->decode_claims($expired), undef, q{expired token returns undef} );

    is( $logger->count(q{warn}), 6, q{invalid tokens are logged} );
};

subtest 'generate() tests' => sub {

    plan tests => 2;

    my $tokenizer = Koha::Token->new;

    is( $tokenizer->generate( { type => q{JWT} } ), undef, q{no JWT is generated without an id} );

    my $jwt = $tokenizer->generate( { type => q{JWT}, id => q{some_id} } );
    is( $tokenizer->decode_jwt( { token => $jwt } ), q{some_id}, q{generated JWT carries the id} );
};

subtest 'check_jwt() tests' => sub {

    plan tests => 4;

    my $tokenizer = Koha::Token->new;
    my $logger    = t::lib::Mocks::Logger->new;

    my $jwt = $tokenizer->generate_jwt( { id => q{some_id} } );

    ok( $tokenizer->check_jwt( { id  => q{some_id},  token => $jwt } ), q{matching id is accepted} );
    ok( !$tokenizer->check_jwt( { id => q{other_id}, token => $jwt } ), q{different id is rejected} );

    my $no_id = $tokenizer->encode_claims( { foo => q{bar} } );
    ok( !$tokenizer->check_jwt( { id => q{some_id}, token => $no_id } ), q{token without an id is rejected} );

    my $expired = $tokenizer->generate_jwt( { id => q{some_id}, expires => time - 5 } );
    ok( !$tokenizer->check_jwt( { id => q{some_id}, token => $expired } ), q{expired token is rejected} );
};
