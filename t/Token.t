#!/usr/bin/perl

# tests for Koha::Token

# Copyright 2016 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Test::More tests => 6;
use Koha::Token;

my $tokenizer = Koha::Token->new;
is( length( $tokenizer->generate ), 1, "Generate without parameters" );
my $token = $tokenizer->generate({ length => 20 });
is( length($token), 20, "Token $token has 20 chars" );

my $id = $tokenizer->generate({ length => 8 });
my $secr = $tokenizer->generate({ length => 32 });
my $csrftoken = $tokenizer->generate({ CSRF => 1, id => $id, secret => $secr });
isnt( length($csrftoken), 0, "Token $csrftoken should not be empty" );

is( $tokenizer->check, undef, "Check without any parameters" );
my $result = $tokenizer->check({
    CSRF => 1, id => $id, secret => $secr, token => $csrftoken,
});
is( $result, 1, "CSRF token verified" );

$result = $tokenizer->check({
    CSRF => 1, id => $id, secret => $secr, token => $token,
});
isnt( $result, 1, "This token is no CSRF token" );
