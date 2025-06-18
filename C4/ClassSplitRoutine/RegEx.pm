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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

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
    my ( $cn_item, $regexs ) = @_;

    for my $regex (@$regexs) {
        eval "\$cn_item =~ $regex";    ## no critic (StringyEval)
    }
    my @lines = split "\n", $cn_item;

    return @lines;
}

1;

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut
