package Koha::REST::V1::Acquisitions::Vendors;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Acquisition::Booksellers;

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Acquisitions::Vendors

=head1 API

=head2 Methods

=head3 list_vendors

Controller function that handles listing Koha::Acquisition::Bookseller objects

=cut

sub list_vendors {
    my $c = shift->openapi->valid_input or return;

    my $args = _to_model($c->req->params->to_hash);
    my $filter;

    for my $filter_param ( keys %$args ) {
        $filter->{$filter_param} = { LIKE => $args->{$filter_param} . "%" }
            if $args->{$filter_param};
    }

    my @vendors;

    return try {
        @vendors = Koha::Acquisition::Booksellers->search($filter);
        @vendors = map { _to_api($_->TO_JSON) } @vendors;
        return $c->render( status  => 200,
                           openapi => \@vendors );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };
}

=head3 get_vendor

Controller function that handles retrieving a single Koha::Acquisition::Bookseller

=cut

sub get_vendor {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Booksellers->find( $c->validation->param('vendor_id') );
    unless ($vendor) {
        return $c->render( status  => 404,
                           openapi => { error => "Vendor not found" } );
    }

    return $c->render( status  => 200,
                       openapi => _to_api($vendor->TO_JSON) );
}

=head3 add_vendor

Controller function that handles adding a new Koha::Acquisition::Bookseller object

=cut

sub add_vendor {
    my $c = shift->openapi->valid_input or return;

    my $vendor = Koha::Acquisition::Bookseller->new( _to_model( $c->validation->param('body') ) );

    return try {
        $vendor->store;
        return $c->render( status  => 200,
                           openapi => _to_api($vendor->TO_JSON) );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->msg } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };
}

=head3 update_vendor

Controller function that handles updating a Koha::Acquisition::Bookseller object

=cut

sub update_vendor {
    my $c = shift->openapi->valid_input or return;

    my $vendor;

    return try {
        $vendor = Koha::Acquisition::Booksellers->find( $c->validation->param('vendor_id') );
        $vendor->set( _to_model( $c->validation->param('body') ) );
        $vendor->store();
        return $c->render( status  => 200,
                           openapi => _to_api($vendor->TO_JSON) );
    }
    catch {
        if ( not defined $vendor ) {
            return $c->render( status  => 404,
                               openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('Koha::Exceptions::Object') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->message } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };

}

=head3 delete_vendor

Controller function that handles deleting a Koha::Acquisition::Bookseller object

=cut

sub delete_vendor {
    my $c = shift->openapi->valid_input or return;

    my $vendor;

    return try {
        $vendor = Koha::Acquisition::Booksellers->find( $c->validation->param('vendor_id') );
        $vendor->delete;
        return $c->render( status => 200,
                           openapi => q{} );
    }
    catch {
        if ( not defined $vendor ) {
            return $c->render( status  => 404,
                               openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->msg } );
        }
        else {
            return $c->render( status  => 500,
                               openapi => { error => "Something went wrong, check the logs." } );
        }
    };

}

=head3 _to_api

Helper function that maps a Koha::Acquisition::Bookseller object into
the attribute names the exposed REST api spec.

=cut

sub _to_api {
    my $vendor = shift;

    # Delete unused fields
    delete $vendor->{booksellerfax};
    delete $vendor->{bookselleremail};
    delete $vendor->{booksellerurl};
    delete $vendor->{currency};
    delete $vendor->{othersupplier};

    # Rename changed fields
    $vendor->{list_currency}        = delete $vendor->{listprice};
    $vendor->{invoice_currency}     = delete $vendor->{invoiceprice};
    $vendor->{gst}                  = delete $vendor->{gstreg};
    $vendor->{list_includes_gst}    = delete $vendor->{listincgst};
    $vendor->{invoice_includes_gst} = delete $vendor->{invoiceincgst};

    return $vendor;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Acquisition::Bookseller
attribute names.

=cut

sub _to_model {
    my $vendor = shift;

    # Rename back
    $vendor->{listprice}     = delete $vendor->{list_currency};
    $vendor->{invoiceprice}  = delete $vendor->{invoice_currency};
    $vendor->{gstreg}        = delete $vendor->{gst};
    $vendor->{listincgst}    = delete $vendor->{list_includes_gst};
    $vendor->{invoiceincgst} = delete $vendor->{invoice_includes_gst};

    return $vendor;
}

1;
