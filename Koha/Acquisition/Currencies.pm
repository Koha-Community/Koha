package Koha::Acquisition::Currencies;

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

use Koha::Acquisition::Currency;

use base qw(Koha::Objects);

=head1 NAME

Koha::Acquisition::Currencies - Koha Acquisition Currency Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_active

=cut

sub get_active {
    my ( $self ) = @_;
    return $self->SUPER::search( { active => 1 } )->next;
}

=head3 type

=cut

sub type {
    return 'Currency';
}

sub object_class {
    return 'Koha::Acquisition::Currency';
}

1;
