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

# This test file is made to be run by our CI
# - KOHA_TESTING must be set
# - the database must exist but be empty
# It will go through the installer process with only the mandatory sample data checked, to test the onboarding process

use Modern::Perl;

use Test::More tests => 2;

use t::lib::Selenium;
use C4::Context;

my $superlibrarian = {
    surname    => 'Super',
    firstname  => 'Librarian',
    cardnumber => '143749305',
    userid     => 'SuperL',
    password   => 'aA1bB2cC3dD4'
};
my $languages = {
    en    => 'en',
    ar    => 'ar-Arab',
    es    => 'es-ES',
    fr    => 'fr-FR',
    it    => 'it-IT',
    pt_BR => 'pt-BR',
    tr    => 'tr-TR',
    zh_TW => 'zh-Hans-TW'
};

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 2 if $@;

    skip
        "This test must be run with an empty DB. We are using KOHA_TESTING that is set by our CI\nIf you really want to run it, set this env var.",
        2
        unless $ENV{KOHA_TESTING};

    my $dbh = eval { C4::Context->dbh; };
    skip "Tests won't run if the database does not exist", 2 if $@;

    {
        my $dup_err;
        local *STDERR;
        open STDERR, ">>", \$dup_err;
        $dbh->do(
            q|
            SELECT * FROM systempreferences WHERE 1 = 0 |
        );
        close STDERR;
        if ($dup_err) {
            skip "Tests won't run if the database is not empty", 2 if $@;
        }
    }

    my $s = t::lib::Selenium->new;

    my $driver   = $s->driver;
    my $base_url = $s->base_url;
    my $db_user  = C4::Context->config('user');
    my $db_pass  = C4::Context->config('pass');

    $driver->get( $base_url . "mainpage.pl" );

    my $lang = "en";    # The idea here is to loop on all languages

    $driver->set_window_size( 3840, 1080 );

    # Welcome to the Koha web installer
    $s->fill_form( { userid => $db_user, password => $db_pass } );
    $s->submit_form;

    # Choose your language
    $s->fill_form( { language => $languages->{$lang} } );
    $s->submit_form;

    # Check Perl dependencies
    $s->submit_form;

    # Database settings
    $s->submit_form;

    # Database settings
    # Connection established
    $s->driver->find_element('//div[@class="alert alert-success"]');
    $s->submit_form;

    # Set up database
    $s->submit_form;

    # Success
    # Database tables created
    $s->driver->find_element('//div[@class="alert alert-success"]');
    $s->submit_form;

    # Install basic configuration settings
    $s->submit_form;

    # Select your MARC flavor
    $s->fill_form( { marcflavour => 'MARC21' } );
    $s->submit_form;

    # Selecting default settings
    # Do not check otherwise no onboarding
    #my @checkboxes = $driver->find_elements('//input[@type="checkbox" and not(@checked="checked")]');
    #for my $c ( @checkboxes ) {
    #    $c->click;
    #}
    $s->submit_form;

    for ( 1 .. 20 )
    { # FIXME This is really ugly, but for an unknown reason the next submit_form is resubmitting the same form. So waiting for the next page to be effectively loaded
        my $title = $s->driver->get_title;
        last if $title =~ m|Default data loaded|;
        sleep 1;
    }

    # Default data loaded
    $s->submit_form;

    # Installation complete
    $s->click( { href => '/installer/onboarding.pl', main => 'installer-step3' } );

    # Create a library
    $s->fill_form( { branchcode => 'CPL', branchname => 'Centerville' } );
    $s->submit_form;

    # Library created!
    $s->driver->find_element('//div[@class="alert alert-success"]');

    # Create a patron category
    $s->fill_form( { categorycode => 'S', description => 'Staff', enrolmentperiod => 12 } );
    $s->submit_form;

    # Patron category created!
    $s->driver->find_element('//div[@class="alert alert-success"]');

    # Create Koha administrator patron
    $s->fill_form( { %$superlibrarian, password2 => $superlibrarian->{password} } );
    $s->submit_form;

    #Administrator account created!
    $s->driver->find_element('//div[@class="alert alert-success"]');

    # Create a new item type
    $s->fill_form( { itemtype => 'BK', description => 'Book' } );
    $s->submit_form;

    # New item type created!
    $s->driver->find_element('//div[@class="alert alert-success"]');

    # Create a new circulation rule
    # Keep default values
    $s->submit_form;

    # Get the interface in the correct language
    C4::Context->set_preference( 'language',      $languages->{$lang} );
    C4::Context->set_preference( 'opaclanguages', $languages->{$lang} );

    $s->click( { href => '/mainpage.pl', main => 'onboarding-step5' } );

    $s->fill_form( { userid => $superlibrarian->{userid}, password => $superlibrarian->{password} } );

    like(
        $s->driver->get_title, qr(Log in to Koha),
        'After the onboarding process the user should have landed in the login form page'
    );
    $s->submit_form;

    is( $s->driver->get_title, 'Koha staff interface', 'The credentials we created should work' );

    $driver->quit();
}
