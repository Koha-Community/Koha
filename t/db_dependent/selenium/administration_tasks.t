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

#This selenium test tests the Koha Administration module functionality including adding circ rules, item types and modifying frameworks

#Note: If you are testing this on kohadevbox with selenium installed in kohadevbox then you need to set the staffClientBaseURL to localhost:8080 and the OPACBaseURL to http://localhost:80

use Modern::Perl;

use C4::Context;

use Test::More tests => 1;

use t::lib::Selenium;

my $login = $ENV{KOHA_USER} || 'koha';

my $itemtype      = 'UT_DVD';
my $frameworkcode = 'UTFW';     # frameworkcode is only 4 characters max!
my $branchcode    = 'UT_BC';
my $categoryname = 'Test';
our ($cleanup_needed);

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 1 if $@;

    $cleanup_needed = 1;

    my $s        = t::lib::Selenium->new;
    my $driver   = $s->driver;
    my $mainpage = $s->base_url . q|mainpage.pl|;
    $driver->get($mainpage);
    like( $driver->get_title(), qr(Log in to Koha), );
    $s->auth;
    { # Item types
        # Navigate to the Administration area and create an item type
        $s->click( { href => '/admin/admin-home.pl', main => 'doc3' } )
          ;    # Koha administration
        $s->click( { href => '/admin/itemtypes.pl', main => 'doc' } );  # Item Types
        $s->click( { href => '/admin/itemtypes.pl?op=add_form', main => 'doc3' } )
          ;    # New item type
        $s->fill_form(
            { itemtype => $itemtype, description => "Digital Optical Disc" } );
        $s->submit_form;
        $s->click(
            {
                href => '/admin/itemtypes.pl?op=add_form&itemtype=' . $itemtype,
                main => 'doc3'
            }
        );     # New item type
    };

    { # Circulation/fine rules
        $driver->get($mainpage);
        $s->click( { href => '/admin/admin-home.pl', main => 'doc3' } )
          ;    # Koha administration
        $s->click( { href => '/admin/smart-rules.pl', main => 'doc' } )
          ;    # Circulation and fines rules
               # TODO Create smart navigation here
    };

    { # Biblio frameworks
        $driver->get($mainpage);
        $s->click( { href => '/admin/admin-home.pl', main => 'doc3' } )
          ;    # Koha administration
        $s->click( { href => '/admin/biblio_framework.pl', main => 'doc' } )
          ;    # MARC bibliographic framework
        $s->click(
            { href => '/admin/biblio_framework.pl?op=add_form', main => 'doc3' } )
          ;    # New framework
        $s->fill_form(
            {
                frameworkcode => $frameworkcode,
                description   => 'just a description'
            }
        );
        $s->submit_form;
        $s->click( { id => 'frameworkactions' . $frameworkcode } );
        $s->click(
            {
                href => 'marctagstructure.pl?frameworkcode=' . $frameworkcode,
                main => 'doc3'
            }
        );    # MARC structure # FIXME '/admin/' is missing in the url
              # TODO Click on OK to create the MARC structure
    };

    { #Libraries
        $driver->get($mainpage);
        $s->click( { href => '/admin/admin-home.pl', main => 'doc3' } )
          ;    # Koha administration
        $s->click( { href => '/admin/branches.pl', main => 'doc' } )
          ;    # Libraries and groups
        $s->click( { href => '/admin/branches.pl?op=add_form', main => 'doc3' } )
          ;    # New library
        $s->fill_form( { branchcode => $branchcode, branchname => 'my library' } );
        $s->submit_form;
        $s->click(
            {
                href => '/admin/branches.pl?op=add_form&branchcode=' . $branchcode,
                main => 'doc3'
            }
        );     # Edit
        $s->fill_form( { branchname => 'another branchname' } );
        $s->submit_form;
        $s->click(
            {
                href => '/admin/branches.pl?op=delete_confirm&branchcode='. $branchcode,
                main => 'doc3'
            }
        );     # Delete
    };

    { #Authorized values
        $driver->get($mainpage);
        $s->click( { href => '/admin/admin-home.pl', main => 'doc3' } ); #Koha administration

        $s->click( { href => '/admin/authorised_values.pl', main => 'doc' } ); #Authorized values

        $s->click( { href => '/cgi-bin/koha/admin/authorised_values.pl?op=add_form&category=Adult', main => 'doc3' } ); # New category
        $s->fill_form( { authorised_value => 'Hardover', lib => 'Hardcover book'} );
        $s->submit_form;

        $s->click(
            {
                href => '/cgi-bin/koha/admin/authorised_values.pl?op=delete&searchfield=Adult&id=400',
                main => 'doc3'
            }
        );
    };

    { #Patron categories
        $driver->get($mainpage);
        $s->click( { href => '/cgi-bin/koha/admin/categories.pl', main => 'doc3' } ); #Koha administration
        $s->click( { href => '/cgi-bin/koha/admin/categories.pl?op=add_form', main => 'doc' } ); #New patron category

        $s->fill_form( { categorycode => 'Test', description => 'Test category', enrolmentperiod => 12, category_type => 'Adult' } );
        $s->submit_form;

        $s->click(
            {
                href => '/cgi-bin/koha/admin/categories.pl?op=delete_confirm&categorycode=TEST',
                main => 'doc3'
            }
        );
    };

    $driver->quit();
}

END {
    cleanup() if $cleanup_needed;
};

sub cleanup {
    my $dbh = C4::Context->dbh;
    $dbh->do(q|DELETE FROM itemtypes WHERE itemtype=?|, undef, $itemtype);
    $dbh->do(q|DELETE FROM biblio_framework WHERE frameworkcode=?|, undef, $frameworkcode);
    $dbh->do(q|DELETE FROM branches WHERE branchcode=?|, undef, $branchcode);
}
