package Koha::REST::V1::ERM::EHoldings::Packages;

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

use Mojo::Base 'Mojolicious::Controller';

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

use Koha::REST::V1::ERM::EHoldings::Packages::Manual;
use Koha::REST::V1::ERM::EHoldings::Packages::EBSCO;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        return Koha::REST::V1::ERM::EHoldings::Packages::EBSCO::list(@_);
    } else {
        return Koha::REST::V1::ERM::EHoldings::Packages::Manual::list(@_);
    }
}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EHoldings::Package object

=cut

sub get {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        return Koha::REST::V1::ERM::EHoldings::Packages::EBSCO::get(@_);
    } else {
        return Koha::REST::V1::ERM::EHoldings::Packages::Manual::get(@_);
    }
}

=head3 add

Controller function that handles adding a new Koha::ERM::EHoldings::Package object

=cut

sub add {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        die "invalid action";
    } else {
        return Koha::REST::V1::ERM::EHoldings::Packages::Manual::add(@_);
    }
}

=head3 update

Controller function that handles updating a Koha::ERM::EHoldings::Package object

=cut

sub update {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        die "invalid action";
    } else {
        return Koha::REST::V1::ERM::EHoldings::Packages::Manual::update(@_);
    }
};

=head3 delete

=cut

sub delete {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        die "invalid action";
    } else {
        return Koha::REST::V1::ERM::EHoldings::Packages::Manual::update(@_);
    }
}

1;
