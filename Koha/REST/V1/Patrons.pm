package Koha::REST::V1::Patrons;

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

use Koha::DateUtils;
use Koha::Patrons;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Patrons

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Patron objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $patrons_rs = Koha::Patrons->new;
        my $args = $c->validation->output;
        my $attributes = {};

        # Extract reserved params
        my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($args);

        my $restricted = delete $filtered_params->{restricted};

        # Merge sorting into query attributes
        $c->dbic_merge_sorting(
            {
                attributes => $attributes,
                params     => $reserved_params,
                result_set => $patrons_rs
            }
        );

        # Merge pagination into query attributes
        $c->dbic_merge_pagination(
            {
                filter => $attributes,
                params => $reserved_params
            }
        );

        if ( defined $filtered_params ) {

            # Apply the mapping function to the passed params
            $filtered_params = $patrons_rs->attributes_from_api($filtered_params);
            $filtered_params = $c->build_query_params( $filtered_params, $reserved_params );
        }

        # translate 'restricted' => 'debarred'
        $filtered_params->{debarred} = { '!=' => undef }
          if $restricted;

        my $patrons = $patrons_rs->search( $filtered_params, $attributes );
        if ( $patrons_rs->is_paged ) {
            $c->add_pagination_headers(
                {
                    total  => $patrons->pager->total_entries,
                    params => $args,
                }
            );
        }

        return $c->render( status => 200, openapi => $patrons->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


=head3 get

Controller function that handles retrieving a single Koha::Patron object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $patron_id = $c->validation->param('patron_id');
        my $patron    = Koha::Patrons->find($patron_id);

        unless ($patron) {
            return $c->render( status => 404, openapi => { error => "Patron not found." } );
        }

        return $c->render( status => 200, openapi => $patron->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Patron object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $patron = Koha::Patron->new_from_api( $c->validation->param('body') )->store;

        $c->res->headers->location( $c->req->url->to_string . '/' . $patron->borrowernumber );
        return $c->render(
            status  => 201,
            openapi => $patron->to_api
        );
    }
    catch {

        my $to_api_mapping = Koha::Patron->new->to_api_mapping;

        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            return $c->render(
                status  => 400,
                openapi => {
                          error => "Given "
                        . $to_api_mapping->{ $_->broken_fk }
                        . " does not exist"
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                          error => "Given "
                        . $to_api_mapping->{ $_->parameter }
                        . " does not exist"
                }
            );
        }
        else {
            $c->unhandled_exception($_);
        }
    };
}


=head3 update

Controller function that handles updating a Koha::Patron object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find( $patron_id );

    unless ($patron) {
         return $c->render(
             status  => 404,
             openapi => { error => "Patron not found" }
         );
     }

    return try {
        my $body = $c->validation->param('body');
        my $user = $c->stash('koha.user');

        if ( $patron->is_superlibrarian and !$user->is_superlibrarian ) {
            return $c->render(
                status  => 403,
                openapi => { error => "Not enough privileges to change a superlibrarian's email" }
            ) if $body->{email} ne $patron->email ;
        }

        $patron->set_from_api($c->validation->param('body'))->store;
        $patron->discard_changes;
        return $c->render( status => 200, openapi => $patron->to_api );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => {
                    error => "Something went wrong, check Koha logs for details."
                }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Given " .
                            $patron->to_api_mapping->{$_->broken_fk}
                            . " does not exist" }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::MissingParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Missing mandatory parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Invalid parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::NoChanges') ) {
            return $c->render(
                status  => 204,
                openapi => { error => "No changes have been made" }
            );
        }
        else {
            $c->unhandled_exception($_);
        }
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron;

    return try {
        $patron = Koha::Patrons->find( $c->validation->param('patron_id') );

        # check if loans, reservations, debarrment, etc. before deletion!
        $patron->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        unless ($patron) {
            return $c->render(
                status  => 404,
                openapi => { error => "Patron not found" }
            );
        }
        else {
            $c->unhandled_exception($_);
        }
    };
}

=head3 guarantors_can_see_charges

Method for setting whether guarantors can see the patron's charges.

=cut

sub guarantors_can_see_charges {
    my $c = shift->openapi->valid_input or return;

    return try {
        if ( C4::Context->preference('AllowPatronToSetFinesVisibilityForGuarantor') ) {
            my $patron = $c->stash( 'koha.user' );
            my $privacy_setting = ($c->req->json->{allowed}) ? 1 : 0;

            $patron->privacy_guarantor_fines( $privacy_setting )->store;

            return $c->render(
                status  => 200,
                openapi => {}
            );
        }
        else {
            return $c->render(
                status  => 403,
                openapi => {
                    error =>
                      'The current configuration doesn\'t allow the requested action.'
                }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 guarantors_can_see_checkouts

Method for setting whether guarantors can see the patron's checkouts.

=cut

sub guarantors_can_see_checkouts {
    my $c = shift->openapi->valid_input or return;

    return try {
        if ( C4::Context->preference('AllowPatronToSetCheckoutsVisibilityForGuarantor') ) {
            my $patron = $c->stash( 'koha.user' );
            my $privacy_setting = ( $c->req->json->{allowed} ) ? 1 : 0;

            $patron->privacy_guarantor_checkouts( $privacy_setting )->store;

            return $c->render(
                status  => 200,
                openapi => {}
            );
        }
        else {
            return $c->render(
                status  => 403,
                openapi => {
                    error =>
                      'The current configuration doesn\'t allow the requested action.'
                }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
