package C4::ClassSplitRoutine::Dewey;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

=head1 NAME

C4::ClassSplitRoutine::Dewey - Dewey call number split method

=head1 SYNOPSIS

use C4::ClassSplitRoutine;

my $cn_split = C4::ClassSplitRoutine::Dewey::split_callnumber($cn_item);

=head1 FUNCTIONS

=head2 split_callnumber

  my $cn_split = C4::ClassSplitRoutine::Dewey::split_callnumber($cn_item);

=cut

sub split_callnumber {
    my ($cn_item) = @_;

    my $possible_decimal = qr/\d{3,}(?:\.\d+)?/;    # at least three digits for a DDCN

    $cn_item =~ s/\///g
        ; # in theory we should be able to simply remove all segmentation markers and arrive at the correct call number...
    my (@lines) = $cn_item =~ m/
        ^([-a-zA-Z]*\s?(?:$possible_decimal)?) # R220.3  CD-ROM 787.87 # will require extra splitting
        \s+
        (.+)                               # H2793Z H32 c.2 EAS # everything else (except bracketing spaces)
        \s*
        /x;
    unless (@lines) {
        warn sprintf( 'regexp failed to match string: %s', $cn_item );
        push @lines, $cn_item;    # if no match, just push the whole string.
    }

    if ( $lines[0] =~ /^([-a-zA-Z]+)\s?($possible_decimal)$/ ) {
        shift @lines;              # pull off the matching first element, like example 1
        unshift @lines, $1, $2;    # replace it with the two pieces
    }

    push @lines, split /\s+/,
        pop @lines;                # split the last piece into an arbitrary number of pieces at spaces
    return @lines;
}

1;

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut
