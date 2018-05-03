package Koha::OAuth;

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

use Koha::ApiKeys;
use Koha::OAuthAccessTokens;

=head1 NAME

Koha::OAuth - Koha library for OAuth2 callbacks

=head1 API

=head2 Class methods

=head3 config

    my $config = Koha::OAuth->config;

Returns a hashref containing the callbacks Net::OAuth2::AuthorizationServer requires

=cut

sub config {
    return {
        verify_client_cb => \&_verify_client_cb,
        store_access_token_cb => \&_store_access_token_cb,
        verify_access_token_cb => \&_verify_access_token_cb
    };
}

=head3 _verify_client_cb

A callback to verify if the client asking for authorization is known to the authorization server
and allowed to get authorization.

=cut

sub _verify_client_cb {
    my (%args) = @_;

    my ($client_id, $client_secret) = @args{ qw/ client_id client_secret / };

    my $api_key;

    if ($client_id) {
        $api_key = Koha::ApiKeys->find( $client_id );
    }

    # client_id mandatory and exists on the DB
    return (0, 'unauthorized_client') unless $api_key && $api_key->active;

    return (0, 'access_denied') unless $api_key->secret eq $client_secret;

    return (1, undef, []);
}

=head3 _store_access_token_cb

A callback to store the generated access tokens.

=cut

sub _store_access_token_cb {
    my ( %args ) = @_;

    my ( $client_id, $access_token, $expires_in )
        = @args{ qw/ client_id access_token expires_in / };

    my $at = Koha::OAuthAccessToken->new({
        access_token  => $access_token,
        expires       => time + $expires_in,
        client_id     => $client_id,
    });
    $at->store;

    return;
}

=head3 _verify_access_token_cb

A callback to verify the access token.

=cut

sub _verify_access_token_cb {
    my (%args) = @_;

    my $access_token = $args{access_token};

    my $at = Koha::OAuthAccessTokens->find($access_token);
    if ($at) {
        if ( $at->expires <= time ) {
            # need to revoke the access token
            $at->delete;

            return (0, 'invalid_grant')
        }

        return $at->unblessed;
    }

    return (0, 'invalid_grant')
};

1;
