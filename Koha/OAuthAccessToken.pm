package Koha::OAuthAccessToken;

use Modern::Perl;

use base qw(Koha::Object);

sub _type {
    return 'OauthAccessToken';
}

1;
