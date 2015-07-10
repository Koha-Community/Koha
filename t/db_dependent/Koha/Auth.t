#!/usr/bin/env perl

# Copyright 2015 Open Source Freedom Fighters
#
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

use Test::More;
use Try::Tiny; #Even Selenium::Remote::Driver uses Try::Tiny :)

use t::lib::Page::Mainpage;

use t::lib::TestObjects::PatronFactory;

##Setting up the test context
my $testContext = {};

my $password = '1234';
my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
my $borrowers = $borrowerFactory->createTestGroup([
            {firstname  => 'Olli-Antti',
             surname    => 'Kivi',
             cardnumber => '1A01',
             branchcode => 'CPL',
             flags      => '1', #superlibrarian, not exactly a very good way of doing permission testing?
             userid     => 'mini_admin',
             password   => $password,
            },
        ], undef, $testContext);

##Test context set, starting testing:
eval { #run in a eval-block so we don't die without tearing down the test context

    testPasswordLogin();

};
if ($@) { #Catch all leaking errors and gracefully terminate.
    warn $@;
    tearDown();
    exit 1;
}

##All tests done, tear down test context
tearDown();
done_testing;

sub tearDown {
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}

######################################################
    ###  STARTING TEST IMPLEMENTATIONS         ###
######################################################

sub testPasswordLogin {
    my $mainpage = t::lib::Page::Mainpage->new();
    $mainpage->isPasswordLoginAvailable()->doPasswordLogin($borrowers->{'1A01'}->userid(), $password)->quit();
}