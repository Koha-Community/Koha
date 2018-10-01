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

use C4::Context;

use Koha::Database;
use Koha::StockRotationStages;

use base qw(Koha::Object);

=head1 NAME

Koha::Library - Koha Library Object class

=head1 API

=head2 Class methods

=head3 get_categories

TODO: Ask the author to add a proper description

=cut

sub get_categories {
    my ( $self, $params ) = @_;
    # TODO This should return Koha::LibraryCategories
    return $self->{_result}->categorycodes( $params );
}

=head3 update_categories

TODO: Ask the author to add a proper description

=cut

sub update_categories {
    my ( $self, $categories ) = @_;
    $self->_result->delete_related( 'branchrelations' );
    $self->add_to_categories( $categories );
}

=head3 add_to_categories

TODO: Ask the author to add a proper description

=cut

sub add_to_categories {
    my ( $self, $categories ) = @_;
    for my $category ( @$categories ) {
        $self->_result->add_to_categorycodes( $category->_result );
    }
}

=head3 stockrotationstages

  my $stages = Koha::Library->stockrotationstages;

Returns the stockrotation stages associated with this Library.

=cut

sub stockrotationstages {
    my ( $self ) = @_;
    my $rs = $self->_result->stockrotationstages;
    return Koha::StockRotationStages->_new_from_dbic( $rs );
}

=head3 get_effective_marcorgcode

    my $marcorgcode = Koha::Libraries->find( $library_id )->get_effective_marcorgcode();

Returns the effective MARC organization code of the library. It falls back to the value
from the I<MARCOrgCode> syspref if undefined for the library.

=cut

sub get_effective_marcorgcode {
    my ( $self )  = @_;

    return $self->marcorgcode || C4::Context->preference("MARCOrgCode");
}

=head3 library_groups

Return the Library groups of this library

=cut

sub library_groups {
    my ( $self ) = @_;
    my $rs = $self->_result->library_groups;
    return Koha::Library::Groups->_new_from_dbic( $rs );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Branch';
}

1;
