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

use t::lib::Page::Opac::OpacSearch;
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
             userid     => 'mini_admin',
             password   => $password,
            },
        ], undef, $testContext);

##Test context set, starting testing:
eval { #run in a eval-block so we don't die without tearing down the test context

    my $opacsearch = t::lib::Page::Opac::OpacSearch->new();
    testAnonymousSearchHistory($opacsearch);

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

sub testAnonymousSearchHistory {
    my $opacsearch = shift;

    $opacsearch->doSetSearchFieldTerm(1, 'Author', 'nengard')->doSearchSubmit()->navigateAdvancedSearch()
               ->doSetSearchFieldTerm(1, 'Author', 'joubu')->doSearchSubmit()->navigateAdvancedSearch()
               ->doSetSearchFieldTerm(1, 'Author', 'khall')->doSearchSubmit()->navigateHome()
               ->doPasswordLogin($borrowers->{'1A01'}->userid, $password)->navigateAdvancedSearch()
               ->doSetSearchFieldTerm(1, 'Author', 'magnuse')->doSearchSubmit()->navigateAdvancedSearch()
               ->doSetSearchFieldTerm(1, 'Author', 'cait')->doSearchSubmit()->navigateSearchHistory()
               ->testDoSearchHistoriesExist(['nengard',
                                             'joubu',
                                             'khall',
                                             'magnuse',
                                             'cait'])
               ->quit();
}