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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;

use C4::ClassSplitRoutine::RegEx;

# Exercise _apply_substitution through the public split_callnumber interface.
# split_callnumber($string, \@regexes) applies each regex in turn and splits
# on newlines; a single-rule list with no \n in the result returns a
# one-element list.
sub apply {
    my ( $string, $regex ) = @_;
    my @parts = C4::ClassSplitRoutine::RegEx::split_callnumber( $string, [$regex] );
    return $parts[0] // $string;
}

subtest 'basic substitution' => sub {
    plan tests => 3;
    is( apply( 'foo', 's/foo/bar/' ),  'bar', 'simple replacement' );
    is( apply( 'foo', 's/foo/bar/g' ), 'bar', '/g flag' );
    is( apply( 'FOO', 's/foo/bar/i' ), 'bar', '/i flag' );
};

subtest 'alternate delimiters' => sub {
    plan tests => 3;
    is( apply( 'foo', 's#foo#bar#' ), 'bar', 'hash delimiter' );
    is( apply( 'foo', 's|foo|bar|' ), 'bar', 'pipe delimiter' );
    is( apply( 'foo', 's!foo!bar!' ), 'bar', 'bang delimiter' );
};

subtest 'backreference and flag combinations' => sub {
    plan tests => 3;
    is( apply( '20260623', 's/(\d{4})(\d{2})(\d{2})/$1-$2-$3/' ), '2026-06-23', '$n backrefs' );
    is( apply( '20260623', 's/(\d{4})(\d{2})(\d{2})/\1-\2-\3/' ), '2026-06-23', '\n backrefs' );
    is( apply( 'FOO foo',  's/foo/bar/gi' ),                      'bar bar',    '/gi combined' );
};

subtest '/e flag is rejected (no code execution)' => sub {
    plan tests => 3;
    is( apply( 'foo', 's/foo/1+1/e' ),   'foo', '/e alone: string unchanged' );
    is( apply( 'foo', 's/foo/1+1/ge' ),  'foo', '/ge: string unchanged' );
    is( apply( 'foo', 's/foo/1+1/ige' ), 'foo', '/ige: string unchanged' );
};

subtest 'malformed and uncompilable rules are silently ignored' => sub {
    plan tests => 3;

    # Not an s/// at all — ignored
    is( apply( 'foo', 'm/foo/' ), 'foo', 'non-substitution regex ignored' );

    # Missing closing delimiter
    is( apply( 'foo', 's/foo/bar' ), 'foo', 'truncated s/// ignored' );

    # Invalid pattern — compilation fails (also exercises the logger warn path)
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, @_ };
    is( apply( 'foo', 's/[invalid/bar/' ), 'foo', 'bad pattern ignored' );
};
