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

use Test::More tests => 1;

use Koha::AuthUtils;
use t::lib::Selenium;
use t::lib::TestBuilder;

eval { require Selenium::Remote::Driver; };
skip "Selenium::Remote::Driver is needed for selenium tests.", 1 if $@;

my $s = t::lib::Selenium->new;

my $driver = $s->driver;
my $base_url = $s->base_url;
my $builder = t::lib::TestBuilder->new;

our @cleanup;
subtest 'OPAC - borrowernumber and branchcode as html attributes' => sub {
    plan tests => 2;

    my $patron = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password = Koha::AuthUtils::generate_password();
    my $digest   = Koha::AuthUtils::hash_password($password);
    $patron->update_password( $patron->userid, $digest );
    $s->opac_auth( $patron->userid, $password );
    my $elt = $driver->find_element('//span[@class="loggedinusername"]');
    is( $elt->get_attribute('data-branchcode'), $patron->library->branchcode,
        "Since bug 20921 span.loggedinusername should contain data-branchcode"
    );
    is( $elt->get_attribute('data-borrowernumber'), $patron->borrowernumber,
"Since bug 20921 span.loggedinusername should contain data-borrowernumber"
    );
    push @cleanup, $patron;
    push @cleanup, $patron->category;
    push @cleanup, $patron->library;
};

END {
    $_->delete for @cleanup;
};
