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

use Koha::Token;

subtest 'encode_claims() and decode_claims() tests' => sub {

    plan tests => 8;

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
};
