package Koha::REST::V1::Acquisitions::Orders;

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

use Koha::Acquisition::Orders;

use Clone qw( clone );
use JSON;
use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Acquisitions::Orders

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Acquisition::Order objects

=cut

sub list {

    my $c = shift->openapi->valid_input or return;

    return try {

        my $only_active = delete $c->validation->output->{only_active};
        my $order_id    = delete $c->validation->output->{order_id};

        my $orders_rs;

        if ( $only_active ) {
            $orders_rs = Koha::Acquisition::Orders->filter_by_active;
        }
        else {
            $orders_rs = Koha::Acquisition::Orders->new;
        }

        $orders_rs = $orders_rs->filter_by_id_including_transfers({ ordernumber => $order_id })
            if $order_id;

        my $args = $c->validation->output;
        my $attributes = {};

        # Extract reserved params
        my ( $filtered_params, $reserved_params, $path_params ) = $c->extract_reserved_params($args);
        # Look for embeds
        my $embed = $c->stash('koha.embed');
        my $fixed_embed = clone($embed);
        if ( exists $fixed_embed->{biblio} ) {
            # Add biblioitems to prefetch
            # FIXME remove if we merge biblio + biblioitems
            $fixed_embed->{biblio}->{children}->{biblioitem} = {};
            $c->stash('koha.embed', $fixed_embed);
        }

        if ( exists $reserved_params->{_order_by} ) {
            # _order_by passed, fix if required
            for my $p ( @{$reserved_params->{_order_by}} ) {
                $p = $c->table_name_fixer($p);
            }
        }

        # Merge sorting into query attributes
        $c->dbic_merge_sorting(
            {
                attributes => $attributes,
                params     => $reserved_params,
                result_set => $orders_rs,
            }
        );

        # If no pagination parameters are passed, default
        $reserved_params->{_per_page} //= C4::Context->preference('RESTdefaultPageSize');
        $reserved_params->{_page}     //= 1;

        unless ( $reserved_params->{_per_page} == -1 ) {
            # Merge pagination into query attributes
            $c->dbic_merge_pagination(
                {
                    filter => $attributes,
                    params => $reserved_params
                }
            );
        }

        # Generate prefetches for embedded stuff
        $c->dbic_merge_prefetch(
            {
                attributes => $attributes,
                result_set => $orders_rs
            }
        );

        # Call the to_model function by reference, if defined
        if ( defined $filtered_params ) {

            # Apply the mapping function to the passed params
            $filtered_params = $orders_rs->attributes_from_api($filtered_params);
            $filtered_params = $c->build_query_params( $filtered_params, $reserved_params );
        }

        if ( defined $path_params ) {

            # Apply the mapping function to the passed params
            $filtered_params //= {};
            $path_params = $orders_rs->attributes_from_api($path_params);
            foreach my $param (keys %{$path_params}) {
                $filtered_params->{$param} = $path_params->{$param};
            }
        }

        if (   defined $reserved_params->{q}
            || defined $reserved_params->{query}
            || defined $reserved_params->{'x-koha-query'} )
        {

            $filtered_params //={};

            my @query_params_array;

            my $json = JSON->new;

            # q is defined as multi => JSON::Validator generates an array
            # containing the string
            foreach my $q ( @{ $reserved_params->{q} } ) {
                push @query_params_array,
                  $json->decode( $c->table_name_fixer($q) )
                  if $q;    # skip if exists but is empty
            }

            # x-koha-query contains a string
            push @query_params_array,
              $json->decode(
                $c->table_name_fixer( $reserved_params->{'x-koha-query'} ) )
              if $reserved_params->{'x-koha-query'};

            # query is already decoded by JSON::Validator at this point
            push @query_params_array,
              $json->decode(
                $c->table_name_fixer(
                    $json->encode( $reserved_params->{query} )
                )
              ) if $reserved_params->{query};

            my $query_params;

            if ( scalar(@query_params_array) > 1 ) {
                $query_params = { '-and' => \@query_params_array };
            }
            else {
                $query_params = $query_params_array[0];
            }

            $filtered_params = $c->merge_q_params( $filtered_params, $query_params, $orders_rs );
        }

        # Perform search
        my $orders = $orders_rs->search( $filtered_params, $attributes );
        my $total  = $orders_rs->search->count;

        $c->add_pagination_headers(
            {
                base_total   => $total,
                page         => $reserved_params->{_page},
                per_page     => $reserved_params->{_per_page},
                query_params => $args,
                total        => ( $orders->is_paged ? $orders->pager->total_entries : $orders->count ),
            }
        );

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($orders)
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Acquisition::Order object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->validation->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => "Order not found" }
        );
    }

    return try {
        my $embed = $c->stash('koha.embed');

        return $c->render(
            status  => 200,
            openapi => $order->to_api({ embed => $embed })
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Acquisition::Order object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $order = Koha::Acquisition::Order->new_from_api( $c->validation->param('body') );
        $order->store->discard_changes;

        $c->res->headers->location(
            $c->req->url->to_string . '/' . $order->ordernumber
        );

        return $c->render(
            status  => 201,
            openapi => $order->to_api
        );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Acquisition::Order object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->validation->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => "Order not found" }
        );
    }

    return try {
        $order->set_from_api( $c->validation->param('body') );
        $order->store()->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $order->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $order = Koha::Acquisition::Orders->find( $c->validation->param('order_id') );

    unless ($order) {
        return $c->render(
            status  => 404,
            openapi => { error => 'Order not found' }
        );
    }

    return try {

        $order->delete;

        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head2 Internal methods

=head3 table_name_fixer

    $q = $c->table_name_fixer( $q );

The Koha::Biblio representation includes the biblioitem.* attributes. This is handy
for API consumers but as they are different tables, converting the queries that mention
biblioitem columns can be tricky. This method renames known column names as used on Koha's
UI.

=cut

sub table_name_fixer {
    my ( $self, $q ) = @_;
    $q =~ s/biblio\.(?=isbn|ean|publisher)/biblio.biblioitem./g;
    return $q;
}

1;
