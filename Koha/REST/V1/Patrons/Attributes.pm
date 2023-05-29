package Koha::REST::V1::Patrons::Attributes;

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

use Koha::Patron::Attributes;
use Koha::Patrons;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Patrons::Attributes

=head1 API

=head2 Methods

=head3 list_patron_attributes

Controller method that handles listing the Koha::Patron::Attribute objects that belong
to a given patron.

=cut

sub list_patron_attributes {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'Patron not found'
            }
        );
    }

    return try {

        my $attributes = $c->objects->search( $patron->extended_attributes );

        return $c->render(
            status  => 200,
            openapi => $attributes
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller method that handles adding a Koha::Patron::Attribute to a given patron.

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'Patron not found'
            }
        );
    }

    return try {

        my $attribute = $patron->add_extended_attribute(
            Koha::Patron::Attribute->new_from_api( # new_from_api takes care of mapping attributes
                $c->req->json
            )->unblessed
        );

        $c->res->headers->location( $c->req->url->to_string . '/' . $attribute->id );
        return $c->render(
            status  => 201,
            openapi => $attribute->to_api
        );
    }
    catch {
        if ( blessed $_ ) {
            if (
                $_->isa(
                    'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint')
              )
            {
                return $c->render(
                    status  => 409,
                    openapi => {
                        error => "$_"
                    }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable') )
            {
                return $c->render(
                    status  => 409,
                    openapi => {
                        error => "$_"
                    }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::InvalidType') )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 overwrite

Controller method that handles overwriting extended attributes for a given patron.

=cut

sub overwrite {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'Patron not found'
            }
        );
    }

    return try {

        my $body = $c->req->json;

        my @attrs;

        foreach my $attr ( @{$body} ) {
            push @attrs, { code => $attr->{type}, attribute => $attr->{value} };
        }

        # Fetch the attributes, sorted by id
        my $attributes = $patron->extended_attributes( \@attrs )->search( undef, { order_by => 'id' });

        return $c->render(
            status  => 200,
            openapi => $attributes->to_api
        );
    }
    catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Patron::Attribute::InvalidType') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa(
                    'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint')
              )
            {
                return $c->render(
                    status  => 409,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable') )
            {
                return $c->render(
                    status  => 409,
                    openapi => { error => "$_" }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Patron::MissingMandatoryExtendedAttribute') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );

            }
        }

        $c->unhandled_exception($_);
    };
}


=head3 update

Controller method that handles updating a single extended patron attribute.

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'Patron not found'
            }
        );
    }

    return try {
        my $attribute = $patron->extended_attributes->find(
            $c->param('extended_attribute_id') );

        unless ($attribute) {
            return $c->render(
                status  => 404,
                openapi => {
                    error => 'Attribute not found'
                }
            );
        }

        $attribute->set_from_api( $c->req->json )->store;
        $attribute->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $attribute->to_api
        );
    }
    catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Patron::Attribute::InvalidType') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa(
                    'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint')
              )
            {
                return $c->render(
                    status  => 409,
                    openapi => { error => "$_" }
                );
            }
            elsif (
                $_->isa('Koha::Exceptions::Patron::Attribute::NonRepeatable') )
            {
                return $c->render(
                    status  => 409,
                    openapi => { error => "$_" }
                );
            }
        }

        $c->unhandled_exception($_);
    };

}

=head3 delete

Controller method that handles removing an extended patron attribute.

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'Patron not found'
            }
        );
    }

    return try {

        my $attribute = $patron->extended_attributes->find(
            $c->param('extended_attribute_id') );

        unless ($attribute) {
            return $c->render(
                status  => 404,
                openapi => {
                    error => 'Attribute not found'
                }
            );
        }

        $attribute->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
