#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2017  Catalyst IT
# Copyright 2021 Koha Development team
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
use Test::More tests => 3;

use C4::Context;
use Koha::AuthUtils;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

my @data_to_cleanup;

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 3 if $@;

    my $builder  = t::lib::TestBuilder->new;
    my $s        = t::lib::Selenium->new;
    my $driver   = $s->driver;

    subtest 'Staff interface authentication' => sub {
        plan tests => 7;
        my $mainpage = $s->base_url . q|mainpage.pl|;
        $driver->get($mainpage);
        like( $driver->get_title, qr(Log in to Koha), 'Hitting the main page should redirect to the login form');

        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});
        my $password = Koha::AuthUtils::generate_password($patron->category);
        t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
        $patron->set_password({ password => $password });

        # Patron is authenticated but is not authorized to access staff interface
        $s->auth( $patron->userid, $password );
        like( $driver->get_title, qr(Access denied), 'Patron without permission should be redirected to the login form' );

        # Try logging in as someone else (even a non-existent patron) and you should still be denied access
        $s->auth('Bond','James Bond');
        like( $driver->get_title, qr(Invalid username or password), 'Trying to change to a non-existent user should fail login' );

        $driver->get($mainpage . q|?logout.x=1|);
        $patron->flags(4)->store; # catalogue permission
        $s->auth( $patron->userid, $password );
        like( $driver->get_title, qr(Koha staff interface), 'Patron with flags catalogue should be able to login' );

        $driver->get($mainpage . q|?logout.x=1|);
        like( $driver->get_title(), qr(Log in to Koha), 'If logout is requested, login form should be displayed' );

        $patron->flags(1)->store; # superlibrarian permission
        $s->auth( $patron->userid, $password );
        like( $driver->get_title, qr(Koha staff interface), 'Patron with flags superlibrarian should be able to login' );

        subtest 'not authorized' => sub {
            plan tests => 17;

            # First, logout!
            $driver->get($mainpage . q|?logout.x=1|);
            $patron->flags(4)->store; # Patron has only catalogue permission
            like( $driver->get_title, qr(Log in to Koha), 'Patron should hit the login form after logout' );
            # Login!
            $s->fill_form({ userid => $patron->userid, password => $password });
            $s->driver->find_element('//input[@id="submit-button"]')->click;

            my $cookie = $driver->get_cookie_named('CGISESSID');
            my $first_sessionID = $cookie->{value};

            # Patron is logged in and got a CGISESSID cookie, miam
            like( $driver->get_title, qr(Koha staff interface), 'Patron is logged in' );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session after login, the session has been upgraded' );

            # Authorized page can be accessed, cookie does not change
            $driver->get( $s->base_url . q|catalogue/search.pl| );
            like( $driver->get_title, qr(Advanced search), 'Patron can access advanced search' );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session after hit' );

            # Unauthorized page redirect to the login form
            $driver->get( $s->base_url . q|circ/circulation.pl| );
            like( $driver->get_title, qr(Access denied), 'Patron cannot access the circulation module' );
            # But the patron does not lose the CGISESSID cookie!
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session if unauthorized page is hit' );

            # Luckily mainpage can still be accessed
            $s->click( { id => 'mainpage', main_class => 'main container-fluid' } );
            like( $driver->get_title, qr(Koha staff interface), 'Patron can come back to the mainpage' );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session if back to the mainpage' );

            # As well as the search
            $driver->get( $s->base_url . q|catalogue/search.pl| );
            like( $driver->get_title, qr(Advanced search), 'Patron can access advanced search' );
            # But circulation module is prohibided!
            $driver->get( $s->base_url . q|circ/circulation.pl| );
            like( $driver->get_title, qr(Access denied), 'Patron cannot access the circulation module' );
            # Still can reuse the same cookie
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session if unauthorized page is hit' );

            # This is the "previous page" using the back() JS
            $s->click( { id => 'previous_page', main_class => 'main container-fluid' } );
            like( $driver->get_title, qr(Advanced search), 'Patron can come back to the previous page' );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session if back to the previous page' );

            # Check with a script that is using check_cookie_auth, session must not be deleted!
            $driver->get( $s->base_url . q|svc/checkouts| );
            #FIXME - 500 is the current behaviour, but it's not nice. It could be improved.
            like( $driver->get_title, qr(Error 500), 'Patron cannot access svc script where circulate permissions are required');
            $driver->get( $s->base_url . q|catalogue/search.pl| );
            like( $driver->get_title, qr(Advanced search), 'Patron can reuse the cookie after a script that used check_cookie_auth' );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, 'no new session if unauthorized page is hit' );
        };
        push @data_to_cleanup, $patron, $patron->category, $patron->library;
    };

    subtest 'OPAC interface authentication' => sub {
        plan tests => 7;

        my $mainpage = $s->opac_base_url . q|opac-main.pl|;

        $driver->get($mainpage . q|?logout.x=1|); # Disconnect first! We are logged in if staff and opac interfaces are separated by ports

        $driver->get($mainpage);
        like( $driver->get_title, qr(Koha online catalog), 'Hitting the main page should not redirect to the login form');

        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});
        my $password = Koha::AuthUtils::generate_password($patron->category);
        t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
        $patron->set_password({ password => $password });

        # Using the modal
        $driver->find_element('//a[@class="nav-link login-link loginModal-trigger"]')->click;
        $s->fill_form( { muserid => $patron->userid, mpassword => $password } );
        $driver->find_element('//div[@id="loginModal"]//input[@type="submit"]')->click;
        like( $driver->get_title, qr(Koha online catalog), 'Patron without permission should be able to login to the OPAC using the modal' );
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron without permissions should be able to login to the OPAC using the modal');

        $driver->find_element('//a[@id="user-menu"]')->click;
        $driver->find_element('//a[@id="logout"]')->click;
        $driver->get($mainpage); # This should not be needed but we the next find_element fails randomly

        { # Temporary debug
            $driver->error_handler(
                sub {
                    my ( $driver, $selenium_error ) = @_;
                    print STDERR "\nSTRACE:";
                    my $i = 1;
                    while ( (my @call_details = (caller($i++))) ){
                        print STDERR "\t" . $call_details[1]. ":" . $call_details[2] . " in " . $call_details[3]."\n";
                    }
                    print STDERR "\n";
                    print STDERR sprintf("Is logged in patron: %s (%s)?\n", $patron->firstname, $patron->surname );
                    $s->capture( $driver );
                    croak $selenium_error;
                }
            );

            $driver->find_element('//div[@id="login"]'); # logged out
            $s->add_error_handler; # Reset to the default error handler
        }

        # Using the form on the right
        $s->fill_form( { userid => $patron->userid, password => $password } );
        $s->submit_form;
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron without permissions should be able to login to the OPAC using the form on the right');

        $driver->find_element('//a[@id="user-menu"]')->click;
        $driver->find_element('//a[@id="logout"]')->click;
        $driver->find_element('//div[@id="login"]'); # logged out


        $patron->flags(4)->store; # catalogue permission
        $s->fill_form( { userid => $patron->userid, password => $password } );
        $s->submit_form;
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron with catalogue permission should be able to login to the OPAC');

        $driver->find_element('//a[@id="user-menu"]')->click;
        $driver->find_element('//a[@id="logout"]')->click;
        $driver->find_element('//div[@id="login"]'); # logged out

        $patron->flags(1)->store; # superlibrarian permission
        $s->fill_form( { userid => $patron->userid, password => $password } );
        $s->submit_form;
        $driver->find_element('//div[@id="userdetails"]');
        like( $driver->get_title, qr(Your library home), 'Patron with superlibrarian permission should be able to login to the OPAC');

        $driver->find_element('//a[@id="user-menu"]')->click;
        $driver->find_element('//a[@id="logout"]')->click;
        $driver->find_element('//div[@id="login"]'); # logged out

        subtest 'not authorized' => sub {
            plan tests => 13;

            $driver->get($mainpage . q|?logout.x=1|);
            $driver->get($mainpage);
            my $cookie = $driver->get_cookie_named('CGISESSID');
            my $first_sessionID = $cookie->{value};

            # User is not logged in, navigation does not generate a new cookie
            $driver->get( $s->opac_base_url . q|opac-search.pl| );
            like( $driver->get_title, qr(Advanced search) );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, );

            # Login
            $driver->get($mainpage);
            $s->fill_form( { userid => $patron->userid, password => $password } );
            $s->submit_form;

            # After logged in, the same cookie is reused
            like( $driver->get_title, qr(Your library home) );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, );
            $driver->get( $s->opac_base_url . q|opac-search.pl| );
            like( $driver->get_title, qr(Advanced search) );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, );

            # Logged in user can place holds
            $driver->get( $s->opac_base_url . q|opac-reserve.pl| ); # We may need to pass a biblionumber here in the future
            like( $driver->get_title, qr(Placing a hold) );
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, );

            $driver->get($mainpage . q|?logout.x=1|);

            # FIXME This new get should not be needed, but the cookie is not modified right after logout
            # However it's not the behaviour when testing the UI
            $driver->get($mainpage);

            # After logout a new cookie is generated, the previous session has been deleted
            $cookie = $driver->get_cookie_named('CGISESSID');
            isnt( $cookie->{value}, $first_sessionID, );
            $first_sessionID = $cookie->{value};

            $driver->get( $s->opac_base_url . q|svc/checkout_notes| );
            #FIXME - 500 is the current behaviour, but it's not nice. It could be improved.
            like( $driver->get_title, qr(An error has occurred), 'Patron cannot access svc');
            # No new cookie generated
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, );

            $driver->get( $s->opac_base_url . q|opac-reserve.pl| );
            like( $driver->get_title, qr(Log in to your account) );

            # Still no new cookie generated
            $driver->get($mainpage);
            $cookie = $driver->get_cookie_named('CGISESSID');
            is( $cookie->{value}, $first_sessionID, );
        };

        push @data_to_cleanup, $patron, $patron->category, $patron->library;
    };

    subtest 'Regressions' => sub {

        plan tests => 2;

        my $mainpage = $s->base_url . q|mainpage.pl|;

        my $patron_1 = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 1 }});
        my $patron_2 = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 0 }});
        my $password = 'password';
        t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
        $patron_1->set_password({ password => $password });
        $patron_2->set_password({ password => $password });

        $driver->get($mainpage . q|?logout.x=1|);
        $s->auth( $patron_2->userid, $password );
        like( $driver->get_title, qr(Access denied), 'Patron without permissions should not be able to login' );

        $s->auth( $patron_1->userid, $password );
        like( $driver->get_title(), qr(Koha staff interface), 'Patron with permissions should be able to login' );

        push @data_to_cleanup, $patron_1, $patron_1->category, $patron_1->library;
        push @data_to_cleanup, $patron_2, $patron_2->category, $patron_2->library;
    };

    $driver->quit();
};

END {
    $_->delete for @data_to_cleanup;
};
