#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 1;
use Test::Mojo;
use Koha::App::Intranet;

use Koha::Database;
use Koha::Patrons;

use t::lib::TestBuilder;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new();

subtest '/cgi-bin/koha/acquisitions/vendors' => sub {
    plan tests => 10;

    my $t = Test::Mojo->new('Koha::App::Intranet');

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags => 1,
            },
        }
    );
    $patron->set_password( { password => 'P4ssword!', skip_validation => 1 } );

    # Log in
    $t->get_ok('/cgi-bin/koha/mainpage.pl');
    my $csrf_token = $t->tx->res->dom('input[name="csrf_token"]')->map( attr => 'value' )->first;
    $t->post_ok(
        '/cgi-bin/koha/mainpage.pl',
        form => {
            csrf_token         => $csrf_token,
            op                 => 'cud-login',
            login_userid       => $patron->userid,
            login_password     => 'P4ssword!',
            koha_login_context => 'intranet',
            branch             => '',
        }
    )->status_is(200)->content_like( qr/Koha home/, 'Login OK' );

    $t->get_ok('/cgi-bin/koha/acquisition/vendors')->status_is(200)->element_exists('#vendors');
    $t->get_ok('/cgi-bin/koha/acquisition/vendors/add')->status_is(200)->element_exists('#vendors');
};
