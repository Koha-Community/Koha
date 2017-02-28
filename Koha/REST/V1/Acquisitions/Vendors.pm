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

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Acquisition::Booksellers;

use Try::Tiny;

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

sub _to_api {

    my $vendor = shift;

    #my $vendor = $vendor_param->TO_JSON;

    # Delete unused fields
    delete $vendor->{booksellerfax};
    delete $vendor->{bookselleremail};
    delete $vendor->{booksellerurl};
    delete $vendor->{currency};
    delete $vendor->{othersupplier};

    # Rename changed fields
    $vendor->{list_currency} = $vendor->{listprice};
    delete $vendor->{listprice};
    $vendor->{invoice_currency} = $vendor->{invoiceprice};
    delete $vendor->{invoiceprice};
    $vendor->{gst} = $vendor->{gstreg};
    delete $vendor->{gstreg};
    $vendor->{list_includes_gst} = $vendor->{listincgst};
    delete $vendor->{listincgst};
    $vendor->{invoice_includes_gst} = $vendor->{invoiceincgst};
    delete $vendor->{invoiceincgst};

    return $vendor;
}

sub _to_model {
    my $vendor_param = shift;

    my $vendor = $vendor_param;

    # Rename back
    $vendor->{listprice} = $vendor->{list_currency};
    delete $vendor->{list_currency};
    $vendor->{invoiceprice} = $vendor->{invoice_currency};
    delete $vendor->{invoice_currency};
    $vendor->{gstreg} = $vendor->{gst};
    delete $vendor->{gst};
    $vendor->{listincgst} = $vendor->{list_includes_gst};
    delete $vendor->{list_includes_gst};
    $vendor->{invoiceincgst} = $vendor->{invoice_includes_gst};
    delete $vendor->{invoice_includes_gst};

    return $vendor;
}

1;
