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

our @cleanup;
END {
    unless ( @cleanup ) { say "WARNING: Cleanup failed!" }
    $_->delete for @cleanup;
};

use C4::Context;

use utf8;
use Test::More;
use Test::MockModule;

use C4::Context;
use Koha::AuthUtils;
use Koha::Patrons;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

eval { require Selenium::Remote::Driver; };
if ( $@ ) {
    plan skip_all => "Selenium::Remote::Driver is needed for selenium tests.";
} else {
    plan tests => 1;
}


my $s             = t::lib::Selenium->new;
my $driver        = $s->driver;
my $opac_base_url = $s->opac_base_url;
my $base_url      = $s->base_url;
my $builder       = t::lib::TestBuilder->new;

subtest 'Search patrons' => sub {
    plan tests => 17;

    if ( Koha::Patrons->search({surname => {-like => "test_patron_%"}})->count ) {
        BAIL_OUT("Cannot run this test, data we need to create already exist in the DB");
    }
    my @patrons;
    my $borrowernotes           = q|<strong>just 'a" note</strong> \123 ❤|;
    my $borrowernotes_displayed = q|just 'a" note \123 ❤|;
    my $branchname = q|<strong>just 'another" library</strong> \123 ❤|;
    my $firstname  = q|<strong>fir's"tname</strong> \123 ❤|;
    my $address    = q|<strong>add'res"s</strong> \123 ❤|;
    my $email      = q|a<strong>bad_email</strong>@example\123 ❤.com|;
    my $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'A' }
        }
    );
    my $library = $builder->build_object(
        { class => 'Koha::Libraries', value => { branchname => $branchname } }
    );
    my $default_patron_search_fields = C4::Context->preference('DefaultPatronSearchFields');
    my $default_patron_per_page = C4::Context->preference('PatronsPerPage');
    for my $i ( 1 .. 25 ) {
        push @patrons,
          $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    surname       => "test_patron_" . $i++,
                    firstname     => $firstname,
                    categorycode  => $patron_category->categorycode,
                    branchcode    => $library->branchcode,
                    borrowernotes => $borrowernotes,
                    address       => $address,
                    email         => $email,
                }
            }
          );
    }
    my $library_2 = $builder->build_object(
        { class => 'Koha::Libraries', value => { branchname => 'X' . $branchname } }
    );
    push @patrons,
      $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname       => "test_patron_26",
                firstname     => $firstname,
                categorycode  => $patron_category->categorycode,
                branchcode    => $library_2->branchcode,
                borrowernotes => $borrowernotes,
                address       => $address,
                email         => $email,
            }
        }
      );

    my $attribute_type = Koha::Patron::Attribute::Type->new(
        {
            code        => 'my code1',
            description => 'my description1',
        }
    )->store;
    my $attribute_type_searchable = Koha::Patron::Attribute::Type->new(
        {
            code             => 'my code2',
            description      => 'my description2',
            opac_display     => 1,
            staff_searchable => 1
        }
    )->store;
    $patrons[0]->extended_attributes([
        { code => $attribute_type->code, attribute => 'test_attr_1' },
        { code => $attribute_type_searchable->code, attribute => 'test_attr_2'},
    ]);
    $patrons[1]->extended_attributes([
        { code => $attribute_type->code, attribute => 'test_attr_1' },
        { code => $attribute_type_searchable->code, attribute => 'test_attr_2'},
    ]);

    my $total_number_of_patrons = Koha::Patrons->search->count;
    my $table_id = "memberresultst";

    $s->auth;
    C4::Context->set_preference('DefaultPatronSearchFields',"");
    my $PatronsPerPage = 15;
    C4::Context->set_preference('PatronsPerPage', $PatronsPerPage);
    $driver->get( $base_url . "/members/members-home.pl" );
    my @adv_options = $driver->find_elements('//select[@id="searchfieldstype"]/option');
    my @filter_options = $driver->find_elements('//select[@id="searchfieldstype_filter"]/option');
    is( scalar @adv_options, 11, 'All standard fields are searchable if DefaultPatronSearchFields not set');
    is( scalar @filter_options, 11, 'All standard fields are searchable by filter if DefaultPatronSearchFields not set');
    C4::Context->set_preference('DefaultPatronSearchFields',"initials");
    $driver->get( $base_url . "/members/members-home.pl" );
    @adv_options = $driver->find_elements('//select[@id="searchfieldstype"]/option');
    @filter_options = $driver->find_elements('//select[@id="searchfieldstype_filter"]/option');
    is( scalar @adv_options, 12, 'New option added when DefaultPatronSearchFields is populated with a field');
    is( scalar @filter_options, 12, 'New filter option added when DefaultPatronSearchFields is populated with a field');
    C4::Context->set_preference('DefaultPatronSearchFields',"initials,horses");
    $driver->get( $base_url . "/members/members-home.pl" );
    @adv_options = $driver->find_elements('//select[@id="searchfieldstype"]/option');
    @filter_options = $driver->find_elements('//select[@id="searchfieldstype_filter"]/option');
    is( scalar @adv_options, 12, 'Invalid option not added when DefaultPatronSearchFields is populated with an invalid field');
    is( scalar @filter_options, 12, 'Invalid filter option not added when DefaultPatronSearchFields is populated with an invalid field');
    C4::Context->set_preference('DefaultPatronSearchFields',"");
    $s->fill_form( { search_patron_filter => 'test_patron' } );
    $s->submit_form;
    my $first_patron = $patrons[0];

    $s->wait_for_ajax;
    my @td = $driver->find_elements('//table[@id="'.$table_id.'"]/tbody/tr/td');
    like ($td[2]->get_text, qr[\Q$firstname\E],
        'Column "Name" should be the 3rd and contain the firstname correctly filtered'
    );
    like ($td[2]->get_text, qr[\Q$address\E],
        'Column "Name" should be the 3rd and contain the address correctly filtered'
    );
    like ($td[2]->get_text, qr[\Q$email\E],
        'Column "Name" should be the 3rd and contain the email address correctly filtered'
    );
    is( $td[4]->get_text, $branchname,
        'Column "Library" should be the 6th and contain the html tags - they have been html filtered'
    );
    is( $td[9]->get_text, $borrowernotes_displayed,
        'Column "Circ note" should be the 10th and not contain the html tags - they have not been html filtered'
    );

    $driver->find_element(
            '//a[@href="/cgi-bin/koha/members/memberentry.pl?op=modify&destination=circ&borrowernumber='
          . $first_patron->borrowernumber
          . '"]' )->click;
    is(
        $driver->get_title,
        sprintf(
            "Modify patron %s %s (%s) %s (%s) (%s) › Patrons › Koha",
            $first_patron->title, $first_patron->firstname, $first_patron->othernames, $first_patron->surname, $first_patron->cardnumber,
            $first_patron->category->description,
        )
    );

    $driver->get( $base_url . "/members/members-home.pl" );
    $s->fill_form( { search_patron_filter => 'test_patron' } );
    $s->submit_form;
    $s->wait_for_ajax;

    $s->driver->find_element('//*[@id="'.$table_id.'_filter"]//input')->send_keys('test_patron');
    $s->wait_for_ajax;
    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 26, $total_number_of_patrons) );

    $s->driver->find_element('//table[@id="'.$table_id.'"]//th[@data-filter="libraries"]/select/option[@value="'.$library->branchcode.'"]')->click;
    $s->wait_for_ajax;
    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('Showing 1 to %s of %s entries (filtered from %s total entries)', $PatronsPerPage, 25, $total_number_of_patrons) );

    # Reset the filters
    $driver->find_element('//form[@id="patron_search_form"]//*[@id="clear_search"]')->click();
    $s->submit_form;
    $s->wait_for_ajax;

    # And make sure all the patrons are present
    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('Showing 1 to %s of %s entries', $PatronsPerPage, $total_number_of_patrons) );

    # Search on non-searchable attribute, we expect no result!
    $s->fill_form( { search_patron_filter => 'test_attr_1' } );
    $s->submit_form;
    $s->wait_for_ajax;

    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('No entries to show (filtered from %s total entries)', $total_number_of_patrons) );

    # clear form
    $driver->find_element('//form[@id="patron_search_form"]//*[@id="clear_search"]')->click();
    # Search on searchable attribute, we expect 2 patrons
    $s->fill_form( { search_patron_filter => 'test_attr_2' } );
    $s->submit_form;
    $s->wait_for_ajax;

    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('Showing 1 to %s of %s entries (filtered from %s total entries)', 2, 2, $total_number_of_patrons) );

    # Refine search and search for test_patron in all the data using the DT global search
    # No change in result expected, still 2 patrons
    $s->driver->find_element('//*[@id="'.$table_id.'_filter"]//input')->send_keys('test_patron');
    $s->wait_for_ajax;
    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('Showing 1 to %s of %s entries (filtered from %s total entries)', 2, 2, $total_number_of_patrons) );

    # Adding the surname of the first patron in the "Name" column
    # We expect only 1 result
    $s->driver->find_element('//table[@id="'.$table_id.'"]//input[@placeholder="Name search"]')->send_keys($patrons[0]->surname);
    $s->wait_for_ajax;
    is( $driver->find_element('//div[@id="'.$table_id.'_info"]')->get_text, sprintf('Showing 1 to %s of %s entries (filtered from %s total entries)', 1, 1, $total_number_of_patrons) );

    push @cleanup, $_ for @patrons;
    push @cleanup, $library;
    push @cleanup, $library_2;
    push @cleanup, $patron_category;
    push @cleanup, $attribute_type, $attribute_type_searchable;
    C4::Context->set_preference('DefaultPatronSearchFields',$default_patron_search_fields);
    C4::Context->set_preference('PatronsPerPage',$default_patron_per_page);

    $driver->quit();
};
