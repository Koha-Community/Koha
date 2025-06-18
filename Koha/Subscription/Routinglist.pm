package Koha::Subscription::Routinglist;

#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;
use Koha::Subscriptions;

use base qw(Koha::Object);

=head1 NAME

Koha::Subscription::Routinglist - Koha subscription routing list object class

=head1 API

=head2 Class methods

=cut

=head3 subscription

my $subscription = $routinglist->subscription

Returns the subscription for a routing list.

=cut

sub subscription {
    my ($self) = @_;
    return Koha::Subscription->_new_from_dbic( $self->_result->subscriptionid );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Subscriptionroutinglist';
}

=head1 AUTHOR

Katrin Fischer <katrin.fischer@bsz-bw.de>

=cut

1;
