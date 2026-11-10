package Koha::REST::Plugin::Policy;

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

=head1 NAME

Koha::REST::Plugin::Policy - Mojolicious plugin for module policies

=head1 SYNOPSIS

    # In the Koha REST app startup
    $self->plugin('Koha::REST::Plugin::Policy');

    # In any controller, when refusing a request because of the policy
    return $c->render(
        status  => 403,
        openapi => {
            error      => 'Return date override is not enabled',
            error_code => 'return_date_not_allowed',
            policy     => $c->module_policy( 'Checkin', { library => $library_id } ),
        }
    );

=head1 DESCRIPTION

Provides helpers for returning module policies in API responses. The policy
represents the current capabilities available to the authenticated user at
the given library for a specific module.

When a request is refused because of the module policy, the error object
carries the current policy in its C<policy> attribute so the client can
refresh its view of it. It follows the C<module_policy> API definition. It is
informational, for the client to update the UI: the server keeps validating
every action.

=head1 API

=head2 Helper methods

=cut

=head2 register

=cut

sub register {
    my ( $self, $app ) = @_;

=head3 module_policy

    my $policy = $c->module_policy('Checkin');
    my $policy = $c->module_policy( 'Checkin', { library => 'CPL' } );

Returns the current policy for the given module, for the authenticated
user, as a hashref matching the C<module_policy> API definition (see
L<Koha::Module::Policy/to_hashref>).

Parameters:

=over 4

=item * C<$scope> (required) - Module name, e.g., 'Checkin', 'Checkout', 'ERM'.
    Maps to C<Koha::Module::Policy::$scope>.

=item * C<$params> (optional hashref):

=over 4

=item * C<library> - Branch code. Defaults to the authenticated user's branch.

=back

=back

Throws an exception if there is no policy class for I<$scope>.

=cut

    $app->helper(
        'module_policy' => sub {
            my ( $c, $scope, $params ) = @_;

            $params //= {};

            my $user       = $c->stash('koha.user');
            my $library_id = $params->{library} // $user->branchcode;

            die "Invalid module policy scope\n" unless ( $scope // q{} ) =~ /^\w+$/;

            my $class = "Koha::Module::Policy::$scope";
            eval "require $class" or die $@;    ## no critic (BuiltinFunctions::ProhibitStringyEval)

            return $class->new(
                {
                    user    => $user,
                    library => $library_id,
                }
            )->to_hashref;
        }
    );
}

1;
