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

use Koha::REST::V1::ERM::EHoldings::Resources::Local;
use Koha::REST::V1::ERM::EHoldings::Resources::EBSCO;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $provider = $c->validation->param('provider');
    if ( $provider eq 'ebsco' ) {
        return Koha::REST::V1::ERM::EHoldings::Resources::EBSCO::list($c);
    } else {
        return Koha::REST::V1::ERM::EHoldings::Resources::Local::list($c);
    }
}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EHoldings::Resource object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $provider = $c->validation->param('provider');
    if ( $provider eq 'ebsco' ) {
        return Koha::REST::V1::ERM::EHoldings::Resources::EBSCO::get($c);
    } else {
        return Koha::REST::V1::ERM::EHoldings::Resources::Local::get($c);
    }
}

1;
