package Koha::ERM::EHolding;

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

use Koha::ERM::EHolding::Packages;

=head1 NAME

Koha::ERM::EHolding - Koha ERM EHolding Object class

=head1 API

=head2 Class Methods

=head3 eholding_packages

Returns the eholding_packages link for this eHolding

=cut

sub eholding_packages {
    my ( $self, $eholding_packages ) = @_;

    if ( $eholding_packages ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->eholding_packages->delete;

                for my $eholding_package (@$eholding_packages) {
                    $self->_result->add_to_erm_eholdings_packages($eholding_package);
                }
            }
        );
    }
    my $eholding_packages_rs = $self->_result->erm_eholdings_packages;
    return Koha::ERM::EHolding::Packages->_new_from_dbic($eholding_packages_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmEholding';
}

1;
