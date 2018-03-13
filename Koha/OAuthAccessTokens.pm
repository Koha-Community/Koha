package Koha::OAuthAccessTokens;

use Modern::Perl;

use base qw(Koha::Objects);

sub object_class {
    return 'Koha::OAuthAccessToken';
}

sub _type {
    return 'OauthAccessToken';
}

1;
