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
use Test::NoWarnings;
use Test::More tests => 3;

use C4::Biblio qw(DelBiblio);

use C4::Context;
use Koha::AuthUtils;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

our $builder = t::lib::TestBuilder->new;

our $biblio_title        = 'opac holds test place hold button';
our $biblio_title_search = $biblio_title =~ s/\s/+/gr;
our $biblio              = $builder->build_sample_biblio( { title => $biblio_title } );
our $second_biblio       = $builder->build_sample_biblio( { title => $biblio_title } );

our $biblionumber        = $biblio->biblionumber;
our $second_biblionumber = $second_biblio->biblionumber;

our $item_1 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
    }
);
our $item_1_itemnumber = $item_1->itemnumber;

our $item_2 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
    }
);
our $item_2_itemnumber = $item_2->itemnumber;

our $item_3 = $builder->build_sample_item(
    {
        biblionumber => $second_biblio->biblionumber,
    }
);
our $item_3_itemnumber = $item_3->itemnumber;

our $item_4 = $builder->build_sample_item(
    {
        biblionumber => $second_biblio->biblionumber,
    }
);
our $item_4_itemnumber = $item_4->itemnumber;

# Selenium is faster than search indexer, it needs to wait
sleep 10;

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 3 if $@;

    our $s      = t::lib::Selenium->new;
    our $driver = $s->driver;

    subtest 'not authenticated' => sub {
        plan tests => 2;

        reset_data();

        subtest 'search results' => sub {
            plan tests => 7;

            # 'Place hold' button exists by default
            $driver->get( $s->opac_base_url . "opac-search.pl?q=" . $biblio_title_search );
            like(
                $driver->get_title, qr(Results of search for '$biblio_title'),
                'Correctly in search results page'
            );

            is(
                $driver->find_element('//div[@class="actions-menu noprint"]/span[@class="actions"]/a')->get_text,
                'Place hold',
                'Place hold button should be present',
            );

            # 'Place hold' button doesn't exist when holds are not allowed
            set_holdallowed_not_allowed();
            search_page_hold_button_absent('Unauthenticated - holdallowed not allowed');
            reset_data();

            # 'Place hold'  button doesn't exist when all items are withdrawn
            withdraw_items();
            search_page_hold_button_absent('Unauthenticated - Items withdrawn');
            reset_data();

            # Set onshelfholds rule
            # 0 - "If any unavailable"
            # 1 - "Yes"
            # 2 - "If all unavailable"

            # Always shows "Place hold" for unauthenticated because onshelfholds is not considered
            set_onshelfholds(0);
            search_page_hold_button_present('Unauthenticated - onshelfholds If any unavailable');
            reset_data();

            # Always shows "Place hold" for unauthenticated because onshelfholds is not considered
            set_onshelfholds(1);
            search_page_hold_button_present('Unauthenticated - onshelfholds Yes');
            reset_data();

            # Always shows "Place hold" for unauthenticated because onshelfholds is not considered
            set_onshelfholds(2);
            search_page_hold_button_present('Unauthenticated - onshelfholds If all unavailable');
            reset_data();
        };

        subtest 'detail page' => sub {
            plan tests => 7;

            # 'Place hold' button exists by default
            $driver->get( $s->opac_base_url . "opac-detail.pl?biblionumber=" . $biblionumber );
            like(
                $driver->get_title, qr(Details for $biblio_title),
                'Correctly in detail page'
            );

            is(
                $driver->find_element('//div[@id="ulactioncontainer"]/ul[@id="action"]/li/a')->get_text,
                'Place hold',
                'Place hold button should be present',
            );

            # 'Place hold' button doesn't exist when holds are not allowed
            set_holdallowed_not_allowed();
            detail_page_hold_button_absent('Unauthenticated - holdallowed not allowed');
            reset_data();

            # 'Place hold' button doesn't exist when all items are withdrawn
            withdraw_items();
            detail_page_hold_button_absent('Unauthenticated - items withdrawn');
            reset_data();

            # Set onshelfholds rule
            # 0 - "If any unavailable"
            # 1 - "Yes"
            # 2 - "If all unavailable"

            # Always shows "Place hold" for unauthenticated because onshelfholds is not considered
            set_onshelfholds(0);
            detail_page_hold_button_present('Unauthenticated - onshelfholds If any unavailable');
            reset_data();

            # Always shows "Place hold" for unauthenticated because onshelfholds is not considered
            set_onshelfholds(1);
            detail_page_hold_button_present('Unauthenticated - onshelfholds Yes');
            reset_data();

            # Always shows "Place hold" for unauthenticated because onshelfholds is not considered
            set_onshelfholds(2);
            detail_page_hold_button_present('Unauthenticated - onshelfholds If all unavailable');
            reset_data();
        };

    };

    subtest 'authenticated' => sub {
        plan tests => 5;

        my $mainpage = $s->opac_base_url . q|opac-main.pl|;

        $driver->get( $mainpage . q|?logout.x=1| )
            ;    # Disconnect first! We are logged in if staff and opac interfaces are separated by ports

        $driver->get($mainpage);
        like(
            $driver->get_title, qr(Koha online catalog),
            'Hitting the main page should not redirect to the login form'
        );

        my $patron   = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
        my $password = Koha::AuthUtils::generate_password( $patron->category );
        t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
        $patron->set_password( { password => $password } );

        # Using the modal
        $driver->find_element('//a[@class="nav-link login-link loginModal-trigger"]')->click;
        $s->fill_form( { muserid => $patron->userid, mpassword => $password } );
        $driver->find_element('//div[@id="loginModal"]//input[@type="submit"]')->click;
        like(
            $driver->get_title, qr(Koha online catalog),
            'Patron without permission should be able to login to the OPAC using the modal'
        );
        $driver->find_element('//div[@id="userdetails"]');
        like(
            $driver->get_title, qr(Your summary),
            'Patron without permissions should be able to login to the OPAC using the modal'
        );

        reset_data();

        subtest 'search results' => sub {
            plan tests => 5;

            # 'Place hold' button exists by default
            $driver->get( $s->opac_base_url . "opac-search.pl?q=" . $biblio_title_search );
            like(
                $driver->get_title, qr(Results of search for '$biblio_title'),
                'Correctly in search results page'
            );

            is(
                $driver->find_element('//div[@class="actions-menu noprint"]/span[@class="actions"]/a')->get_text,
                'Place hold',
                'Place hold button should be present',
            );

            # 'Place hold' button doesn't exist when holds are not allowed
            set_holdallowed_not_allowed();
            search_page_hold_button_absent('Authenticated - holdallowed not allowed');
            reset_data();

            # 'Place hold'  button doesn't exist when all items are withdrawn
            withdraw_items();
            search_page_hold_button_absent('Authenticated - items withdrawn');
            reset_data();

            # Set onshelfholds rule
            # 0 - "If any unavailable"
            # 1 - "Yes"
            # 2 - "If all unavailable"

            # FIXME: The test below fails
            # Ideally it should match with its detail page counterpart, but it does not.
            # 'Place hold' button doesn't exist because all are available
            # set_onshelfholds(0);
            # search_page_hold_button_absent('Authenticated - onshelfholds If any unavailable');
            # reset_data();

            set_onshelfholds(1);
            search_page_hold_button_present('Authenticated - onshelfholds Yes');
            reset_data();

            # FIXME: The test below fails
            # Ideally it should match with its detail page counterpart, but it does not.
            # 'Place hold' button doesn't exist because all are available
            # set_onshelfholds(2);
            # search_page_hold_button_absent('Authenticated - onshelfholds If all unavailable');
            # reset_data();
        };

        subtest 'detail page' => sub {
            plan tests => 7;

            # 'Place hold' button exists by default
            $driver->get( $s->opac_base_url . "opac-detail.pl?biblionumber=" . $biblionumber );
            like(
                $driver->get_title, qr(Details for $biblio_title),
                'Correctly in detail page'
            );

            is(
                $driver->find_element('//div[@id="ulactioncontainer"]/ul[@id="action"]/li/a')->get_text,
                'Place hold',
                'Place hold button should be present',
            );

            # 'Place hold' button exists even though holdallowed = not_allowed
            # because it's using category based circulation rules instead
            set_holdallowed_not_allowed();
            detail_page_hold_button_present('Authenticated - holdallowed not allowed');
            reset_data();

            # 'Place hold' button doesn't exist when all items are withdrawn
            withdraw_items();
            detail_page_hold_button_absent('Authenticated - items withdrawn');
            reset_data();

            # Set onshelfholds rule
            # 0 - "If any unavailable"
            # 1 - "Yes"
            # 2 - "If all unavailable"

            # 'Place hold' button doesn't exist because all are available
            set_onshelfholds(0);
            detail_page_hold_button_absent('Authenticated - onshelfholds If any unavailable');
            reset_data();

            set_onshelfholds(1);
            detail_page_hold_button_present('Authenticated - onshelfholds Yes');
            reset_data();

            # 'Place hold' button doesn't exist because all are available
            set_onshelfholds(2);
            detail_page_hold_button_absent('Authenticated - onshelfholds If all unavailable');
            reset_data();
        };

    };

    $driver->quit();

    sub reset_data {
        my $dbh = C4::Context->dbh;
        $dbh->do(q|DELETE FROM circulation_rules WHERE rule_name="holdallowed"|);
        $dbh->do(q|UPDATE circulation_rules SET rule_value=1 WHERE rule_name="onshelfholds"|);
        $dbh->do(
            qq|UPDATE items SET withdrawn=0 WHERE itemnumber IN ('$item_1_itemnumber','$item_2_itemnumber','$item_3_itemnumber','$item_4_itemnumber')|
        );
    }

    sub cleanup_data {
        my $dbh = C4::Context->dbh;
        $dbh->do(
            qq|DELETE items FROM biblio INNER JOIN items ON biblio.biblionumber = items.biblionumber WHERE biblio.title = "$biblio_title"|
        );
        DelBiblio($biblionumber);
        DelBiblio($second_biblionumber);
    }

    sub withdraw_items {
        my $dbh = C4::Context->dbh;
        $dbh->do(
            qq|UPDATE items SET withdrawn=1 WHERE itemnumber IN ('$item_1_itemnumber','$item_2_itemnumber','$item_3_itemnumber','$item_4_itemnumber')|
        );
    }

    sub set_holdallowed_not_allowed {
        Koha::CirculationRules->set_rules(
            {
                itemtype   => undef,
                branchcode => undef,
                rules      => {
                    holdallowed => "not_allowed",
                }
            }
        );
    }

    sub set_onshelfholds {
        my ($rule_value) = @_;
        Koha::CirculationRules->set_rule(
            {
                categorycode => undef,
                itemtype     => undef,
                branchcode   => undef,
                rule_name    => 'onshelfholds',
                rule_value   => $rule_value,
            }
        );
    }

    sub search_page_hold_button_absent {
        my ($message) = @_;

        $driver->get( $s->opac_base_url . "opac-search.pl?q=" . $biblio_title_search );

        my $place_hold_buttons =
            $driver->find_elements( '//div[@id="title_summary_'
                . $biblionumber
                . '"]/div[@class="actions-menu noprint"]/span[@class="actions"]/a[not(contains(@class,"addtoshelf"))]'
            );

        is(
            scalar @{$place_hold_buttons},
            0,
            'Search page - Place hold button should be absent. ' . $message,
        );
    }

    sub search_page_hold_button_present {
        my ($message) = @_;

        $driver->get( $s->opac_base_url . "opac-search.pl?q=" . $biblio_title_search );

        is(
            $driver->find_element(
                      '//div[@id="title_summary_'
                    . $biblionumber
                    . '"]/div[@class="actions-menu noprint"]/span[@class="actions"]/a[not(contains(@class,"addtoshelf"))]'
            )->get_text,
            'Place hold',
            'Search page - Place hold button should be present. ' . $message
        );
    }

    sub detail_page_hold_button_absent {
        my ($message) = @_;
        $driver->get( $s->opac_base_url . "opac-detail.pl?biblionumber=" . $biblionumber );

        is(
            $driver->find_element('//div[@id="ulactioncontainer"]/ul[@id="action"]/li/a')->get_text,
            'Print',
            'Detail page - Place hold button should be absent. ' . $message,
        );
    }

    sub detail_page_hold_button_present {
        my ($message) = @_;
        $driver->get( $s->opac_base_url . "opac-detail.pl?biblionumber=" . $biblionumber );

        is(
            $driver->find_element('//div[@id="ulactioncontainer"]/ul[@id="action"]/li/a')->get_text,
            'Place hold',
            'Detail page - Place hold button should be present. ' . $message,
        );
    }

}

END {
    cleanup_data();
}
