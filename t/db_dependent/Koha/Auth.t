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

use Koha::Auth::PermissionManager;

use t::lib::Page::Mainpage;
use t::lib::Page::Opac::OpacMain;

use t::lib::TestObjects::PatronFactory;

##Enable debug mode for PageObject tests.
#$ENV{KOHA_PAGEOBJECT_DEBUG} = 1;

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
            {firstname  => 'Admin',
             surname    => 'Administrative',
             cardnumber => 'maxi_admin',
             branchcode => 'FPL',
             userid     => 'maxi_admin',
             password   => $password,
            },
        ], undef, $testContext);

my $permissionManager = Koha::Auth::PermissionManager->new();
$permissionManager->grantPermission($borrowers->{'1A01'}, 'catalogue', 'staff_login');
$permissionManager->grantPermission($borrowers->{'maxi_admin'}, 'superlibrarian', 'superlibrarian');

##Test context set, starting testing:
eval { #run in a eval-block so we don't die without tearing down the test context

    my $mainpage = t::lib::Page::Mainpage->new();
    testBadPasswordLogin($mainpage);
    testPasswordLoginLogout($mainpage);
    testSuperuserPasswordLoginLogout($mainpage);
    testSuperlibrarianPasswordLoginLogout($mainpage);
    $mainpage->quit();

    my $opacmain = t::lib::Page::Opac::OpacMain->new();
    testBadPasswordLogin($opacmain);
    testOpacPasswordLoginLogout($opacmain);
    testSuperuserPasswordLoginLogout($opacmain);
    testOpacSuperlibrarianPasswordLoginLogout($opacmain);
    $opacmain->quit();
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

sub testBadPasswordLogin {
    my ($mainpage) = @_;
    $mainpage->isPasswordLoginAvailable()->failPasswordLogin($borrowers->{'1A01'}->userid(), 'a truly bad password')
             ->refresh() #Refresh is important in bringing out certain bugs with cookies and misset Userid.
             ->isPasswordLoginAvailable();
}
sub testPasswordLoginLogout {
    my ($mainpage) = @_;
    $mainpage->isPasswordLoginAvailable()->doPasswordLogin($borrowers->{'1A01'}->userid(), $password)
             ->isLoggedInBranchCode($borrowers->{'1A01'}->branchcode())
             ->doPasswordLogout();
}
sub testOpacPasswordLoginLogout {
    my ($mainpage) = @_;
    $mainpage->isPasswordLoginAvailable()->doPasswordLogin($borrowers->{'1A01'}->userid(), $password)
             ->doPasswordLogout();
}
sub testSuperuserPasswordLoginLogout {
    my ($mainpage) = @_;
    $mainpage->isPasswordLoginAvailable()->doPasswordLogin(C4::Context->config('user'), C4::Context->config('pass'))
             ->doPasswordLogout();
}
sub testSuperlibrarianPasswordLoginLogout {
    my ($mainpage) = @_;
    $mainpage->isPasswordLoginAvailable()->doPasswordLogin($borrowers->{'maxi_admin'}->userid(), $password)
             ->isLoggedInBranchCode($borrowers->{'maxi_admin'}->branchcode())
             ->doPasswordLogout();
}
sub testOpacSuperlibrarianPasswordLoginLogout {
    my ($mainpage) = @_;
    $mainpage->isPasswordLoginAvailable()->doPasswordLogin($borrowers->{'maxi_admin'}->userid(), $password)
             ->doPasswordLogout();
}
