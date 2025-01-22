#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Mojo;

use Koha::Database;

subtest 'CSRF - Intranet' => sub {
    plan tests => 6;

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

    subtest 'GETting what should be POSTed should fail' => sub {
        plan tests => 3;

        $t->get_ok('/cgi-bin/koha/mainpage.pl?op=cud-login')->status_is(400)->content_like(
            qr/Incorrect use of a safe HTTP method with an `op` parameter that starts with &quot;cud-&quot;/,
            'Body contains correct error message'
        );
    };

    subtest 'POSTing what should be GET should fail' => sub {
        plan tests => 3;

        $t->post_ok('/cgi-bin/koha/mainpage.pl?op=login')->status_is(400)->content_like(
            qr/Incorrect use of an unsafe HTTP method with an `op` parameter that does not start with &quot;cud-&quot;/,
            'Body contains correct error message'
        );
    };
};

subtest 'CSRF - OPAC' => sub {
    plan tests => 6;

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

    subtest 'GETting what should be POSTed should fail' => sub {
        plan tests => 3;

        $t->get_ok('/cgi-bin/koha/opac-user.pl?op=cud-login')->status_is(400)->content_like(
            qr/Incorrect use of a safe HTTP method with an `op` parameter that starts with &quot;cud-&quot;/,
            'Body contains correct error message'
        );
    };

    subtest 'POSTing what should be GET should fail' => sub {
        plan tests => 3;

        $t->post_ok('/cgi-bin/koha/opac-user.pl?op=login')->status_is(400)->content_like(
            qr/Incorrect use of an unsafe HTTP method with an `op` parameter that does not start with &quot;cud-&quot;/,
            'Body contains correct error message'
        );
    };
};
