package Koha::ERM::Agreement::UserRole;

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

use Koha::Database;

use Koha::Patrons;

use base qw(Koha::Object);

=head1 NAME

Koha::ERM::Agreement::UserRole - Koha Agreement UserRole Object class

=head1 API

=head2 Class Methods

=cut

=head3 patron

Return the patron linked to this user role

=cut

sub patron {
    my ( $self ) = @_;
    my $patron_rs = $self->_result->user;
    return Koha::Patron->_new_from_dbic($patron_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmAgreementUserRole';
}

1;
