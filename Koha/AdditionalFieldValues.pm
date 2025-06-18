package Koha::AdditionalFieldValues;

=head1 NAME

Koha::AdditionalFieldValues - Koha::Objects derived class for additional field
values

=cut

use Modern::Perl;
use Koha::AdditionalFieldValue;

use base 'Koha::Objects';

sub _type { 'AdditionalFieldValue' }

=head2 object_class

Missing POD for object_class.

=cut

sub object_class { 'Koha::AdditionalFieldValue' }

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

L<Koha::Objects>

=cut

1;
