package Koha::AdditionalFieldValue;

use Modern::Perl;
use Koha::AdditionalField;

use base 'Koha::Object';

=head1 NAME

Koha::AdditionalFieldValue - Koha::Object derived class for additional field
values

=cut

=head2 Class methods

=cut

=head3 field

Return the Koha::AdditionalField object for this AdditionalFieldValue

=cut

sub field {
    my ($self) = @_;

    return Koha::AdditionalField->_new_from_dbic( $self->_result()->field() );
}

=head2 Internal methods

=head3 _type

=cut

sub _type { 'AdditionalFieldValue' }

=head1 AUTHOR

Koha Development Team <https://koha-community.org/>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 BibLibre

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later
version.

Koha is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 SEE ALSO

L<Koha::Object>

=cut

1;
