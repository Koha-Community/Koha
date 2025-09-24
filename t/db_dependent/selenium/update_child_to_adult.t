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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;

use Test::NoWarnings;
use Test::More;
use Test::MockModule;

use C4::Context;
use Koha::AuthUtils;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

eval { require Selenium::Remote::Driver; };
if ($@) {
    plan skip_all => "Selenium::Remote::Driver is needed for selenium tests.";
} else {
    plan tests => 2;
}

my $s             = t::lib::Selenium->new;
my $driver        = $s->driver;
my $opac_base_url = $s->opac_base_url;
my $base_url      = $s->base_url;
my $builder       = t::lib::TestBuilder->new;

our @cleanup;
subtest 'Update child to patron' => sub {
    plan tests => 3;

    # We are going to test 3 scénarios:
    # 1. There are no adults in the DB => no "Update child" link appear
    # 2. There are at least 2 adults in the DB => a window popup is displayed, letting the librarian choosing the adult category they want
    # 3.An adult will not be able to click the "Update child" link

    $s->auth;

    # Creating the child
    my $patron_category_C =
        $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'C' } } );

    my $child = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $patron_category_C->categorycode,
            }
        }
    );
    my $child_borrowernumber = $child->borrowernumber;

    subtest 'No adult categories' => sub {
        plan tests => 1;

        # That's pretty ugly, but we need 0 adult in the DB to really test the whole behaviorà
        Koha::Patron::Categories->search( { category_type => 'A' } )->update( { category_type => 'Z' } );

        $driver->get( $base_url . "/members/moremember.pl?borrowernumber=" . $child_borrowernumber );

        # Find the "More" button group, it's the last one
        # Do not use "More" to select the button, to make it works even when translated
        $driver->find_element('//div[@id="toolbar"]/div[@class="btn-group"][last()]')->click;

        $s->remove_error_handler;

        # Why ->id is needed to make it fail?
        # We should expect ->find_element to return 0, but it returns a WebElement (??)
        my $update_link_id = eval { $driver->find_element('//a[@id="updatechild"]')->id; };
        $s->add_error_handler;
        is( $update_link_id, undef, 'No update link should be displayed' );

        # Resetting the patrons to adult
        Koha::Patron::Categories->search( { category_type => 'Z' } )->update( { category_type => 'A' } );
    };

    my $patron_category_A =
        $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'A' } } );
    my $adult_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $patron_category_A->categorycode,
            }
        }
    );
    my $adult_2 = $builder->build_object(    # We want at least 2 adults to display the popup window
        {
            class => 'Koha::Patrons',
            value => {
                categorycode => $patron_category_A->categorycode,
            }
        }
    );
    my $adult_borrowernumber = $adult_1->borrowernumber;

    subtest 'Update child to adult' => sub {
        plan tests => 2;
        $driver->get( $base_url . "/members/moremember.pl?borrowernumber=" . $child_borrowernumber );
        $driver->find_element('//div[@id="toolbar"]/div[@class="btn-group"][last()]')->click;    # More button group
        my $update_link = $driver->find_element('//a[@id="updatechild"]');

        is(
            $update_link->get_attribute('data-bs-toggle'), undef,
            'The update link should not have a data-bs-toggle attribute => not a tooltip and can be clickable'
        );
        $update_link->click;

        # Switch to the popup window
        # Note that if there is only 1 adult in the DB the popup does not appears, but an alert instead. Not tested so far.
        my $handles = $driver->get_window_handles;
        $driver->switch_to_window( $handles->[1] );
        $driver->find_element( '//input[@id="catcode' . $patron_category_A->categorycode . '"]' )->click;
        $driver->set_window_size( 1024, 768 );
        $s->submit_form;

        is(
            $child->get_from_storage->categorycode, $patron_category_A->categorycode,
            'The child should now be an adult!'
        );

        # Switching back to the main window
        $driver->switch_to_window( $handles->[0] );
    };

    subtest 'Cannot update an adult' => sub {
        plan tests => 2;

        # Go to the adult detail view
        $driver->get( $base_url . "/members/moremember.pl?borrowernumber=$adult_borrowernumber" );
        $driver->find_element('//div[@id="toolbar"]/div[@class="btn-group"][last()]')->click;    # More button group

        my $update_li = $driver->find_element('//a[@id="updatechild"]/..');
        is(
            $update_li->get_attribute( 'data-bs-toggle', 1 ), 'tooltip',
            q|The parent of the update link should have a data-bs-toggle attribute => it's a tooltip, not clickable|
        );
        $update_li->click;
        like(
            $driver->get_current_url, qr{/members/moremember\.pl\?borrowernumber=$adult_borrowernumber$},
            'After clicking the link, nothing happens, no # in the URL'
        );
    };

    my @patrons = ( $adult_1, $adult_2, $child );
    push @cleanup, $_,                 $_->library, for @patrons;
    push @cleanup, $patron_category_A, $patron_category_C;

    $driver->quit();
};

END {
    # Resetting the patrons to adult, in case it has not been done earlier (if failures happened)
    Koha::Patron::Categories->search( { category_type => 'Z' } )->update( { category_type => 'A' } );

    $_->delete for @cleanup;
}
