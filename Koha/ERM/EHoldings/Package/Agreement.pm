package Koha::ERM::EHoldings::Package::Agreement;

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

use Koha::ERM::Agreement;
use Koha::ERM::EHoldings::Package;

use base qw(Koha::Object);

=head1 NAME

Koha::ERM::EHoldings::Package::Agreement - Koha Package-Agreement Object class

=head1 API

=head2 Class Methods

=cut

=head3 agreement

Return the agreement linked to this package agreement

=cut

sub agreement {
    my ( $self ) = @_;
    my $agreement_rs = $self->_result->agreement;
    return Koha::ERM::Agreement->_new_from_dbic($agreement_rs);
}

=head3 package

Return the package linked to this package package

=cut

sub package {
    my ( $self ) = @_;
    my $package_rs = $self->_result->package;
    return Koha::ERM::EHoldings::Package->_new_from_dbic($package_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmEholdingsPackagesAgreement';
}

1;
