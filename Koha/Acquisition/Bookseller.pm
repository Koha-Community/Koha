package Koha::Acquisition::Bookseller;

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

use Koha::Acquisition::Bookseller::Aliases;
use Koha::Acquisition::Bookseller::Contacts;
use Koha::Subscriptions;

use base qw( Koha::Object );

=head1 NAME

Koha::Acquisition::Bookseller Object class

=head1 API

=head2 Class methods

=head3 baskets

    my $vendor  = Koha::Acquisition::Booksellers->find( $id );
    my @baskets = $vendor->baskets();

Returns the list of baskets for the vendor

=cut

sub baskets {
    my ( $self ) = @_;
    my $baskets_rs = $self->_result->aqbaskets;
    return Koha::Acquisition::Baskets->_new_from_dbic( $baskets_rs );
}

=head3 contacts

    my $vendor   = Koha::Acquisition::Booksellers->find( $id );
    my @contacts = $vendor->contacts();

Returns the list of contacts for the vendor

=cut

sub contacts {
    my ($self) = @_;
    my $contacts_rs = $self->_result->aqcontacts;
    return Koha::Acquisition::Bookseller::Contacts->_new_from_dbic( $contacts_rs );
}

=head3 subscriptions

    my $vendor        = Koha::Acquisition::Booksellers->find( $id );
    my $subscriptions = $vendor->subscriptions();

Returns the list of subscriptions for the vendor

=cut

sub subscriptions {
    my ($self) = @_;

    # FIXME FK missing at DB level
    return Koha::Subscriptions->search( { aqbooksellerid => $self->id } );
}

=head3 aliases

    my $aliases = $vendor->aliases

    $vendor->aliases([{ alias => 'one alias'}]);

=cut

sub aliases {
    my ($self, $aliases) = @_;

    if ($aliases) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->aliases->delete;
                for my $alias (@$aliases) {
                    $self->_result->add_to_aqbookseller_aliases($alias);
                }
            }
        );
    }

    my $rs = $self->_result->aqbookseller_aliases;
    return Koha::Acquisition::Bookseller::Aliases->_new_from_dbic( $rs );
}


=head3 to_api_mapping

This method returns the mapping for representing a Koha::Acquisition::Bookseller object
on the API.

=cut

sub to_api_mapping {
    return {
        listprice       => 'list_currency',
        invoiceprice    => 'invoice_currency',
        gstreg          => 'gst',
        listincgst      => 'list_includes_gst',
        invoiceincgst   => 'invoice_includes_gst'
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqbookseller';
}

1;
