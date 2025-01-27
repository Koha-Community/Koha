package Koha::Acquisition::Invoice;

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

use base qw(Koha::Object Koha::Object::Mixin::AdditionalFields);

=head1 NAME

Koha::Acquisition::Invoice object class

=head1 API

=head2 Class methods

=head3 to_api

    my $json = $invoice->to_api;

Overloaded method that returns a JSON representation of the Koha::Acquisition::Invoice object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json_invoice = $self->SUPER::to_api($params);
    return unless $json_invoice;

    $json_invoice->{closed} =
        ( $self->closedate )
        ? Mojo::JSON->true
        : Mojo::JSON->false;

    return $json_invoice;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Acquisition::Invoice object
on the API.

=cut

sub to_api_mapping {
    return {
        invoiceid             => 'invoice_id',
        invoicenumber         => 'invoice_number',
        booksellerid          => 'vendor_id',
        shipmentdate          => 'shipping_date',
        billingdate           => 'invoice_date',
        closedate             => 'closed_date',
        shipmentcost          => 'shipping_cost',
        shipmentcost_budgetid => 'shipping_fund_id',
        message_id            => undef
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Aqinvoice';
}

1;
