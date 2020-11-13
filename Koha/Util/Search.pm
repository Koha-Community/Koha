package Koha::Util::Search;

# Copyright 2020 University of Helsinki
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

use C4::Biblio;

=head1 NAME

Koha::Util::Search - functions to build complex search queries

=head1 FUNCTIONS

=head2 get_component_part_query

Returns a query which can be used to search for all component parts of MARC21 biblios

=cut

sub get_component_part_query {
    my ($biblionumber) = @_;

    my $marc = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    my $pf001 = $marc->field('001') || undef;

    if (defined($pf001)) {
        my $pf003 = $marc->field('003') || undef;
        my $searchstr;

        if (!defined($pf003)) {
            # search for 773$w='Host001'
            $searchstr = "rcn='".$pf001->data()."'";
        } else {
            # search for (773$w='Host001' and 003='Host003') or 773$w='Host003 Host001')
            $searchstr = "(rcn='".$pf001->data()."' AND cni='".$pf003->data()."')";
            $searchstr .= " OR rcn='".$pf003->data()." ".$pf001->data()."'";
        }
    }
}

1;
