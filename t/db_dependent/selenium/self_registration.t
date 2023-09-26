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
use utf8;

use C4::Context;

use Test::More;
use Test::MockModule;

use C4::Context;
use Koha::AuthUtils;
use t::lib::Selenium;
use t::lib::TestBuilder;
use t::lib::Mocks;

eval { require Selenium::Remote::Driver; };
if ( $@ ) {
    plan skip_all => "Selenium::Remote::Driver is needed for selenium tests.";
} else {
    plan tests => 2;
}

my $s = t::lib::Selenium->new;

my $driver = $s->driver;
my $opac_base_url = $s->opac_base_url;
my $builder = t::lib::TestBuilder->new;

my $PatronSelfRegistration_value = C4::Context->preference('PatronSelfRegistration');
C4::Context->set_preference('PatronSelfRegistration', '1');

my $PatronSelfRegistrationDefaultCategory_value = C4::Context->preference('PatronSelfRegistrationDefaultCategory');

our @cleanup;

subtest 'Disable if no default category' => sub {
    plan tests => 1;

    $driver->get( $opac_base_url . 'opac-memberentry.pl' );
    like( $driver->get_title(), qr(Koha online catalog), );
};

subtest 'Set flags' => sub {
    plan tests => 2;

    my $default_category = $builder->build_object( { class => 'Koha::Patron::Categories' } );
    C4::Context->set_preference( 'PatronSelfRegistrationDefaultCategory', $default_category->categorycode );

    $driver->get($opac_base_url . 'opac-memberentry.pl');
    like( $driver->get_title(), qr(Register a new account), );

    $driver->find_element('//*[@id="borrower_surname"]')->send_keys("a surname");
    $driver->find_element('//*[@id="borrower_firstname"]')->send_keys("a firstname");
    $driver->find_element('//*[@id="borrower_initials"]')->send_keys("1");
    $driver->execute_script(q{document.querySelector("#borrower_initials").setAttribute("name", "borrower_flags");});
    my $captcha = $driver->find_element('//*[@id="captcha"]/following-sibling::span/strong')->get_text();
    $driver->find_element('//*[@id="captcha"]')->send_keys($captcha);
    $s->submit_form;

    my $patron = Koha::Patrons->search({ surname => "a surname" })->next;
    is( $patron->flags, undef, 'flags must be undef even if user tried to pass it' );
    push @cleanup, $patron;
    push @cleanup, $default_category;
};


$driver->quit();

END {
    C4::Context->set_preference('PatronSelfRegistration', $PatronSelfRegistration_value);
    C4::Context->set_preference('PatronSelfRegistration', $PatronSelfRegistrationDefaultCategory_value);
    $_->delete for @cleanup;
};
