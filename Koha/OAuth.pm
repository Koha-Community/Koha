package Koha::OAuth;

use Modern::Perl;
use Koha::OAuthAccessTokens;
use Koha::OAuthAccessToken;

sub config {
    return {
        verify_client_cb => \&_verify_client_cb,
        store_access_token_cb => \&_store_access_token_cb,
        verify_access_token_cb => \&_verify_access_token_cb
    };
}

sub _verify_client_cb {
    my (%args) = @_;

    my ($client_id, $client_secret)
        = @args{ qw/ client_id client_secret / };

    return (0, 'unauthorized_client') unless $client_id;

    my $clients = C4::Context->config('api_client');
    $clients = [ $clients ] unless ref $clients eq 'ARRAY';
    my ($client) = grep { $_->{client_id} eq $client_id } @$clients;
    return (0, 'unauthorized_client') unless $client;

    return (0, 'access_denied') unless $client_secret eq $client->{client_secret};

    return (1, undef, []);
}

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
