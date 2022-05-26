package Koha::ERM::EHoldings::Package;

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

use Koha::ERM::EHoldings::Package::Agreements;

=head1 NAME

Koha::ERM::EHoldings::Package - Koha ERM Package Object class

=head1 API

=head2 Class Methods

=head3 package_agreements

Returns the package agreements link for this package

=cut

sub package_agreements {
    my ( $self, $package_agreements ) = @_;

    if ( $package_agreements ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->package_agreements->delete;

                for my $package_agreement (@$package_agreements) {
                    $self->_result->add_to_erm_eholdings_packages_agreements($package_agreement);
                }
            }
        );
    }

    my $agreements_rs = $self->_result->erm_eholdings_packages_agreements;
    return Koha::ERM::EHoldings::Package::Agreements->_new_from_dbic($agreements_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmEholdingsPackage';
}

1;
