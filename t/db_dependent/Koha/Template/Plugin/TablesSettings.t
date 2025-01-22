#!/usr/bin/perl

use Modern::Perl;

use C4::Context;

use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 4;
use t::lib::Mocks;

BEGIN {
    use_ok( 'Koha::Template::Plugin::TablesSettings', "Can use Koha::Template::Plugin::TablesSettings" );
}

ok( my $settings = Koha::Template::Plugin::TablesSettings->new(), 'Able to instantiate template plugin' );

subtest "is_hidden" => sub {
    plan tests => 2;

    is(
        $settings->is_hidden( 'opac', 'biblio-detail', 'holdingst', 'item_materials' ), 1,
        'Returns true if the column is hidden'
    );
    is(
        $settings->is_hidden( 'opac', 'biblio-detail', 'holdingst', 'item_callnumber' ), 0,
        'Returns false if the column is not hidden'
    );
};

1;
