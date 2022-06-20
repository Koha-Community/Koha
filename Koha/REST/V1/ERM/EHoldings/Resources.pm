package Koha::REST::V1::ERM::EHoldings::Resources;

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

use Koha::REST::V1::ERM::EHoldings::Resources::Manual;
use Koha::REST::V1::ERM::EHoldings::Resources::EBSCO;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        return Koha::REST::V1::ERM::EHoldings::Resources::EBSCO::list(@_);
    } else {
        return Koha::REST::V1::ERM::EHoldings::Resources::Manual::list(@_);
    }
}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EHoldings::Resource object

=cut

sub get {
    my $provider = C4::Context->preference('ERMProvider');
    if ( $provider eq 'ebsco' ) {
        return Koha::REST::V1::ERM::EHoldings::Resources::EBSCO::get(@_);
    } else {
        return Koha::REST::V1::ERM::EHoldings::Resources::Manual::get(@_);
    }
}

1;
