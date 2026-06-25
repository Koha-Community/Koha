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
use Test::More tests => 5;
use File::Temp qw( tempdir );
use File::Spec;

use Koha::Regex::Replacement;

# Helper: run a real substitution the way the MARC and call-number sinks do,
# using expand_template as the replacement so $1..$n and %+ are populated per
# match.
sub subst {
    my ( $value, $search, $replacement, $modifiers ) = @_;
    $modifiers //= '';
    my $expand = sub { Koha::Regex::Replacement::expand_template( $replacement, [@{^CAPTURE}], {%+} ) };
    if    ( $modifiers eq 'g' ) { $value =~ s/$search/$expand->()/ge }
    elsif ( $modifiers eq 'i' ) { $value =~ s/$search/$expand->()/ie }
    else                        { $value =~ s/$search/$expand->()/e }
    return $value;
}

subtest 'dollar capture-group backreferences' => sub {
    plan tests => 6;
    is( subst( 'foo bar', '(\w+) (\w+)', '$2 $1' ),     'bar foo', '$1 and $2 swap' );
    is( subst( 'foo bar', '(\w+) (\w+)', '${2}-${1}' ), 'bar-foo', '${n} braced form' );
    is( subst( 'abc',     '(a)(b)(c)',   '$3$2$1' ),    'cba',     'three groups reversed' );
    is( subst( 'x',       '(x)',         '[$1]' ),      '[x]',     'backref surrounded by literals' );
    is( subst( 'x',       '(x)',         '$2' ),        '',        'out-of-range group is empty' );
    is(
        subst( 'a1 b2 c3', '(\w)(\d)', '$2$1', 'g' ),
        '1a 2b 3c',
        'captures reset for each match under /g'
    );
};

subtest 'named captures' => sub {
    plan tests => 2;
    is( subst( 'jdoe', '(?<user>\w+)', '$+{user}' ), 'jdoe', '$+{name}' );
    is( subst( 'jdoe', '(?<user>\w+)', '${user}' ),  'jdoe', '${name}' );
};

subtest 'legacy \1 backreferences and fixed escapes' => sub {
    plan tests => 6;

    # The legacy \1 .. \9 form (bug 23873 / call-number usage). This is what the
    # first cut of the expander missed and what Andrew's example relies on.
    is( subst( 'foo bar', '(\w+) (\w+)', '\2 \1' ), 'bar foo', '\1 and \2 swap' );
    is(
        subst( '20260623', '(\d{4})(\d{2})(\d{2})', '\1\-\2\-\3' ),
        '2026-06-23',
        'Andrew example: \1\-\2\-\3 yields a dashed date'
    );
    is(
        subst( '20260623', '(\d{4})(\d{2})(\d{2})', '$1-$2-$3' ),
        '2026-06-23',
        'the $1-$2-$3 form gives the same result'
    );

    is( subst( 'z', '.', 'a\nb' ), "a\nb", '\n becomes a newline' );
    is( subst( 'z', '.', 'a\tb' ), "a\tb", '\t becomes a tab' );
    is( subst( 'x', '(x)', '\$1' ), '$1', '\$ emits a literal dollar, not a backref' );
};

subtest 'malicious replacements are inert (no code execution)' => sub {
    plan tests => 4;

    my $dir = tempdir( CLEANUP => 1 );
    my $a   = File::Spec->catfile( $dir, 'a' );
    my $b   = File::Spec->catfile( $dir, 'b' );
    my $c   = File::Spec->catfile( $dir, 'c' );

    # Run each interpolation-block payload through a real substitution.
    subst( 'Z', '.', qq{\@{[ system("touch $a") ]}}, 'g' );
    subst( 'Z', '.', qq{\${\\ system("touch $b") }}, 'g' );
    subst( 'Z', '.', qq{\@{[ `touch $c` ]}},         'g' );

    ok( !-e $a, 'array interpolation @{[ ... ]} did not run system()' );
    ok( !-e $b, 'scalar interpolation ${\ ... } did not run system()' );
    ok( !-e $c, 'backticks did not run' );

    is(
        Koha::Regex::Replacement::expand_template('@{[ system("id") ]}'),
        '@{[ system("id") ]}',
        'an interpolation block is emitted verbatim as data'
    );
};
