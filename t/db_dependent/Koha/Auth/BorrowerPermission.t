#!/usr/bin/perl

# Copyright 2015 Vaara-kirjastot
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

use Koha::Auth::BorrowerPermission;
use Koha::Auth::BorrowerPermissions;

use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::PatronFactory;

##Setting up the test context
my $testContext = {};

my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
my $borrowers = $borrowerFactory->createTestGroup([
            {firstname  => 'Olli-Antti',
             surname    => 'Kivi',
             cardnumber => '1A01',
             branchcode => 'CPL',
            },
            {firstname  => 'Alli-Ontti',
             surname    => 'Ivik',
             cardnumber => '1A02',
             branchcode => 'CPL',
            },
        ], undef, $testContext);

##Test context set, starting testing:
eval { #run in a eval-block so we don't die without tearing down the test context
    ##Basic id-based creation.
    my $borrowerPermissionById = Koha::Auth::BorrowerPermission->new({borrowernumber => $borrowers->{'1A01'}->borrowernumber, permission_module_id => 1, permission_id => 1});
    $borrowerPermissionById->store();
    my @borrowerPermissionById = Koha::Auth::BorrowerPermissions->search({borrowernumber => $borrowers->{'1A01'}->borrowernumber});
    is(scalar(@borrowerPermissionById), 1, "BorrowerPermissions, id-based creation:> Borrower has only one permission");
    is($borrowerPermissionById[0]->permission_module_id, 1, "BorrowerPermissions, id-based creation:> Same permission_module_id");
    is($borrowerPermissionById[0]->permission_id, 1, "BorrowerPermissions, id-based creation:> Same permission_id");

    ##Basic name-based creation.
    my $borrowerPermissionByName = Koha::Auth::BorrowerPermission->new({borrowernumber => $borrowers->{'1A02'}->borrowernumber, permissionModule => 'circulate', permission => 'manage_restrictions'});
    $borrowerPermissionByName->store();
    my @borrowerPermissionByName = Koha::Auth::BorrowerPermissions->search({borrowernumber => $borrowers->{'1A02'}->borrowernumber});
    is(scalar(@borrowerPermissionByName), 1, "BorrowerPermissions, name-based creation:> Borrower has only one permission");
    is($borrowerPermissionByName[0]->getPermissionModule->module, 'circulate', "BorrowerPermissions, name-based creation:> Same permission_module");
    is($borrowerPermissionByName[0]->getPermission->code, 'manage_restrictions', "BorrowerPermissions, name-based creation:> Same permission");

    ##Testing setter/getter for Borrower
    my $borrower1A01 = $borrowerPermissionById->getBorrower();
    is($borrower1A01->cardnumber, "1A01", "BorrowerPermissions, setter/getter:> getBorrower() 1A01");
    my $borrower1A02 = $borrowerPermissionByName->getBorrower();
    is($borrower1A02->cardnumber, "1A02", "BorrowerPermissions, setter/getter:> getBorrower() 1A02");

    $borrowerPermissionById->setBorrower($borrower1A02);
    is($borrowerPermissionById->getBorrower()->cardnumber, "1A02", "BorrowerPermissions, setter/getter:> setBorrower() 1A02");
    $borrowerPermissionByName->setBorrower($borrower1A01);
    is($borrowerPermissionByName->getBorrower()->cardnumber, "1A01", "BorrowerPermissions, setter/getter:> setBorrower() 1A01");

    ##Testing getter for PermissionModule
    my $permissionModule1 = $borrowerPermissionById->getPermissionModule();
    is($permissionModule1->permission_module_id, 1, "BorrowerPermissions, setter/getter:> getPermissionModule() 1");
    my $permissionModuleCirculate = $borrowerPermissionByName->getPermissionModule();
    is($permissionModuleCirculate->module, "circulate", "BorrowerPermissions, setter/getter:> getPermissionModule() circulate");

    #Not testing setters because changing the module might not make any sense.
    #Then we would need to make sure we dont end up with bad permissionModule->permission combinations.

    ##Testing getter for Permission
    my $permission1 = $borrowerPermissionById->getPermission();
    is($permission1->permission_id, 1, "BorrowerPermissions, setter/getter:> getPermission() 1");
    my $permissionManage_restrictions = $borrowerPermissionByName->getPermission();
    is($permissionManage_restrictions->code, "manage_restrictions", "BorrowerPermissions, setter/getter:> getPermission() manage_restrictions");
};
if ($@) { #Catch all leaking errors and gracefully terminate.
    warn $@;
    tearDown();
    exit 1;
}

##All tests done, tear down test context
$borrowerFactory->tearDownTestContext($testContext);
done_testing;

sub tearDown {
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
}