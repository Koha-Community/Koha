package C4::ClassSplitRoutine::RegEx;

# Copyright 2018 Koha Development Team
#
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

use Koha::Logger;
use Koha::Regex::Replacement;

=head1 NAME

C4::ClassSplitRoutine::RegEx - regex call number sorting key routine

=head1 SYNOPSIS

use C4::ClassSplitRoutine;

my $cn_sort = C4::ClassSplitRoutine::RegEx::split_callnumber($cn_item, $regexs);

=head1 FUNCTIONS

=head2 split_callnumber

  my $cn_split = C4::ClassSplitRoutine::RegEx::split_callnumber($cn_item, $regexs);

=cut

sub split_callnumber {
    my ($cn_item, $regexs) = @_;

    for my $regex (@$regexs) {
        _apply_substitution( \$cn_item, $regex );
    }
    my @lines = split "\n", $cn_item;

    return @lines;
}

=head2 _apply_substitution

  _apply_substitution( \$string, $regex );

Applies a single admin-configured s/// substitution to $string in place,
without ever evaluating the input as code. The rule is parsed as
s<DELIM>PATTERN<DELIM>REPLACEMENT<DELIM>FLAGS; the pattern is compiled with
qr// (so embedded-code assertions are treated as a runtime pattern and blocked
by Perl), and the replacement is expanded as data via
Koha::Regex::Replacement::expand_template. The
/e flag is rejected and anything that is not a plain substitution is ignored.
This replaces the previous C<eval "\$cn_item =~ $regex"> stringy eval, which
executed arbitrary Perl.

=cut

sub _apply_substitution {
    my ( $ref, $regex ) = @_;

    return unless defined $regex;

    # Parse  s<DELIM>PATTERN<DELIM>REPLACEMENT<DELIM>FLAGS, allowing any
    # non-space delimiter and backslash-escaped delimiters inside the pattern
    # and replacement. Anything that is not a well-formed plain substitution is
    # ignored rather than executed.
    return unless $regex =~ m{^s(\S)((?:\\.|(?!\1).)*)\1((?:\\.|(?!\1).)*)\1([a-z]*)\z}s;
    my ( $pattern, $replacement, $flags ) = ( $2, $3, $4 );

    return if $flags =~ /e/;    # never evaluate the replacement as code
    my $global = $flags =~ /g/ ? 1      : 0;
    my $ci     = $flags =~ /i/ ? '(?i)' : '';

    my $compiled = eval { qr/$ci$pattern/ };
    unless ( defined $compiled ) {
        Koha::Logger->get->warn("C4::ClassSplitRoutine::RegEx: failed to compile pattern [$pattern]: $@");
        return;
    }

    my $expand = sub { Koha::Regex::Replacement::expand_template( $replacement, [ @{^CAPTURE} ], {%+} ) };

    if ($global) {
        ${$ref} =~ s/$compiled/$expand->()/ge;
    } else {
        ${$ref} =~ s/$compiled/$expand->()/e;
    }

    return;
}

1;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
