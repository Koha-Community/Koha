#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Test::MockModule;
use Test::More tests => 3;
use t::lib::Mocks;

BEGIN {
    use_ok( 'Koha::Template::Plugin::JSConsents', "Can use Koha::Template::Plugin::JSConsents" );
}

ok( my $consents = Koha::Template::Plugin::JSConsents->new(), 'Able to instantiate template plugin' );

subtest "all" => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference(
        'CookieConsentedJS',
        'W3siaWQiOiJfbGFrZGhjOW11IiwibmFtZSI6InRlc3QiLCJkZXNjcmlwdGlvbiI6InRlc3QiLCJtYXRjaFBhdHRlcm4iOiJ0ZXN0MSIsImNvb2tpZURvbWFpbiI6ImxvY2FsaG9zdCIsImNvb2tpZVBhdGgiOiIvIiwib3BhY0NvbnNlbnQiOnRydWUsInN0YWZmQ29uc2VudCI6dHJ1ZSwiY29kZSI6IktHWjFibU4wYVc5dUtDa2dleUFLSUNBZ0lHTnZibk52YkdVdWJHOW5LQ2RJWld4c2J5Qm1jbTl0SUhSbGMzUXhKeWs3SUFvZ0lDQWdaRzlqZFcxbGJuUXVZMjl2YTJsbElEMGdJblJsYzNReFBYUmxjM1JwYm1jN0lHUnZiV0ZwYmoxc2IyTmhiR2h2YzNRN0lIQmhkR2c5THpzZ1UyRnRaVk5wZEdVOVRtOXVaVHNnVTJWamRYSmxJanNnQ24wcEtDazcifV0='
    );

    is_deeply(
        $consents->all('opacConsent'),
        [
            {
                'name'       => 'test',
                'cookiePath' => '/',
                'code' =>
                    'KGZ1bmN0aW9uKCkgeyAKICAgIGNvbnNvbGUubG9nKCdIZWxsbyBmcm9tIHRlc3QxJyk7IAogICAgZG9jdW1lbnQuY29va2llID0gInRlc3QxPXRlc3Rpbmc7IGRvbWFpbj1sb2NhbGhvc3Q7IHBhdGg9LzsgU2FtZVNpdGU9Tm9uZTsgU2VjdXJlIjsgCn0pKCk7',
                'staffConsent' => 1,
                'matchPattern' => 'test1',
                'description'  => 'test',
                'cookieDomain' => 'localhost',
                'opacConsent'  => 1,
                'id'           => '_lakdhc9mu'
            }
        ],
        'Returns a Base64 decoded JSON object converted into a data structure'
    );
};

1;
