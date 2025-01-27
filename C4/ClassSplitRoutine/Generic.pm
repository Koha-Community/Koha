package C4::ClassSplitRoutine::Generic;

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

=head1 NAME

C4::ClassSplitRoutine::Generic - generic call number sorting key routine

=head1 SYNOPSIS

use C4::ClassSplitRoutine;

=head1 FUNCTIONS


=head2 split_callnumber

  my $cn_split = C4::ClassSplitRoutine::Generic::split_callnumber($cn_item);

  NOTE: Custom call number types go here. It may be necessary to create additional
  splitting algorithms if some custom call numbers cannot be made to work here.
  Presently this splits standard non-ddcn, non-lccn fiction and biography call numbers.

=cut

sub split_callnumber {
    my ($cn_item) = @_;

    my @lines;

    # Split call numbers based on spaces
    push @lines, split /\s+/, $cn_item;    # split the call number into an arbitrary number of pieces at spaces
    if ( $lines[-1] !~ /^.*\d-\d.*$/ && $lines[-1] =~ /^(.*\d+)(\D.*)$/ ) {
        pop @lines;                        # pull off the matching last element
        push @lines, $1, $2;               # replace it with the two pieces
    }
    unless ( scalar @lines ) {
        warn sprintf( 'regexp failed to match string: %s', $cn_item );
        push( @lines, $cn_item );
    }

    return @lines;
}

1;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
