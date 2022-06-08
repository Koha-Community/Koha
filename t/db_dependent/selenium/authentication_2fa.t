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
use Test::More tests => 3;

use C4::Context;
use Koha::AuthUtils;
use Koha::Auth::TwoFactorAuth;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

my @data_to_cleanup;
my $pref_value = C4::Context->preference('TwoFactorAuthentication');

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 2 if $@;

    my $builder  = t::lib::TestBuilder->new;

    my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { flags => 1 }});
    $patron->flags(1)->store; # superlibrarian permission
    my $password = Koha::AuthUtils::generate_password($patron->category);
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->set_password({ password => $password });

    push @data_to_cleanup, $patron, $patron->category, $patron->library;

    my $s        = t::lib::Selenium->new({ login => $patron->userid, password => $password });
    my $driver   = $s->driver;

    subtest 'Setup' => sub {
        plan tests => 10;

        my $mainpage = $s->base_url . q|mainpage.pl|;
        $driver->get($mainpage);
        like( $driver->get_title, qr(Log in to Koha), 'Hitting the main page should redirect to the login form');

        fill_login_form($s);
        like( $driver->get_title, qr(Koha staff interface), 'Patron with flags superlibrarian should be able to login' );

        C4::Context->set_preference('TwoFactorAuthentication', 0);
        $driver->get($s->base_url . q|members/two_factor_auth.pl|);
        like( $driver->get_title, qr(Error 404), 'Must be redirected to 404 is the pref is off' );

        C4::Context->set_preference('TwoFactorAuthentication', 1);
        $driver->get($s->base_url . q|members/two_factor_auth.pl|);
        like( $driver->get_title, qr(Two-factor authentication), 'Must be on the page with the pref on' );

        is( $driver->find_element('//div[@class="two-factor-status"]')->get_text(), 'Status: Disabled', '2FA is disabled' );

        $driver->find_element('//form[@id="two-factor-auth"]//input[@type="submit"]')->click;
        ok($driver->find_element('//img[@id="qr_code"]'), 'There is a QR code');

        $s->fill_form({pin_code => 'wrong_code'});
        $s->submit_form;
        ok($driver->find_element('//div[@class="dialog error"][contains(text(), "Invalid PIN code")]'));
        is( $patron->get_from_storage->secret, undef, 'secret is not set in DB yet' );

        my $secret32 = $driver->find_element('//form[@id="two-factor-auth"]//input[@name="secret32"]')->get_value();
        my $auth = Koha::Auth::TwoFactorAuth->new({patron => $patron, secret32 => $secret32});
        my $code = $auth->code();
        $s->fill_form({pin_code => $code});
        $s->submit_form;
        is( $driver->find_element('//div[@class="two-factor-status"]')->get_text(), 'Status: Enabled', '2FA is enabled' );
        $patron = $patron->get_from_storage;
        is( $patron->decoded_secret, $secret32, 'encrypted secret is set in DB' );

    };

    subtest 'Login' => sub {
        plan tests => 18;

        my $mainpage = $s->base_url . q|mainpage.pl|;

        my $secret32 = $patron->decoded_secret;
        { # ok first try
            $driver->get($mainpage . q|?logout.x=1|);
            $driver->get($s->base_url . q|circ/circulation.pl?borrowernumber=|.$patron->borrowernumber);
            like( $driver->get_title, qr(Log in to Koha), 'Must be on the first auth screen' );
            $driver->capture_screenshot('selenium_failure_2.png');
            fill_login_form($s);
            like( $driver->get_title, qr(Two-factor authentication), 'Must be on the second auth screen' );
            is( login_error($s), undef );

            my $auth = Koha::Auth::TwoFactorAuth->new(
                { patron => $patron, secret32 => $secret32 } );
            my $code = $auth->code();
            $auth->clear;
            $driver->find_element('//form[@id="loginform"]//input[@id="otp_token"]')->send_keys($code);
            $driver->find_element('//input[@type="submit"]')->click;
            like( $driver->get_title, qr(Checking out to ), 'Must be redirected to the original page' );
        }

        { # second try and logout
            $driver->get($mainpage . q|?logout.x=1|);
            $driver->get($s->base_url . q|circ/circulation.pl?borrowernumber=|.$patron->borrowernumber);
            like( $driver->get_title, qr(Log in to Koha), 'Must be on the first auth screen' );
            fill_login_form($s);
            like( $driver->get_title, qr(Two-factor authentication), 'Must be on the second auth screen' );
            is( login_error($s), undef );
            $driver->find_element('//form[@id="loginform"]//input[@id="otp_token"]')->send_keys('wrong_code');
            $driver->find_element('//input[@type="submit"]')->click;
            is( login_error($s), "Invalid two-factor code" );

            $driver->get($mainpage);
            like( $driver->get_title, qr(Two-factor authentication), 'Must still be on the second auth screen' );
            is( login_error($s), undef );
            $driver->find_element('//a[@id="logout"]')->click();
            like( $driver->get_title, qr(Log in to Koha), 'Must be on the first auth screen' );
            is( login_error($s), undef );
        }

        { # second try and success

            $driver->get($mainpage . q|?logout.x=1|);
            $driver->get($s->base_url . q|circ/circulation.pl?borrowernumber=|.$patron->borrowernumber);
            like( $driver->get_title, qr(Log in to Koha), 'Must be on the first auth screen' );
            like( login_error($s), qr(Session timed out) );
            fill_login_form($s);
            like( $driver->get_title, qr(Two-factor authentication), 'Must be on the second auth screen' );
            is( login_error($s), undef );
            $driver->find_element('//form[@id="loginform"]//input[@id="otp_token"]')->send_keys('wrong_code');
            $driver->find_element('//input[@type="submit"]')->click;
            is( login_error($s), "Invalid two-factor code" );

            my $auth = Koha::Auth::TwoFactorAuth->new(
                { patron => $patron, secret32 => $secret32 } );
            my $code = $auth->code();
            $auth->clear;
            $driver->find_element('//form[@id="loginform"]//input[@id="otp_token"]')->send_keys($code);
            $driver->find_element('//input[@type="submit"]')->click;
            like( $driver->get_title, qr(Checking out to ), 'Must be redirected to the original page' );
        }
    };

    subtest "Disable" => sub {
        plan tests => 4;

        my $mainpage = $s->base_url . q|mainpage.pl|;
        $driver->get( $mainpage . q|?logout.x=1| );
        fill_login_form($s);
        my $auth = Koha::Auth::TwoFactorAuth->new( { patron => $patron } );
        my $code = $auth->code();
        $auth->clear;
        $driver->find_element('//form[@id="loginform"]//input[@id="otp_token"]')
          ->send_keys($code);
        $driver->find_element('//input[@type="submit"]')->click;

        $driver->get( $s->base_url . q|members/two_factor_auth.pl| );

        is(
            $driver->find_element('//div[@class="two-factor-status"]')->get_text(),
            'Status: Enabled',
            '2FA is enabled'
        );

        $driver->find_element('//form[@id="two-factor-auth"]//input[@type="submit"]')->click;

        is(
            $driver->find_element('//div[@class="two-factor-status"]')->get_text(),
            'Status: Disabled',
            '2FA has been disabled'
        );

        $patron = $patron->get_from_storage;
        is( $patron->secret, undef, "Secret has been cleared" );
        is( $patron->auth_method(), 'password', 'auth_method has been reset to "password"' );
    };

    $driver->quit();
};

END {
    $_->delete for @data_to_cleanup;
    C4::Context->set_preference('TwoFactorAuthentication', $pref_value);
};


sub login_error {
    my ( $s ) = @_;
    my $driver   = $s->driver;

    $s->remove_error_handler;
    my $login_error = eval {
        my $elt = $driver->find_element('//div[@id="login_error"]');
        return $elt->get_text if $elt && $elt->id;
    };
    $s->add_error_handler;
    return $login_error;
}

# Don't use the usual t::lib::Selenium->auth as we don't want the ->get($mainpage) to test the redirect
sub fill_login_form {
    my ( $s ) = @_;
    $s->fill_form({ userid => $s->login, password => $s->password });
    $s->driver->find_element('//input[@id="submit-button"]')->click;
}
