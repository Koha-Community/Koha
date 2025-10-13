package Koha::Template::Plugin::AuthClient;

# Copyright Theke Solutions 2022
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

use Template::Plugin;
use base      qw( Template::Plugin );
use Try::Tiny qw( catch try );

use Koha::Auth::Identity::Providers;
use Koha::Logger;

=head1 NAME

Koha::Template::Plugin::AuthClient

=head1 DESCRIPTION

This plugin is used to retrieve configured and valid authentication
providers in the caller context.

=head1 API

=head2 Methods

=head3 get_providers

    [% FOREACH provider IN AuthClient.get_providers %] ...

=cut

sub get_providers {
    my ( $self, $interface ) = @_;

    $interface = 'staff'
        if $interface eq 'intranet';

    my @urls;

    # Handle database upgrade state where schema might be out of sync
    try {
        my $providers =
            Koha::Auth::Identity::Providers->search( { "domains.allow_$interface" => 1 }, { prefetch => 'domains' } );
        my $base_url = ( $interface eq 'staff' ) ? "/api/v1/oauth/login" : "/api/v1/public/oauth/login";

        while ( my $provider = $providers->next ) {

            my $code = $provider->code;

            if ( $provider->protocol eq 'OIDC' || $provider->protocol eq 'OAuth' ) {
                push @urls,
                    {
                    code        => $code,
                    description => $provider->description,
                    icon_url    => $provider->icon_url,
                    url         => "$base_url/$code/$interface",
                    };
            }
        }
    } catch {

        # If database query fails (e.g., during upgrade), return empty array
        Koha::Logger->get->warn("AuthClient: Unable to load identity providers (database may need upgrade): $_");
        @urls = ();
    };

    return \@urls;
}

1;
