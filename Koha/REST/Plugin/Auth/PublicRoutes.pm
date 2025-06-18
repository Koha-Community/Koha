package Koha::REST::Plugin::Auth::PublicRoutes;

# Copyright Hypernova Oy 2024
#
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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Exception;
use Koha::Exceptions;
use Koha::Exceptions::REST;
use Koha::Patrons;

use Module::Load::Conditional;

=head1 NAME

Koha::REST::Plugin::Auth::PublicRoutes

=head1 API

=head2 Mojolicious::Plugin methods

=head3 register

=cut

sub register {
    my ( $self, $app ) = @_;

=head2 Helper methods

=head3 auth.public

    $c->auth->public( $public_user_id );

=cut

    $app->helper(
        'auth.public' => sub {
            my ( $c, $public_user_id ) = @_;

            unless ( $c->stash('is_public') ) {
                Koha::Exception->throw( error => "This is not a public route!" );
            }

            my $user = $c->stash('koha.user');

            unless ($user) {
                Koha::Exceptions::REST::Public::Authentication::Required->throw( error => "Authentication failure." );
            }

            unless ($public_user_id) {
                Koha::Exceptions::REST::Public::Unauthorized->throw(
                    error => "Unprivileged user cannot access another user's resources" );
            }

            if ( $user->borrowernumber == $public_user_id ) {
                return 1;
            } else {
                Koha::Exceptions::REST::Public::Unauthorized->throw(
                    error => "Unprivileged user cannot access another user's resources" );
            }
        }
    );

=head3 auth.public_guarantor

    $c->auth->public_guarantor( $public_user_id );

=cut

    $app->helper(
        'auth.public_guarantor' => sub {
            my ( $c, $public_user_id ) = @_;

            unless ( $c->stash('is_public') ) {
                Koha::Exception->throw( error => "This is not a public route!" );
            }

            my $user = $c->stash('koha.user');

            unless ($user) {
                Koha::Exceptions::REST::Public::Authentication::Required->throw( error => "Authentication failure." );
            }

            unless ($public_user_id) {
                Koha::Exceptions::REST::Public::Unauthorized->throw(
                    error => "Unprivileged user cannot access another user's resources" );
            }

            my $guarantees = $user->guarantee_relationships->guarantees->as_list;
            foreach my $guarantee ( @{$guarantees} ) {
                if ( $guarantee->borrowernumber == $public_user_id ) {
                    return 1;
                }
            }
            Koha::Exceptions::REST::Public::Unauthorized->throw(
                error => "Unprivileged user cannot access another user's resources" );
        }
    );
}

1;
