package Koha::Patron::Attribute::Types;

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

use Koha::Patron::Attribute::Type;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron::Attribute::Types Object set class

=head1 API

=head2 Class Methods

=cut

=head3 Koha::Patron::Attribute::Types->search();

my @attribute_types = Koha::Patron::Attribute::Types->search($params);

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    my $branchcode = $params->{branchcode};
    delete( $params->{branchcode} );

    my $or =
      $branchcode
      ? {
        '-or' => [
            'borrower_attribute_types_branches.b_branchcode' => undef,
            'borrower_attribute_types_branches.b_branchcode' => $branchcode,
        ]
      }
      : {};
    my $join = $branchcode ? { join => 'borrower_attribute_types_branches' } : {};
    $attributes //= {};
    $attributes = { %$attributes, %$join };
    return $self->SUPER::search( { %$params, %$or, }, $attributes );
}


=head3 type

=cut

sub _type {
    return 'BorrowerAttributeType';
}

sub object_class {
    return 'Koha::Patron::Attribute::Type';
}

1;
