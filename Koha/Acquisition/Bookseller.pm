package Koha::Acquisition::Bookseller;

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

use Koha::Acquisition::Bookseller::Contacts;
use Koha::Subscriptions;

use base qw( Koha::Object );

=head1 NAME

Koha::Acquisition::Bookseller Object class

=head1 API

=head2 Class Methods

=head3 baskets

    my $vendor  = Koha::Acquisition::Booksellers->find( $id );
    my @baskets = $vendor->baskets();

Returns the list of baskets for the vendor

=cut

sub baskets {
    my ( $self ) = @_;
    return $self->{_result}->aqbaskets;
}

=head3 contacts

    my $vendor   = Koha::Acquisition::Booksellers->find( $id );
    my @contacts = $vendor->contacts();

Returns the list of contacts for the vendor

=cut

sub contacts {
    my ($self) = @_;
    return Koha::Acquisition::Bookseller::Contacts->search( { booksellerid => $self->id } );
}

=head3 subscriptions

    my $vendor        = Koha::Acquisition::Booksellers->find( $id );
    my @subscriptions = $vendor->subscriptions();

Returns the list of subscriptions for the vendor

=cut

sub subscriptions {
    my ($self) = @_;

    return Koha::Subscriptions->search( { aqbooksellerid => $self->id } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqbookseller';
}

1;
