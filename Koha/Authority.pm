package Koha::Authority;

# Copyright 2015 Koha Development Team
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

use base qw(Koha::Object);
use Koha::SearchEngine::Search;

=head1 NAME

Koha::Authority - Koha Authority Object class

=head1 API

=head2 Instance Methods

=head3 get_usage_count

    $count = $self->get_usage_count;

    Returns the number of linked biblio records.

=cut

sub get_usage_count {
    my ( $self ) = @_;
    return Koha::Authorities->get_usage_count({ authid => $self->authid });
}

=head3 linked_biblionumbers

    my @biblios = $self->linked_biblionumbers({
        [ max_results => $max ], [ offset => $offset ],
    });

    Returns an array of biblionumbers.

=cut

sub linked_biblionumbers {
    my ( $self, $params ) = @_;
    $params->{authid} = $self->authid;
    return Koha::Authorities->linked_biblionumbers( $params );
}

=head2 Class Methods

=head3 type

=cut

sub _type {
    return 'AuthHeader';
}

1;
