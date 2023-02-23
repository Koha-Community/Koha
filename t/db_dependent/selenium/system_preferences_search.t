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

use Koha::AuthUtils;
use Test::More;

use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

eval { require Selenium::Remote::Driver; };
if ( $@ ) {
    plan skip_all => "Selenium::Remote::Driver is needed for Selenium tests.";
} else {
    plan tests => 1;
}

my @cleanup;

my $builder = t::lib::TestBuilder->new;

my $s        = t::lib::Selenium->new;
my $driver   = $s->driver;
my $base_url = $s->base_url;

# Adjust the height and width of the generated screenshots
#$driver->set_window_size( 2160, 991 ); # Height, then Width

my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
my $password = Koha::AuthUtils::generate_password( $patron->category );
t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
$patron->set_password( { password => $password } );

push @cleanup, $patron, $patron->category, $patron->library;

$s->auth( $patron->userid, $password );

subtest 'Perform a system preferences search for "log", and try to expand/collapse both "Policy" sections that appear' => sub {

    plan tests => 6;

    $driver->get( $base_url . 'admin/preferences.pl?tab=&op=search&searchfield=log' );
    #$driver->capture_screenshot( 'Selenium_00.png' );

    my $xpath_v1_expr1 = '//h3[@id="accounting_Policy"]';

    # The first "Policy" section should be under the "Accounting" preferences top-level section and be initially expanded
    my $first_policy_section_toggle_elt = $driver->find_element( $xpath_v1_expr1 );
    is( $first_policy_section_toggle_elt->get_attribute( 'class' , 1 ), 'expanded', 'The first "Policy" section (under "Accounting") is currently expanded' );

    # Clicking on the expand/collapse button should collapse this section
    $first_policy_section_toggle_elt->click;
    #$driver->capture_screenshot( 'Selenium_01.png' );
    is( $first_policy_section_toggle_elt->get_attribute( 'class' , 1 ), 'collapsed', 'The first "Policy" section (under "Accounting") is now collapsed' );

    # Clicking on the expand/collapse button once more should expand this section back to its original state
    $first_policy_section_toggle_elt->click;
    #$driver->capture_screenshot( 'Selenium_02.png' );
    is( $first_policy_section_toggle_elt->get_attribute( 'class' , 1 ), 'expanded', 'The first "Policy" section (under "Accounting") is back to the expanded state' );

    my $xpath_v1_expr2 = '//h3[@id="acquisitions_Policy"]';

    # The second "Policy" section should be under the "Acquisitions" preferences top-level section and be initially expanded
    my $second_policy_section_toggle_elt = $driver->find_element( $xpath_v1_expr2 );
    is( $second_policy_section_toggle_elt->get_attribute( 'class' , 1 ), 'expanded', 'The second "Policy" section (under "Acquisitions") is currently expanded' );

    # Clicking on the expand/collapse button should collapse this section
    $second_policy_section_toggle_elt->click;
    #$driver->capture_screenshot( 'Selenium_03.png' );
    is( $second_policy_section_toggle_elt->get_attribute( 'class' , 1 ), 'collapsed', 'The second "Policy" section (under "Acquisitions") is now collapsed' );

    # Clicking on the expand/collapse button once more should expand this section back to its original state
    $second_policy_section_toggle_elt->click;
    #$driver->capture_screenshot( 'Selenium_04.png' );
    is( $second_policy_section_toggle_elt->get_attribute( 'class' , 1 ), 'expanded', 'The second "Policy" section (under "Acquisitions") is back to the expanded state' );

};

# Delete the test patron
END {
    $_->delete for @cleanup;
};
