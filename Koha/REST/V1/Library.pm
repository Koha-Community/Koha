package Koha::REST::V1::Library;

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
use Koha::Libraries;

use Scalar::Util qw( blessed );

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $libraries;
    my $filter;
    my $args = $c->req->params->to_hash;

    for my $filter_param ( keys %$args ) {
        $filter->{$filter_param} = { LIKE => $args->{$filter_param} . "%" };
    }

    return try {
        my $libraries = Koha::Libraries->search($filter);
        return $c->render( status => 200, openapi => $libraries );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    my $branchcode = $c->validation->param('branchcode');
    my $library = Koha::Libraries->find({ branchcode => $branchcode });
    unless ($library) {
        return $c->render( status  => 404,
                           openapi => { error => "Library not found" } );
    }

    return $c->render( status => 200, openapi => $library );
}

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        if (Koha::Libraries->find($c->req->json->{branchcode})) {
            return $c->render( status => 400,
                openapi => { error => 'Library already exists' } );
        }
        my $library = Koha::Library->new($c->validation->param('body'))->store;
        my $branchcode = $library->branchcode;
        $c->res->headers->location($c->req->url->to_string.'/'.$branchcode);
        return $c->render( status => 201, openapi => $library);
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

sub update {
    my $c = shift->openapi->valid_input or return;

    my $library;
    return try {
        $library = Koha::Libraries->find($c->validation->param('branchcode'));
        $library->set($c->validation->param('body'))->store;
        return $c->render( status => 200, openapi => $library );
    }
    catch {
        if ( not defined $library ) {
            return $c->render( status => 404,
                               openapi => { error => "Object not found" });
        }
        elsif ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $library;
    return try {
        $library = Koha::Libraries->find($c->validation->param('branchcode'));
        $library->delete;
        return $c->render( status => 204, openapi => '');
    }
    catch {
        if ( not defined $library ) {
            return $c->render( status => 404, openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

1;
