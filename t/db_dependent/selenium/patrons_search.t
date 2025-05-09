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

my $original_dateformat                = C4::Context->preference('dateformat');
my $original_DefaultPatronSearchFields = C4::Context->preference('DefaultPatronSearchFields');
my $original_DefaultPatronSearchMethod = C4::Context->preference('DefaultPatronSearchMethod');
my $original_PatronsPerPage            = C4::Context->preference('PatronsPerPage');
our @cleanup;
our $DT_delay = 1;

use C4::Context;

use utf8;
use Test::NoWarnings;
use Test::More;
use Test::MockModule;

use C4::Context;
use Koha::AuthUtils;
use Koha::Patrons;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

eval { require Selenium::Remote::Driver; };
if ($@) {
    plan skip_all => "Selenium::Remote::Driver is needed for selenium tests.";
} else {
    plan tests => 3;
}

my $s             = t::lib::Selenium->new;
my $driver        = $s->driver;
my $opac_base_url = $s->opac_base_url;
my $base_url      = $s->base_url;
my $builder       = t::lib::TestBuilder->new;
my $schema        = Koha::Database->schema;

if ( Koha::Patrons->search( { surname => { -like => "test_patron_%" } } )->count ) {
    BAIL_OUT("Cannot run this test, data we need to create already exist in the DB");
}

my $PatronsPerPage          = 15;
my $borrowernotes           = q|<strong>just 'a" note</strong> \123 ❤|;
my $borrowernotes_displayed = q|just 'a" note \123 ❤|;
my $branchname              = q|<strong>just 'another" library</strong> \123 ❤|;
my $firstname               = q|<strong>fir's"tname</strong> \123 ❤|;
my $address                 = q|<strong>add'res"s</strong> \123 ❤|;
my $email                   = q|a<strong>bad_email</strong>@example\123 ❤.com|;
my (
    $attribute_type,                        $attribute_type_searchable_1, $attribute_type_searchable_2,
    $attribute_type_searchable_not_default, $patron_category,             $library
);

sub setup {
    $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'A' }
        }
    );
    push @cleanup, $patron_category;

    $library = $builder->build_object( { class => 'Koha::Libraries', value => { branchname => $branchname } } );
    push @cleanup, $library;

    my @patrons;
    for my $i ( 1 .. 25 ) {
        push @patrons,
            $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    surname        => "test_patron_" . $i++,
                    firstname      => $firstname,
                    preferred_name => $firstname,
                    middle_name    => q{},                     # We don't want to copy the logic from patron_to_html
                    othernames     => q{},
                    categorycode   => $patron_category->categorycode,
                    branchcode     => $library->branchcode,
                    borrowernotes  => $borrowernotes,
                    address        => $address,
                    email          => $email,
                }
            }
            );
    }

    push @patrons, $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname        => "test",
                firstname      => "not_p_a_t_r_o_n",               # won't match 'patron'
                preferred_name => "not_p_a_t_r_o_n",
                middle_name    => q{},                             # We don't want to copy the logic from patron_to_html
                othernames     => q{},
                categorycode   => $patron_category->categorycode,
                branchcode     => $library->branchcode,
                borrowernotes  => $borrowernotes,
                address        => $address,
                email          => $email,
            }
        }
    );

    unshift @cleanup, $_ for @patrons;

    my $library_2 =
        $builder->build_object( { class => 'Koha::Libraries', value => { branchname => 'X' . $branchname } } );
    push @cleanup, $library_2;

    my $patron_27 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname        => "test_patron_27",
                firstname      => $firstname,
                preferred_name => $firstname,
                middle_name    => q{},                             # We don't want to copy the logic from patron_to_html
                othernames     => q{},
                categorycode   => $patron_category->categorycode,
                branchcode     => $library_2->branchcode,
                borrowernotes  => $borrowernotes,
                address        => $address,
                email          => $email,
                dateofbirth    => '1980-06-17',
            }
        }
    );
    unshift @cleanup, $patron_27;

    my $patron_28 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname      => "test_expired_patron_surname",
                firstname    => 'test_expired_patron',
                categorycode => $patron_category->categorycode,
                branchcode   => $library_2->branchcode,
                dateexpiry   => '2000-12-01',
            }
        }
    );
    unshift @cleanup, $patron_28;

    $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code                => 'my code1',
            description         => 'my description1',
            staff_searchable    => 0,
            searched_by_default => 0
        }
    )->store;
    $attribute_type_searchable_1 = Koha::Patron::Attribute::Type->new(
        {
            code                => 'my code2',
            description         => 'my description2',
            opac_display        => 1,
            staff_searchable    => 1,
            searched_by_default => 1
        }
    )->store;
    $attribute_type_searchable_2 = Koha::Patron::Attribute::Type->new(
        {
            code                => 'my code3',
            description         => 'my description3',
            opac_display        => 1,
            staff_searchable    => 1,
            searched_by_default => 1
        }
    )->store;
    $attribute_type_searchable_not_default = Koha::Patron::Attribute::Type->new(
        {
            code                => 'mycode4',
            description         => 'my description4',
            opac_display        => 1,
            staff_searchable    => 1,
            searched_by_default => 0
        }
    )->store;
    push @cleanup, $attribute_type, $attribute_type_searchable_1, $attribute_type_searchable_2,
        $attribute_type_searchable_not_default;

    $patrons[0]->extended_attributes(
        [
            { code => $attribute_type->code,                        attribute => 'test_attr_1' },
            { code => $attribute_type_searchable_1->code,           attribute => 'test_attr_2' },
            { code => $attribute_type_searchable_2->code,           attribute => 'test_attr_3' },
            { code => $attribute_type_searchable_not_default->code, attribute => 'test_attr_4' },
        ]
    );
    $patrons[1]->extended_attributes(
        [
            { code => $attribute_type->code,                        attribute => 'test_attr_1' },
            { code => $attribute_type_searchable_1->code,           attribute => 'test_attr_2' },
            { code => $attribute_type_searchable_2->code,           attribute => 'test_attr_3' },
            { code => $attribute_type_searchable_not_default->code, attribute => 'test_attr_4' },
        ]
    );
    C4::Context->set_preference( 'PatronsPerPage', $PatronsPerPage );
}

sub teardown {
    C4::Context->set_preference( 'dateformat',                $original_dateformat );
    C4::Context->set_preference( 'DefaultPatronSearchFields', $original_DefaultPatronSearchFields );
    C4::Context->set_preference( 'DefaultPatronSearchMethod', $original_DefaultPatronSearchMethod );
    C4::Context->set_preference( 'PatronsPerPage',            $original_PatronsPerPage );
    $_->delete for @cleanup;
    @cleanup = ();
}

subtest 'Search patrons' => sub {
    plan tests => 30;

    setup();
    my $total_number_of_patrons = Koha::Patrons->search->count;
    my $table_id                = "memberresultst";

    $s->auth;
    C4::Context->set_preference( 'DefaultPatronSearchFields', "" );
    C4::Context->set_preference( 'DefaultPatronSearchMethod', "contains" );
    my $searchable_attributes = Koha::Patron::Attribute::Types->search( { staff_searchable => 1 } )->count();
    my $nb_standard_fields    = 14 + $searchable_attributes;    # Standard fields, plus one searchable attribute
    $driver->get( $base_url . "/members/members-home.pl" );
    my @adv_options = $driver->find_elements('//select[@id="searchfieldstype"]/option');
    is(
        scalar @adv_options, $nb_standard_fields + 1,
        'All standard fields are searchable if DefaultPatronSearchFields not set. middle_name is there.'
    );
    is( $adv_options[0]->get_value(), 'standard', 'Standard search uses value "standard"' );
    my @filter_options = $driver->find_elements('//select[@class="searchfieldstype_filter"]/option');
    is(
        scalar @filter_options, $nb_standard_fields + 1,
        'All standard fields + middle_name are searchable by filter if DefaultPatronSearchFields not set'
    );
    is(
        $filter_options[0]->get_value(), 'standard',
        'Standard filter uses hard coded value "standard" DefaultPatronSearchFields not set'
    );
    C4::Context->set_preference( 'DefaultPatronSearchFields', "firstname|initials" );
    $driver->get( $base_url . "/members/members-home.pl" );
    @adv_options = $driver->find_elements('//select[@id="searchfieldstype"]/option');
    is(
        scalar @adv_options, $nb_standard_fields - 1,
        'New option added when DefaultPatronSearchFields is populated with a field. Note that middle_name and preferred_name disappears, we do not want it if not part of DefaultPatronSearchFields'
    );
    is( $adv_options[0]->get_value(), 'standard', 'Standard search uses value "standard"' );
    @filter_options = $driver->find_elements('//select[@class="searchfieldstype_filter"]/option');
    is(
        scalar @filter_options, $nb_standard_fields - 1,
        'New filter option added when DefaultPatronSearchFields is populated with a field'
    );
    is( $filter_options[0]->get_value(), 'standard', 'Standard filter uses value "standard"' );
    $driver->get( $base_url . "/members/members-home.pl" );
    @adv_options    = $driver->find_elements('//select[@id="searchfieldstype"]/option');
    @filter_options = $driver->find_elements('//select[@class="searchfieldstype_filter"]/option');
    is(
        scalar @adv_options, $nb_standard_fields - 1,
        'Invalid option not added when DefaultPatronSearchFields is populated with an invalid field'
    );
    is(
        scalar @filter_options, $nb_standard_fields - 1,
        'Invalid filter option not added when DefaultPatronSearchFields is populated with an invalid field'
    );

    # NOTE: We should probably ensure the bad field is removed from 'standard' search here, else searches are broken
    C4::Context->set_preference( 'DefaultPatronSearchFields', "" );
    $driver->get( $base_url . "/members/members-home.pl" );
    $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
    $s->submit_form;
    my $first_patron = Koha::Patrons->search( { surname => { like => 'test_patron_%' } } )->next;

    sleep $DT_delay && $s->wait_for_ajax;
    my @td = $driver->find_elements( '//table[@id="' . $table_id . '"]/tbody/tr/td' );
    like(
        $td[2]->get_text, qr[\Q$firstname\E],
        'Column "Name" should be the 3rd and contain the firstname correctly filtered'
    );
    like(
        $td[2]->get_text, qr[\Q$address\E],
        'Column "Name" should be the 3rd and contain the address correctly filtered'
    );
    like(
        $td[2]->get_text, qr[\Q$email\E],
        'Column "Name" should be the 3rd and contain the email address correctly filtered'
    );
    is(
        $td[4]->get_text, $branchname,
        'Column "Library" should be the 6th and contain the html tags - they have been html filtered'
    );
    is(
        $td[9]->get_text, $borrowernotes_displayed,
        'Column "Circ note" should be the 10th and not contain the html tags - they have not been html filtered'
    );

    $driver->find_element(
              '//a[@href="/cgi-bin/koha/members/memberentry.pl?op=edit_form&destination=circ&borrowernumber='
            . $first_patron->borrowernumber
            . '"]' )->click;
    is(
        $driver->get_title,
        sprintf(
            "Modify patron %s %s %s (%s) (%s) › Patrons › Koha",
            $first_patron->title, $first_patron->firstname, $first_patron->surname, $first_patron->cardnumber,
            $first_patron->category->description,
        ),
        'Page title is correct after following modification link'
    );

    $driver->get( $base_url . "/members/members-home.pl" );
    $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;

    clear_filters();
    $s->driver->find_element( '//*[@id="' . $table_id . '_wrapper"]//input[@class="dt-input"]' )
        ->send_keys('test_patron');
    sleep $DT_delay && $s->wait_for_ajax;
    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf(
            'Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 26,
            $total_number_of_patrons
        ),
        'Searching in standard brings back correct results'
    );

    $s->driver->find_element( '//table[@id="'
            . $table_id
            . '"]//th[@data-filter="libraries"]/select/option[@value="^'
            . $first_patron->library->branchcode
            . '$"]' )->click;
    sleep $DT_delay && $s->wait_for_ajax;
    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf(
            'Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 25,
            $total_number_of_patrons
        ),
        'Filtering on library works in combination with main search'
    );

    clear_filters();

    # And make sure all the patrons are present
    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'Showing 1 to %s of %s entries', $PatronsPerPage, $total_number_of_patrons ),
        'Resetting filters works as expected'
    );

    # Pattern terms must be split
    $s->fill_form( { 'search_patron_filter' => 'test patron' } );
    $s->submit_form;

    sleep $DT_delay && $s->wait_for_ajax;
    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf(
            'Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 27,
            $total_number_of_patrons
        )
    );
    $driver->find_element('//form[@class="patron_search_form"]//*[@class="btn btn-default clear_search"]')->click();
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;

    # Search on non-searchable attribute, we expect no result!
    $s->fill_form( { 'search_patron_filter' => 'test_attr_1' } );
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;

    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'No entries to show (filtered from %s total entries)', $total_number_of_patrons ),
        'Searching on a non-searchable attribute returns no results'
    );

    clear_filters();

    # Search on searchable attribute, we expect 2 patrons
    $s->fill_form( { 'search_patron_filter' => 'test_attr_2' } );
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;

    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'Showing 1 to %s of %s entries (filtered from %s total entries)', 2, 2, $total_number_of_patrons ),
        'Searching on a searchable attribute returns correct results'
    );

    clear_filters();

    $s->fill_form( { 'search_patron_filter' => 'test_attr_3' } );    # Terms must be split
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;

    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'Showing 1 to %s of %s entries (filtered from %s total entries)', 2, 2, $total_number_of_patrons ),
        'Searching on a searchable attribute returns correct results'
    );

    clear_filters();

    # Search on searchable attribute as specific field, we expect 2 patrons
    $s->fill_form( { 'search_patron_filter' => 'test_attr_4' } );
    $driver->find_element(
              '//form[@class="patron_search_form"]//*[@class="searchfieldstype_filter"]//option[@value="_ATTR_'
            . $attribute_type_searchable_not_default->code
            . '"]' )->click();
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;

    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'Showing 1 to %s of %s entries (filtered from %s total entries)', 2, 2, $total_number_of_patrons ),
        'Searching on a searchable attribute as a specific field returns correct results'
    );

    # Refine search and search for test_patron in all the data using the DT global search
    # No change in result expected, still 2 patrons
    $s->driver->find_element( '//*[@id="' . $table_id . '_wrapper"]//input[@class="dt-input"]' )
        ->send_keys('test_patron');
    sleep $DT_delay && $s->wait_for_ajax;
    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'Showing 1 to %s of %s entries (filtered from %s total entries)', 2, 2, $total_number_of_patrons ),
        'Refining with DataTables search works to further filter the original query'
    );

    # Adding the surname of the first patron in the "Name" column
    # We expect only 1 result
    $s->driver->find_element( '//table[@id="' . $table_id . '"]//input[@placeholder="Name search"]' )
        ->send_keys( $first_patron->surname );
    sleep $DT_delay && $s->wait_for_ajax;
    is(
        $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
        sprintf( 'Showing 1 to %s of %s entries (filtered from %s total entries)', 1, 1, $total_number_of_patrons ),
        'Refining with header filters works to further filter the original query'
    );

    subtest 'limited categories' => sub {

        plan tests => 1;

        $patron_category->replace_library_limits( [ $library->id ] );
        C4::Context->set_preference( 'PatronsPerPage', 5 );
        $driver->get( $base_url . "/members/members-home.pl" );
        clear_filters();
        $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
        $s->submit_form;
        sleep $DT_delay && $s->wait_for_ajax;
        is(
            $driver->find_element( '//div[@id="' . $table_id . '_info"]' )->get_text,
            sprintf(
                'Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 26,
                $total_number_of_patrons
            ),
            'Search works when category of patrons is limited to a library we are not signed in at'
        );

    };

    subtest 'remember_search' => sub {

        plan tests => 7;

        C4::Context->set_preference( 'PatronsPerPage', 5 );
        $driver->get( $base_url . "/members/members-home.pl" );
        clear_filters();
        $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
        $s->submit_form;
        sleep $DT_delay && $s->wait_for_ajax;
        my $patron_selected_text = $driver->find_element('//div[@id="table_search_selections"]/span')->get_text;
        is( $patron_selected_text, "", "Patrons selected is not displayed" );

        my @checkboxes = $driver->find_elements('//input[@type="checkbox"][@name="borrowernumber"]');
        $checkboxes[2]->click;
        $patron_selected_text = $driver->find_element('//div[@id="table_search_selections"]/span')->get_text;
        is( $patron_selected_text, "Patrons selected: 1", "One patron selected" );

        $checkboxes[4]->click;
        $patron_selected_text = $driver->find_element('//div[@id="table_search_selections"]/span')->get_text;
        is( $patron_selected_text, "Patrons selected: 2", "Two patrons are selected" );

        $driver->find_element('//*[@id="memberresultst_wrapper"]//button[@class="dt-paging-button next"]')->click;
        sleep $DT_delay && $s->wait_for_ajax;
        @checkboxes = $driver->find_elements('//input[@type="checkbox"][@name="borrowernumber"]');
        $checkboxes[0]->click;
        $patron_selected_text = $driver->find_element('//div[@id="table_search_selections"]/span')->get_text;
        is( $patron_selected_text, "Patrons selected: 3", "Three patrons are selected" );

        # Perform another search
        $driver->get( $base_url . "/members/members-home.pl" );
        clear_filters();
        $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
        $s->submit_form;
        sleep $DT_delay && $s->wait_for_ajax;
        $patron_selected_text = $driver->find_element('//div[@id="table_search_selections"]/span')->get_text;
        is( $patron_selected_text, "Patrons selected: 3", "Three patrons still selected" );

        $driver->find_element('//*[@id="patronlist-menu"]')->click;
        $driver->find_element('//a[@class="patron-list-add dropdown-item"]')->click;
        my $patron_list_name = "my new list";
        $driver->find_element('//input[@id="new_patron_list"]')->send_keys($patron_list_name);
        $driver->find_element('//button[@id="add_to_patron_list_submit"]')->click;
        sleep $DT_delay && $s->wait_for_ajax;
        is( $driver->find_element('//*[@id="patron_list_dialog"]')->get_text, "Added 3 patrons to $patron_list_name." );
        my $patron_list = $schema->resultset('PatronList')->search( { name => $patron_list_name } )->next;
        is(
            $schema->resultset('PatronListPatron')->search( { patron_list_id => $patron_list->patron_list_id } )->count,
            3
        );

        $patron_list->delete;
    };

    subtest 'filter by date of birth' => sub {
        plan tests => 7;

        C4::Context->set_preference( 'dateformat', 'metric' );

        sub get_dob_search_filter {
            return $s->driver->find_element(
                '//table[@id="' . shift . '"]//th[@aria-label="Date of birth: Activate to sort"]/input' );
        }

        # We have a patron with date of birth=1980-06-17 => formatted as 17/06/1980

        $driver->get( $base_url . "/members/members-home.pl" );
        clear_filters();
        $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
        $s->submit_form;
        sleep $DT_delay && $s->wait_for_ajax;

        $s->show_all_entries( '//div[@id="' . $table_id . '_wrapper"]' );

        get_dob_search_filter($table_id)->send_keys('1980');
        sleep $DT_delay && $s->wait_for_ajax;
        my $patron_27 = Koha::Patrons->search( { surname => 'test_patron_27' } )->next;
        is( is_patron_shown($patron_27), 1, 'search by correct year shows the patron' );
        get_dob_search_filter($table_id)->clear;

        get_dob_search_filter($table_id)->send_keys('1986');
        sleep $DT_delay && $s->wait_for_ajax;
        is( is_patron_shown($patron_27), 0, 'search by incorrect year does not show the patron' );
        get_dob_search_filter($table_id)->clear;

        get_dob_search_filter($table_id)->send_keys('1980-06');
        sleep $DT_delay && $s->wait_for_ajax;
        is( is_patron_shown($patron_27), 1, 'search by correct year-month shows the patron' );
        get_dob_search_filter($table_id)->clear;

        get_dob_search_filter($table_id)->send_keys('1980-06-17');
        sleep $DT_delay && $s->wait_for_ajax;
        is( is_patron_shown($patron_27), 1, 'search by correct full iso date shows the patron' );
        get_dob_search_filter($table_id)->clear;

        get_dob_search_filter($table_id)->send_keys('1986-06-17');
        sleep $DT_delay && $s->wait_for_ajax;
        is( is_patron_shown($patron_27), 0, 'search by incorrect full iso date does not show the patron' );
        get_dob_search_filter($table_id)->clear;

        get_dob_search_filter($table_id)->send_keys('17/06/1980');
        sleep $DT_delay && $s->wait_for_ajax;
        is( is_patron_shown($patron_27), 1, 'search by correct full formatted date shows the patron' );
        get_dob_search_filter($table_id)->clear;

        get_dob_search_filter($table_id)->send_keys('17/06/1986');
        sleep $DT_delay && $s->wait_for_ajax;
        is( is_patron_shown($patron_27), 0, 'search by incorrect full formatted date does not show the patron' );
        get_dob_search_filter($table_id)->clear;

    };

    subtest 'expired and restricted badges' => sub {
        plan tests => 5;

        my $patron_28 = Koha::Patrons->search( { surname => 'test_expired_patron_surname' } )->next;

        $driver->get( $base_url . "/members/members-home.pl" );
        $s->fill_form( { 'searchmember' => 'test_expired_patron' } );

        sleep $DT_delay && $s->wait_for_ajax;

        like(
            $driver->find_element('//ul[@id="ui-id-2"]/li/a')->get_text,
            qr[\Qtest_expired_patron_surname\E],
            'test_expired_patron is shown'
        );

        is(
            $driver->find_element('//ul[@id="ui-id-2"]/li/a/span[@class="badge text-bg-warning"]')->get_text,
            'Expired',
            'Expired badge is shown'
        );

        $patron_28->dateexpiry('2999-12-01')->store;

        $driver->get( $base_url . "/members/members-home.pl" );
        $s->fill_form( { 'searchmember' => 'test_expired_patron' } );

        sleep $DT_delay && $s->wait_for_ajax;

        my @expired_badges = $driver->find_elements('//ul[@id="ui-id-2"]/li/a/span[@class="badge text-bg-warning"]');
        is(
            scalar @expired_badges, 0,
            'No expired badge is shown'
        );

        $patron_28->debarred('2048-11-18')->store;

        $driver->get( $base_url . "/members/members-home.pl" );
        $s->fill_form( { 'searchmember' => 'test_expired_patron' } );

        sleep $DT_delay && $s->wait_for_ajax;

        my @restricted_badges = $driver->find_elements('//ul[@id="ui-id-2"]/li/a/span[@class="badge text-bg-danger"]');
        is(
            $driver->find_element('//ul[@id="ui-id-2"]/li/a/span[@class="badge text-bg-danger"]')->get_text,
            'Restricted',
            'Restricted badge is shown'
        );

        $patron_28->dateexpiry('2000-12-01')->store;

        $driver->get( $base_url . "/members/members-home.pl" );
        $s->fill_form( { 'searchmember' => 'test_expired_patron' } );

        sleep $DT_delay && $s->wait_for_ajax;

        is(
            $driver->find_element('//ul[@id="ui-id-2"]/li/a/span[@class="badge text-bg-warning"]')->get_text,
            'Expired',
            'Both badges are shown'
        );
    };

    teardown();

};

subtest 'Search patrons in modal' => sub {
    plan tests => 2;

    setup();

    my $total_number_of_patrons = Koha::Patrons->search->count;

    $driver->set_window_size( 3840, 10800 );

    subtest 'Add guarantor - simple' => sub {
        plan tests => 4;

        my $table_id = "memberresultst";

        my $mainpage = $s->base_url . q|mainpage.pl|;
        $driver->get( $mainpage . q|?logout.x=1| );
        $s->auth;

        # Go to the add patron form
        $driver->get( $base_url . "/members/memberentry.pl" );

        # Click "Add guarantor"
        $driver->find_element('//a[@href="#patron_search_modal"]')->click();

        # Wait for the modal to be visible
        $s->wait_for_element_visible('//div[@id="patron_search_modal"]//div[@class="modal-header"]');

        # Search for our test patrons
        $s->fill_form( { 'search_patron_filter' => 'test_patron' } );
        $s->submit_form;
        sleep $DT_delay && $s->wait_for_ajax;

        # => the table is correctly displayed
        is(
            $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->get_text,
            sprintf(
                'Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 26,
                $total_number_of_patrons
            ),
            'Searching in standard brings back correct results'
        );

        # Search for patron 2 and display the patron preview modal
        my $patron = Koha::Patrons->search( { surname => 'test_patron_2' } )->next;
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="patron_name patron_preview"]',
            $patron->borrowernumber
        )->click;
        $s->wait_for_element_visible('//div[@id="patron_preview_modal"]');
        sleep $DT_delay && $s->wait_for_ajax;

        # => The modal has patron's detail in it
        is(
            $driver->find_element('//div[@id="patron_preview_modal"]//h1')->get_text(),
            sprintf(
                "%s %s %s (%s)",  $patron->title, $patron->firstname,
                $patron->surname, $patron->cardnumber
            ),
            'Patron preview modal has correct content'
        );

        # Close the patron preview modal
        $driver->find_element('//*[@id="patron_preview_modal"]/div[2]/fieldset/button')->click;

        $s->wait_for_element_hidden('//div[@id="patron_preview_modal"]');

        # Select patron 2
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="btn btn-default btn-xs select_user"]',
            $patron->borrowernumber
        )->click;

        # Wait for the modal to be hidden
        $s->wait_for_element_hidden('//div[@id="patron_search_modal"]//div[@class="modal-header"]');

        # => The guarantor block has the info of the selected patron
        is(
            $driver->find_element('//a[@class="new_guarantor_link"]')->get_text(),
            sprintf( "%s %s (%s)", $patron->firstname, $patron->surname, $patron->cardnumber ),
            'Guarantor block contains info of selected patron'
        );
        is(
            $driver->find_element('//input[@class="new_guarantor_id noEnterSubmit"]')->get_value(),
            $patron->borrowernumber
        );

    };

    subtest 'Add funds - double' => sub {
        plan tests => 11;

        my $table_id = "patron_search_modal_owner_table";

        my $mainpage = $s->base_url . q|mainpage.pl|;
        $driver->get( $mainpage . q|?logout.x=1| );
        $s->auth;

        # Go to the add patron form
        my $fund = $builder->build_object( { class => 'Koha::Acquisition::Funds' } );
        push @cleanup, $fund->budget, $fund;
        $driver->get(
            $base_url . sprintf "/admin/aqbudgets.pl?op=add_form&budget_id=%s&budget_period_id=%s",
            $fund->budget_id, $fund->budget_period_id
        );

        # Click "Select owner"
        $driver->find_element('//a[@href="#patron_search_modal_owner"]')->click();

        # Add { acquisition => budget_modify } subpermission to some patrons
        my $dbh     = C4::Context->dbh;
        my $patrons = Koha::Patrons->search( { surname => { like => 'test_patron_2%' } } );
        while ( my $patron = $patrons->next ) {
            $dbh->do(
                q{INSERT INTO user_permissions (borrowernumber, module_bit, code) VALUES (?, ?, ?)}, {},
                $patron->borrowernumber, 11, "budget_modify"
            );
        }

        # Wait for the modal to be visible
        $s->wait_for_element_visible('//div[@id="patron_search_modal_owner"]//div[@class="modal-header"]');

        # Search for our test patrons
        $driver->find_element('//div[@id="patron_search_modal_owner"]//input[@class="search_patron_filter focus"]')
            ->send_keys('test_patron');
        $driver->find_element('//div[@id="patron_search_modal_owner"]//input[@type="submit"]')->click;

        sleep $DT_delay && $s->wait_for_ajax;

        # => the table is correctly displayed
        is(
            $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->is_displayed,
            1,
        );

        # Search for patron 2 and display the patron preview modal
        my $patron = Koha::Patrons->search( { surname => 'test_patron_2' } )->next;
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="patron_name patron_preview"]',
            $patron->borrowernumber
        )->click;
        $s->wait_for_element_visible('//div[@id="patron_preview_modal"]');
        sleep $DT_delay && $s->wait_for_ajax;

        # => The modal has patron's detail in it
        is(
            $driver->find_element('//div[@id="patron_preview_modal"]//h1')->get_text(),
            sprintf(
                "%s %s %s (%s)",  $patron->title, $patron->firstname,
                $patron->surname, $patron->cardnumber
            )
        );

        # Close the patron preview modal
        $driver->find_element('//*[@id="patron_preview_modal"]/div[2]/fieldset/button')->click;
        $s->wait_for_element_hidden('//div[@id="patron_preview_modal"]');

        # Select patron 2
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="btn btn-default btn-xs select_user"]',
            $patron->borrowernumber
        )->click;

        # Wait for the modal to be hidden
        $s->wait_for_element_hidden('//div[@id="patron_search_modal"]//div[@class="modal-header"]');

        # => The block has the info of the selected patron
        is(
            $driver->find_element('//span[@id="budget_owner_name"]')->get_text(),
            sprintf( "%s %s", $patron->firstname, $patron->surname )
        );
        is(
            $driver->find_element('//input[@id="budget_owner_id"]')->get_value(),
            $patron->borrowernumber
        );

        $table_id = "patron_search_modal_users_table";

        # Click "Add users"
        $driver->find_element('//a[@href="#patron_search_modal_users"]')->click();

        # Wait for the modal to be visible
        $s->wait_for_element_visible('//div[@id="patron_search_modal_users"]//div[@class="modal-header"]');

        # Search for our test patrons
        $driver->find_element('//div[@id="patron_search_modal_users"]//input[@class="search_patron_filter focus"]')
            ->send_keys('test_patron');
        $driver->find_element('//div[@id="patron_search_modal_users"]//input[@type="submit"]')->click;

        sleep $DT_delay && $s->wait_for_ajax;

        # => the table is correctly displayed
        is(
            $driver->find_element( '//div[@id="' . $table_id . '_wrapper"]//div[@class="dt-info"]' )->is_displayed,
            1,
        );

        # Search for patron 2 and display the patron preview modal
        $patron = Koha::Patrons->search( { surname => 'test_patron_2' } )->next;
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="patron_name patron_preview"]',
            $patron->borrowernumber
        )->click;
        $s->wait_for_element_visible('//div[@id="patron_preview_modal"]');
        sleep $DT_delay && $s->wait_for_ajax;

        # => The modal has patron's detail in it
        is(
            $driver->find_element('//div[@id="patron_preview_modal"]//h1')->get_text(),
            sprintf(
                "%s %s %s (%s)",  $patron->title, $patron->firstname,
                $patron->surname, $patron->cardnumber
            )
        );

        # Close the patron preview modal
        $driver->find_element('//*[@id="patron_preview_modal"]/div[2]/fieldset/button')->click;
        $s->wait_for_element_hidden('//div[@id="patron_preview_modal"]');

        # Select patron 2
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="btn btn-default btn-xs add_user"]',
            $patron->borrowernumber
        )->click;

        # The modal is still displayed
        is(
            $driver->find_element('//div[@id="patron_search_modal_users"]//div[@class="modal-header"]')->is_displayed,
            1,
        );

        # Info has been added about the patron
        is(
            $driver->find_element('//div[@id="patron_search_modal_users"]//div[@class="info alert alert-info"]')
                ->get_text,
            sprintf( "Patron '%s %s' added.", $patron->firstname, $patron->surname )
        );

        # Select patron 2 again
        $driver->find_element(
            sprintf '//a[@data-borrowernumber="%s"][@class="btn btn-default btn-xs add_user"]',
            $patron->borrowernumber
        )->click;

        # Warning has been added about the patron
        is(
            $driver->find_element('//div[@id="patron_search_modal_users"]//div[@class="error alert alert-warning"]')
                ->get_text,
            sprintf( "Patron '%s %s' is already in the list.", $patron->firstname, $patron->surname )
        );

        # Click "Close"
        $driver->find_element('//div[@id="patron_search_modal_users"]//div[@class="modal-footer"]//a')->click,

            # The modal is closed
            if (
            $driver->find_element('//div[@id="patron_search_modal_users"]//div[@class="modal-header"]')->is_displayed,
            0,
            );

        # => The block has the info of the selected patron
        is(
            $driver->find_element( sprintf '//*[@id="budget_users"]/*[@id="user_%s"]/a', $patron->borrowernumber )
                ->get_text(),
            sprintf( "%s %s", $patron->firstname, $patron->surname )
        );
        is(
            $driver->find_element('//input[@id="budget_users_id"]')->get_value(),
            sprintf( ":%s", $patron->borrowernumber ),    # FIXME There is an extra ':' here
        );
    };

    teardown();

};

sub is_patron_shown {
    my ($patron) = @_;

    my @checkboxes = $driver->find_elements('//input[@type="checkbox"][@name="borrowernumber"]');
    return scalar( grep { $_->get_value == $patron->borrowernumber } @checkboxes );
}

sub clear_filters {
    $driver->find_element('//form[@class="patron_search_form"]//*[@class="btn btn-default clear_search"]')->click();
    $s->submit_form;
    sleep $DT_delay && $s->wait_for_ajax;
}
