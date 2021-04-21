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

use utf8;
use Test::More tests => 1;
use Test::MockModule;

use C4::Context;
use Koha::AuthUtils;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

eval { require Selenium::Remote::Driver; };
skip "Selenium::Remote::Driver is needed for selenium tests.", 1 if $@;

my $s             = t::lib::Selenium->new;
my $driver        = $s->driver;
my $opac_base_url = $s->opac_base_url;
my $base_url      = $s->base_url;
my $builder       = t::lib::TestBuilder->new;

our @cleanup;
subtest 'Search patrons' => sub {
    plan tests => 12;

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

    $s->auth;
    C4::Context->set_preference('DefaultPatronSearchFields',"");
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
    $s->fill_form( { searchmember_filter => 'test_patron' } );
    $s->submit_form;
    my $first_patron = $patrons[0];

    my @td = $driver->find_elements('//table[@id="memberresultst"]/tbody/tr/td');
    like ($td[2]->get_text, qr[\Q$firstname\E],
        'Column "Name" should be the 3rd and contain the firstname correctly filtered'
    );
    like ($td[2]->get_text, qr[\Q$address\E],
        'Column "Name" should be the 3rd and contain the address correctly filtered'
    );
    like ($td[2]->get_text, qr[\Q$email\E],
        'Column "Name" should be the 3rd and contain the email address correctly filtered'
    );
    is( $td[5]->get_text, $branchname,
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
    push @cleanup, $_ for @patrons;
    push @cleanup, $library;
    push @cleanup, $patron_category;
    C4::Context->set_preference('DefaultPatronSearchFields',$default_patron_search_fields);

    $driver->quit();
};

END {
    $_->delete for @cleanup;
}
