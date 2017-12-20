package Koha::Subscription;

# Copyright ByWater Solutions 2015
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use Koha::Database;
use Koha::Biblios;
use Koha::Acquisition::Booksellers;

use base qw(Koha::Object);

=head1 NAME

Koha::Subscription - Koha Subscription Object class

=head1 API

=head2 Class Methods

=cut

=head3 biblio

Returns the biblio linked to this subscription as a Koha::Biblio object

=cut

sub biblio {
    my ($self) = @_;

    return scalar Koha::Biblios->find($self->biblionumber);
}

=head3 vendor

Returns the vendor/supplier linked to this subscription as a Koha::Acquisition::Bookseller object

=cut

sub vendor {
    my ($self) = @_;
    return scalar Koha::Acquisition::Booksellers->find($self->aqbooksellerid);
}

=head3 subscribers

my $subscribers = $subscription->subscribers;

return a Koha::Patrons object

=cut

sub subscribers {
    my ($self) = @_;
    my $schema = Koha::Database->new->schema;
    my @borrowernumbers = $schema->resultset('Alert')->search({ externalid => $self->subscriptionid })->get_column( 'borrowernumber' )->all;
    return Koha::Patrons->search({ borrowernumber => {-in => \@borrowernumbers } });
}

=head3 add_subscriber

$subscription->add_subscriber( $patron );

Add a new subscriber (Koha::Patron) to this subscription

=cut

sub add_subscriber {
    my ( $self, $patron )  = @_;
    my $schema = Koha::Database->new->schema;
    my $rs = $schema->resultset('Alert');
    $rs->create({ externalid => $self->subscriptionid, borrowernumber => $patron->borrowernumber });
}

=head3 remove_subscriber

$subscription->remove_subscriber( $subscriber );

Remove a subscriber (Koha::Patron) from this subscription

=cut

sub remove_subscriber {
    my ($self, $patron) = @_;
    my $schema = Koha::Database->new->schema;
    my $rs = $schema->resultset('Alert');
    my $subscriber = $rs->find({ externalid => $self->subscriptionid, borrowernumber => $patron->borrowernumber });
    $subscriber->delete if $subscriber;
}

=head3 type

=cut

sub _type {
    return 'Subscription';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
