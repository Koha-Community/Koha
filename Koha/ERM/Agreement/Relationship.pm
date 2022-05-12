package Koha::ERM::Agreement::Relationship;

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

Koha::ERM::Agreement::Relationship - Koha Agreement Relationship Object class

=head1 API

=head2 Class Methods

=cut

=head3 agreement

Return the agreement of this relationship

=cut

sub agreement {
    my ( $self ) = @_;
    my $agreement_rs = $self->_result->agreement;
    return Koha::ERM::Agreement->_new_from_dbic($agreement_rs);
}

=head3 related_agreement

Return the agreement linked to this relationship

=cut

sub related_agreement {
    my ( $self ) = @_;
    my $agreement_rs = $self->_result->related_agreement;
    return Koha::ERM::Agreement->_new_from_dbic($agreement_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmAgreementRelationship';
}

1;
