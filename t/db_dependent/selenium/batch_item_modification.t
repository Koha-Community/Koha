#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use Koha::BackgroundJobs;

use Test::NoWarnings;
use Test::More tests => 3;

use t::lib::Selenium;
use t::lib::TestBuilder;
use utf8;

my $builder = t::lib::TestBuilder->new;

my $login = $ENV{KOHA_USER} || 'koha';

my @cleanup;

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 2 if $@;

    my $s      = t::lib::Selenium->new;
    my $driver = $s->driver;
    $driver->set_window_size( 3840, 1080 );
    my $mainpage = $s->base_url . q|mainpage.pl|;
    $driver->get($mainpage);
    like( $driver->get_title(), qr(Log in to Koha), );
    $s->auth;

    subtest 'test encoding sent to the broker' => sub {
        my $item = $builder->build_sample_item;

        # Navigate to the batch item mod tool
        $s->click( { href => '/cataloguing/cataloging-home.pl', main       => 'container-main' } );
        $s->click( { href => 'tools/batchMod.pl',               main_class => 'main container-fluid' } );
        $driver->find_element('//textarea[@id="barcodelist"]')->send_keys( $item->barcode );
        $s->submit_form;
        my $itemnotes = q{✔ ❤ ★};
        $driver->find_element('//input[@name="items.itemnotes"]')->send_keys($itemnotes);
        $s->submit_form;

        my $view_detail_link =
            $driver->find_element('//a[contains(@href, "/cgi-bin/koha/admin/background_jobs.pl?op=view&id=")]');
        my $href = $view_detail_link->get_attribute('href');
        my $job_id;
        if ( $href =~ m{id=(\d+)} ) {
            $job_id = $1;
        }
        my $job = Koha::BackgroundJobs->find($job_id);
        my $i;
        while ( $job->discard_changes->status ne 'finished' ) {
            sleep(1);
            last if ++$i > 10;
        }
        is( $job->status, 'finished', 'job is finished' );

        is( Koha::Items->find( $item->itemnumber )->itemnotes, $itemnotes );

        push @cleanup, $item, $item->biblio;
    };

    $driver->quit();
}

END {
    $_->delete for @cleanup;
}
