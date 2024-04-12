#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 2;
use Test::Mojo;

use Koha::Database;

subtest 'CSRF - Intranet' => sub {
    plan tests => 4;

    my $t = Test::Mojo->new('Koha::App::Intranet');

    # Make sure we have a CGISESSID cookie
    $t->get_ok('/cgi-bin/koha/mainpage.pl');

    subtest 'Without a CSRF token' => sub {
        plan tests => 3;

        $t->post_ok('/cgi-bin/koha/mainpage.pl')->status_is(403)
            ->content_like( qr/Wrong CSRF token/, 'Body contains "Wrong CSRF token"' );
    };

    subtest 'With a wrong CSRF token' => sub {
        plan tests => 3;

        $t->post_ok( '/cgi-bin/koha/mainpage.pl', form => { csrf_token => 'BAD', op => 'cud-login' } )->status_is(403)
            ->content_like( qr/Wrong CSRF token/, 'Body contains "Wrong CSRF token"' );
    };

    subtest 'With a good CSRF token' => sub {
        plan tests => 4;

        $t->get_ok('/cgi-bin/koha/mainpage.pl');

        my $csrf_token = $t->tx->res->dom('input[name="csrf_token"]')->map( attr => 'value' )->first;

        $t->post_ok( '/cgi-bin/koha/mainpage.pl', form => { csrf_token => $csrf_token, op => 'cud-login' } )
            ->status_is(200)->content_like( qr/Please log in again/, 'Login failed but CSRF test passed' );
    };
};

subtest 'CSRF - OPAC' => sub {
    plan tests => 4;

    my $t = Test::Mojo->new('Koha::App::Opac');

    # Make sure we have a CGISESSID cookie
    $t->get_ok('/cgi-bin/koha/opac-user.pl');

    subtest 'Without a CSRF token' => sub {
        plan tests => 3;

        $t->post_ok('/cgi-bin/koha/opac-user.pl')->status_is(403)
            ->content_like( qr/Wrong CSRF token/, 'Body contains "Wrong CSRF token"' );
    };

    subtest 'With a wrong CSRF token' => sub {
        plan tests => 3;

        $t->post_ok( '/cgi-bin/koha/opac-user.pl', form => { csrf_token => 'BAD', op => 'cud-login' } )->status_is(403)
            ->content_like( qr/Wrong CSRF token/, 'Body contains "Wrong CSRF token"' );
    };

    subtest 'With a good CSRF token' => sub {
        plan tests => 4;

        $t->get_ok('/cgi-bin/koha/opac-user.pl');

        my $csrf_token = $t->tx->res->dom('input[name="csrf_token"]')->map( attr => 'value' )->first;

        $t->post_ok( '/cgi-bin/koha/opac-user.pl', form => { csrf_token => $csrf_token, op => 'cud-login' } )
            ->status_is(200)->content_like( qr/Log in to your account/, 'Login failed but CSRF test passed' );
    };
};
