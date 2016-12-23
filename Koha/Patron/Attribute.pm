package Koha::Patron::Attribute;

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

use Koha::Patron::Attribute::Types;

use base qw(Koha::Object);

=head1 NAME

Koha::Patron::Attribute - Koha Patron Attribute Object class

=head1 API

=head2 Class Methods

=cut

=head3 opac_display

    my $attribute = Koha::Patron::Attribute->new({ code => 'a_code', ... });
    if ( $attribute->opac_display ) { ... }

=cut

sub opac_display {

    my $self = shift;

    return Koha::Patron::Attribute::Types->find( $self->code )->opac_display;
}

=head3 opac_editable

    my $attribute = Koha::Patron::Attribute->new({ code => 'a_code', ... });
    if ( $attribute->is_opac_editable ) { ... }

=cut

sub opac_editable {

    my $self = shift;

    return Koha::Patron::Attribute::Types->find( $self->code )->opac_editable;
}

=head3 _type

=cut

sub _type {
    return 'BorrowerAttribute';
}

1;
