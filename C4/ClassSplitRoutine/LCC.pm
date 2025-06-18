package C4::ClassSplitRoutine::LCC;

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
use Library::CallNumber::LC;

use Koha::Logger;

=head1 NAME

C4::ClassSplitRoutine::LCC - LCC call number split method

=head1 SYNOPSIS

use C4::ClassSplitRoutine;

my $cn_split = C4::ClassSplitRoutine::LCC::split_callnumber($cn_item);

=head1 FUNCTIONS

=head2 split_callnumber

  my $cn_split = C4::ClassSplitRoutine::LCC::split_callnumber($cn_item);

=cut

sub split_callnumber {
    my ($cn_item) = @_;

    # lccn examples: 'HE8700.7 .P6T44 1983', 'BS2545.E8 H39 1996';
    my @lines = Library::CallNumber::LC->new($cn_item)->components();
    unless ( scalar @lines && defined $lines[0] ) {
        Koha::Logger->get->debug( sprintf( 'regexp failed to match string: %s', $cn_item // q{} ) );
        @lines = $cn_item;    # if no match, just use the whole string.
    }
    my $LastPiece = pop @lines;
    push @lines, split /\s+/, $LastPiece
        if $LastPiece;        # split the last piece into an arbitrary number of pieces at spaces
    return @lines;
}

1;

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=cut
