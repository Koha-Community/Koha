package Koha::ERM::Agreement;

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

use base qw(Koha::Object);

use Koha::ERM::Agreement::Periods;
use Koha::ERM::Agreement::UserRoles;
use Koha::ERM::Agreement::Licenses;

=head1 NAME

Koha::ERM::Agreement - Koha ErmAgreement Object class

=head1 API

=head2 Class Methods

=cut

=head3 periods

Returns the periods for this agreement

=cut

sub periods {
    my ( $self, $periods ) = @_;

    if ( $periods ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->periods->delete;

                for my $period (@$periods) {
                    $self->_result->add_to_erm_agreement_periods($period);
                }
            }
        );
    }

    my $periods_rs = $self->_result->erm_agreement_periods;
    return Koha::ERM::Agreement::Periods->_new_from_dbic($periods_rs);
}

=head3 user_roles

Returns the user roles for this agreement

=cut

sub user_roles {
    my ( $self, $user_roles ) = @_;

    if ( $user_roles ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->user_roles->delete;

                for my $user_role (@$user_roles) {
                    $self->_result->add_to_erm_agreement_user_roles($user_role);
                }
            }
        );
    }
    my $user_roles_rs = $self->_result->erm_agreement_user_roles;
    return Koha::ERM::Agreement::UserRoles->_new_from_dbic($user_roles_rs);
}

=head3 agreement_licenses

Returns the agreement_licenses for this agreement

=cut

sub agreement_licenses {
    my ( $self, $agreement_licenses ) = @_;

    if ( $agreement_licenses ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->agreement_licenses->delete;

                for my $agreement_license (@$agreement_licenses) {
                    $self->_result->add_to_erm_agreement_licenses($agreement_license);
                }
            }
        );
    }
    my $agreement_licenses_rs = $self->_result->erm_agreement_licenses;
    return Koha::ERM::Agreement::Licenses->_new_from_dbic($agreement_licenses_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmAgreement';
}

1;
