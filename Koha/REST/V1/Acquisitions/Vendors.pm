package Koha::REST::V1::Acquisitions::Vendors;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Currencies;

use C4::Context;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Acquisitions::Vendors

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Acquisition::Bookseller objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $vendors_rs = Koha::Acquisition::Booksellers->new;
        my $vendors    = $c->objects->search($vendors_rs);
        return $c->render(
            status  => 200,
            openapi => $vendors
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Acquisition::Bookseller

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Booksellers->find( $c->param('vendor_id') );

    return $c->render_resource_not_found("Vendor")
        unless $vendor;

    return try {
        my $vendor_to_return = $c->objects->to_api($vendor);
        if ( $vendor_to_return->{interfaces} ) {
            my $interfaces = $vendor->interfaces->as_list;
            my @updated_interfaces;
            foreach my $interface ( @{$interfaces} ) {
                $interface->password( $interface->plain_text_password );
                push @updated_interfaces, $interface->unblessed;
            }
            $vendor_to_return->{interfaces} = \@updated_interfaces;
        }

        return $c->render(
            status  => 200,
            openapi => $vendor_to_return,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Acquisition::Bookseller object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $vendor              = $c->req->json;
    my $contacts            = delete $vendor->{contacts};
    my $interfaces          = delete $vendor->{interfaces};
    my $aliases             = delete $vendor->{aliases};
    my $extended_attributes = delete $vendor->{extended_attributes};

    my $vendor_to_store = Koha::Acquisition::Bookseller->new_from_api( $c->req->json );

    return try {
        $vendor_to_store->store;

        $vendor_to_store->contacts( $contacts     || [] );
        $vendor_to_store->aliases( $aliases       || [] );
        $vendor_to_store->interfaces( $interfaces || [] );

        if ( $extended_attributes && scalar(@$extended_attributes) > 0 ) {
            my @extended_attributes =
                map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
            $vendor_to_store->extended_attributes( \@extended_attributes );
        }

        $c->res->headers->location( $c->req->url->to_string . '/' . $vendor_to_store->id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($vendor_to_store),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Acquisition::Bookseller object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $vendor_id = $c->param('vendor_id');
    my $vendor    = Koha::Acquisition::Booksellers->find($vendor_id);

    return $c->render_resource_not_found("Vendor")
        unless $vendor;

    return try {
        my $vendor_update = $c->req->json;
        my $contacts      = exists $vendor_update->{contacts}   ? delete $vendor_update->{contacts}   : undef;
        my $interfaces    = exists $vendor_update->{interfaces} ? delete $vendor_update->{interfaces} : undef;
        my $aliases       = exists $vendor_update->{aliases}    ? delete $vendor_update->{aliases}    : undef;
        my $extended_attributes =
            exists $vendor_update->{extended_attributes} ? delete $vendor_update->{extended_attributes} : undef;

        $vendor->set_from_api($vendor_update);
        $vendor->store();

        $vendor->contacts( $contacts     || [] ) if defined $contacts;
        $vendor->aliases( $aliases       || [] ) if defined $aliases;
        $vendor->interfaces( $interfaces || [] ) if defined $interfaces;

        if ( $extended_attributes && scalar(@$extended_attributes) > 0 ) {
            my @extended_attributes =
                map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
            $vendor->extended_attributes( \@extended_attributes );
        }

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($vendor),
        );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 delete

Controller function that handles deleting a Koha::Acquisition::Bookseller object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $vendor = Koha::Acquisition::Booksellers->find( $c->param('vendor_id') );

        return $c->render_resource_not_found("Vendor")
            unless $vendor;

        my $basket_count       = $vendor->baskets->count;
        my $subscription_count = $vendor->subscriptions->count;
        my $invoice_count      = $vendor->invoices->count;

        my $safe_to_delete = ( $basket_count == 0 && $subscription_count == 0 && $invoice_count == 0 ) ? 1 : 0;
        return $c->render(
            status  => 409,
            openapi => { error => "Vendor cannot be deleted with existing baskets, subscriptions or invoices" }
        ) unless $safe_to_delete;

        $vendor->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 config

Return the configuration options needed for the ERM Vue app

=cut

sub config {
    my $c = shift->openapi->valid_input or return;

    my $patron      = $c->stash('koha.user');
    my $userflags   = C4::Auth::haspermission( $patron->userid );
    my $permissions = Koha::Auth::Permissions->get_authz_from_flags( { flags => $userflags } );

    my @gst_values = map { option => $_ + 0.0 }, split( '\|', C4::Context->preference("TaxRates") );

    return $c->render(
        status  => 200,
        openapi => {
            permissions => $permissions,
            currencies  => Koha::Acquisition::Currencies->search->unblessed,
            gst_values  => \@gst_values,
            edifact     => C4::Context->preference('EDIFACT'),
            marc_orders => C4::Context->preference('MarcOrderingAutomation'),
            erm_module  => C4::Context->preference('ERMModule'),
        },
    );
}

1;
