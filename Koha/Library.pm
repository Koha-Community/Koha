package Koha::Library;

# Copyright 2015 Koha Development team
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

use Carp;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Library - Koha Library Object class

=head1 API

=head2 Class Methods

=cut

sub get_categories {
    my ( $self, $params ) = @_;
    # TODO This should return Koha::LibraryCategories
    return $self->{_result}->categorycodes( $params );
}

sub update_categories {
    my ( $self, $categories ) = @_;
    $self->_result->delete_related( 'branchrelations' );
    $self->add_to_categories( $categories );
}

sub add_to_categories {
    my ( $self, $categories ) = @_;
    for my $category ( @$categories ) {
        $self->_result->add_to_categorycodes( $category->_result );
    }
}

=head3 type

=cut

sub _type {
    return 'Branch';
}

1;
