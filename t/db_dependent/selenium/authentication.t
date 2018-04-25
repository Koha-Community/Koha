#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2017  Catalyst IT
# Copyright 2018 Koha Development team
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

#This selenium test is to test authentication, by performing the following: create a category and patron (same as basic_workflow.t). Then the superlibrarian logs out and the created patron must log into the staff intranet and OPAC

#Note: If you are testing this on kohadevbox with selenium installed in kohadevbox then you need to set the staffClientBaseURL to localhost:8080 and the OPACBaseURL to localhost:80

use Modern::Perl;
use Test::More tests => 2;

use C4::Context;
use Koha::AuthUtils;
use t::lib::Selenium;
use t::lib::TestBuilder;

my @data_to_cleanup;

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 2 if $@;

    my $builder  = t::lib::TestBuilder->new;
    my $s        = t::lib::Selenium->new;
    my $driver   = $s->driver;

    subtest 'Staff interface authentication' => sub {
        plan tests => 5;
        my $mainpage = $s->base_url . q|mainpage.pl|;
        $driver->get($mainpage);
        like( $driver->get_title, qr(Log in to Koha), 'Hitting the main page should redirect to the login form');

        my $password = Koha::AuthUtils::generate_password();
        my $digest = Koha::AuthUtils::hash_password( $password );
        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});
        $patron->update_password( $patron->userid, $digest );

        # Patron does not have permission to access staff interface
        $s->auth( $patron->userid, $password );
        like( $driver->get_title, qr(Access denied), 'Patron without permission should be redirected to the login form' );

        $driver->get($mainpage . q|?logout.x=1|);
        $patron->flags(4)->store; # catalogue permission
        $s->auth( $patron->userid, $password );
        like( $driver->get_title, qr(Koha staff client), 'Patron with flags catalogue should be able to login' );

        $driver->get($mainpage . q|?logout.x=1|);
        like( $driver->get_title(), qr(Log in to Koha), 'If logout is requested, login form should be displayed' );

        $patron->flags(1)->store; # superlibrarian permission
        $s->auth( $patron->userid, $password );
        like( $driver->get_title, qr(Koha staff client), 'Patron with flags superlibrarian should be able to login' );
    };

    subtest 'OPAC interface authentication' => sub {
        plan tests => 6;

        my $mainpage = $s->opac_base_url . q|opac-main.pl|;
        $driver->get($mainpage);
        like( $driver->get_title, qr(Koha online catalog), 'Hitting the main page should not redirect to the login form');

        my $password = Koha::AuthUtils::generate_password();
        my $digest = Koha::AuthUtils::hash_password( $password );
        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});
        $patron->update_password( $patron->userid, $digest );

        # Using the modal
        $driver->find_element('//a[@class="login-link loginModal-trigger"]')->click;
        $s->fill_form( { muserid => $patron->userid, mpassword => $password } );
        $driver->find_element('//div[@id="loginModal"]//input[@type="submit"]')->click;
        like( $driver->get_title, qr(Koha online catalog), 'Patron without permission should be able to login to the OPAC using the modal' );
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron without permissions should be able to login to the OPAC using the modal');

        $driver->find_element('//a[@id="logout"]')->click;
        $driver->capture_screenshot('1.png');
        $driver->find_element('//div[@id="login"]'); # logged out

        # Using the form on the right
        $s->fill_form( { userid => $patron->userid, password => $password } );
        $s->submit_form;
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron without permissions should be able to login to the OPAC using the form on the right');

        $driver->find_element('//a[@id="logout"]')->click;
        $driver->find_element('//div[@id="login"]'); # logged out


        $patron->flags(4)->store; # catalogue permission
        $s->fill_form( { userid => $patron->userid, password => $password } );
        $s->submit_form;
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron with catalogue permission should be able to login to the OPAC');

        $driver->find_element('//a[@id="logout"]')->click;
        $driver->find_element('//div[@id="login"]'); # logged out

        $patron->flags(1)->store; # superlibrarian permission
        $s->fill_form( { userid => $patron->userid, password => $password } );
        $s->submit_form;
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron with superlibrarian permission should be able to login to the OPAC');

        $driver->find_element('//a[@id="logout"]')->click;
        $driver->find_element('//div[@id="login"]'); # logged out

        push @data_to_cleanup, $patron, $patron->category, $patron->library;
    };

    $driver->quit();
};

END {
    $_->delete for @data_to_cleanup;
};
