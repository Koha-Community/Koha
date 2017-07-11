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
use Try::Tiny;
use Scalar::Util qw(blessed);

use Koha::Auth::PermissionManager;

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
    my $permissionManager = Koha::Auth::PermissionManager->new();
    my ($permissionModule, $permission, $failureCaughtFlag, $permissionsList);

    ##Test getBorrowerPermissions
    $permissionManager->grantPermission($borrowers->{'1A01'}, 'circulate', 'force_checkout');
    $permissionManager->grantPermission($borrowers->{'1A01'}, undef, 'manage_restrictions');
    $permissionsList = $permissionManager->getBorrowerPermissions($borrowers->{'1A01'});
    is($permissionsList->[0]->getPermission->code, 'force_checkout', "PermissionManager, getBorrowerPermissions:> Check 1.");
    is($permissionsList->[1]->getPermission->code, 'manage_restrictions', "PermissionManager, getBorrowerPermissions:> Check 2.");
    $permissionManager->revokePermission($borrowers->{'1A01'}, undef, 'force_checkout');
    $permissionManager->revokePermission($borrowers->{'1A01'}, 'circulate', 'manage_restrictions');
    $permissionsList = $permissionManager->getBorrowerPermissions($borrowers->{'1A01'});
    is(@$permissionsList, 0, "PermissionManager, getBorrowerPermissions:> All revoked.");

    ##Test grantPermissions && revokeAllPermissions
    $permissionManager->grantPermissions($borrowers->{'1A01'},
                                         {  borrowers => 'view_borrowers',
                                            reserveforothers => ['place_holds'],
                                            tools => ['edit_news', 'edit_notices'],
                                            acquisition => {
                                              budget_add_del => 1,
                                              budget_modify => 1,
                                            },
                                        });
    $permissionManager->hasPermission($borrowers->{'1A01'}, 'borrowers', 'view_borrowers');
    $permissionManager->hasPermission($borrowers->{'1A01'}, 'tools', 'edit_notices');
    $permissionManager->hasPermission($borrowers->{'1A01'}, 'acquisition', 'budget_modify');
    $permissionsList = $permissionManager->getBorrowerPermissions($borrowers->{'1A01'});
    is(scalar(@$permissionsList), 6, "PermissionManager, grantPermissions:> Permissions as HASH, ARRAY and Scalar.");

    $permissionManager->revokeAllPermissions($borrowers->{'1A01'});
    $permissionsList = $permissionManager->getBorrowerPermissions($borrowers->{'1A01'});
    is(scalar(@$permissionsList), 0, "PermissionManager, revokeAllPermissions:> No permissions left.");

    ##Test listKohaPermissionsAsHASH
    my $listedPermissions = $permissionManager->listKohaPermissionsAsHASH();
    ok(ref($listedPermissions->{circulate}->{permissions}->{force_checkout}) eq 'HASH', "PermissionManager, listKohaPermissionsAsHASH:> Check 1.");
    ok(ref($listedPermissions->{editcatalogue}->{permissions}->{edit_catalogue}) eq 'HASH', "PermissionManager, listKohaPermissionsAsHASH:> Check 2.");
    ok(defined($listedPermissions->{reports}->{permissions}->{create_reports}->{description}), "PermissionManager, listKohaPermissionsAsHASH:> Check 3.");
    ok(defined($listedPermissions->{permissions}->{description}), "PermissionManager, listKohaPermissionsAsHASH:> Check 4.");



    ###   TESTING WITH unique keys, instead of the recommended Koha::Objects. ###
    #Arguably this makes for more clear tests cases :)
    ##Add/get PermissionModule
    $permissionModule = $permissionManager->addPermissionModule({module => 'test', description => 'Just testing this module.'});
    is($permissionModule->module, "test", "PermissionManager from names, add/getPermissionModule:> Module added.");
    $permissionModule = $permissionManager->getPermissionModule('test');
    is($permissionModule->module, "test", "PermissionManager from names, add/getPermissionModule:> Module got.");

    ##Add/get Permission
    $permission = $permissionManager->addPermission({module => 'test', code => 'testperm', description => 'Just testing this permission.'});
    is($permission->code, "testperm", "PermissionManager from names, add/getPermission:> Permission added.");
    $permission = $permissionManager->getPermission('testperm');
    is($permission->code, "testperm", "PermissionManager from names, add/getPermission:> Permission got.");

    ##Grant permission
    $permissionManager->grantPermission($borrowers->{'1A01'}, 'test', 'testperm');
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'test', 'testperm'), "PermissionManager from names, grant/hasPermission:> Borrower granted permission.");

    ##hasPermission with wildcard
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'test', '*'), "PermissionManager from names, hasPermission:> Wildcard permission.");

    ##hasPermissions with wildcard
    ok($permissionManager->hasPermissions($borrowers->{'1A01'}, {test => ['*']}), "PermissionManager from names, hasPermission:> Wildcard permissions from array.");

    ##Revoke permission
    $permissionManager->revokePermission($borrowers->{'1A01'}, 'test', 'testperm');
    $failureCaughtFlag = 0;
    try {
        $permissionManager->hasPermission($borrowers->{'1A01'}, 'test', 'testperm');
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::NoPermission')) {
            $failureCaughtFlag = 1;
        }
        else {
            die $_; #Somekind of another problem arised and rethrow it.
        }
    };
    ok($failureCaughtFlag, "PermissionManager from names, revoke/hasPermission:> Borrower revoked permission.");

    ##Delete permissions and modules we just made. When we delete the module first, the permissions is ON CASCADE DELETEd
    $permissionManager->delPermissionModule('test');
    $permissionModule = $permissionManager->getPermissionModule('test');
    ok(not(defined($permissionModule)), "PermissionManager from names, delPermissionModule:> Module deleted.");

    $failureCaughtFlag = 0;
    try {
        #This subpermission is now deleted due to cascading delete of the parent permissionModule
        #We catch the exception gracefully and report test success
        $permissionManager->delPermission('testperm');
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            $failureCaughtFlag = 1;
        }
        else {
            die $_; #Somekind of another problem arised and rethrow it.
        }
    };
    ok($failureCaughtFlag, "PermissionManager from names, delPermission:> Permission already deleted, exception caught.");
    $permission = $permissionManager->getPermission('testperm');
    ok(not(defined($permission)), "PermissionManager from names, delPermission:> Permission deleted.");



    ###  TESTING WITH Koha::Object parameters instead.  ###
    ##Add/get PermissionModule
    $permissionModule = $permissionManager->addPermissionModule({module => 'test', description => 'Just testing this module.'});
    is($permissionModule->module, "test", "PermissionManager from objects, add/getPermissionModule:> Module added.");
    $permissionModule = $permissionManager->getPermissionModule($permissionModule);
    is($permissionModule->module, "test", "PermissionManager from objects, add/getPermissionModule:> Module got.");

    ##Add/get Permission
    $permission = $permissionManager->addPermission({module => 'test', code => 'testperm', description => 'Just testing this permission.'});
    is($permission->code, "testperm", "PermissionManager from objects, add/getPermission:> Permission added.");
    $permission = $permissionManager->getPermission($permission);
    is($permission->code, "testperm", "PermissionManager from objects, add/getPermission:> Permission got.");

    ##Grant permission
    $permissionManager->grantPermission($borrowers->{'1A01'}, $permissionModule, $permission);
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, $permissionModule, $permission), "PermissionManager from objects, grant/hasPermission:> Borrower granted permission.");

    ##hasPermission with wildcard
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, $permissionModule, '*'), "PermissionManager from objects, hasPermission:> Wildcard permission.");

    ##hasPermissions with wildcard, we quite cannot use a blessed Object as a HASH key
    #ok($permissionManager->hasPermissions($borrowers->{'1A01'}, {$permissionModule->module() => ['*']}), "PermissionManager from objects, hasPermission:> Wildcard permissions from array.");

    ##Revoke permission
    $permissionManager->revokePermission($borrowers->{'1A01'}, $permissionModule, $permission);
    $failureCaughtFlag = 0;
    try {
        $permissionManager->hasPermission($borrowers->{'1A01'}, $permissionModule, $permission);
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::NoPermission')) {
            $failureCaughtFlag = 1;
        }
        else {
            die $_; #Somekind of another problem arised and rethrow it.
        }
    };
    ok($failureCaughtFlag, "PermissionManager from objects, revoke/hasPermission:> Borrower revoked permission.");

    ##Delete permissions and modules we just made
    $permissionManager->delPermission($permission);
    $permission = $permissionManager->getPermission('testperm');
    ok(not(defined($permission)), "PermissionManager from objects, delPermission:> Permission deleted.");

    $permissionManager->delPermissionModule($permissionModule);
    $permissionModule = $permissionManager->getPermissionModule('test');
    ok(not(defined($permissionModule)), "PermissionManager from objects, delPermissionModule:> Module deleted.");


    ##Grant all subpermissions from a permission module
    $permissionManager->revokeAllPermissions($borrowers->{'1A01'});
    $permissionManager->grantAllSubpermissions($borrowers->{'1A01'}, ['circulate']);
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'circulate', 'circulate_remaining_permissions'), "PermissionManager, grant all subpermissions of module:> Borrower has all permissions 1.");
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'circulate', 'override_renewals'), "PermissionManager, grant all subpermissions of module:> Borrower has all permissions 2.");
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'circulate', 'overdues_report'), "PermissionManager, grant all subpermissions of module:> Borrower has all permissions 3.");
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'circulate', 'force_checkout'), "PermissionManager, grant all subpermissions of module:> Borrower has all permissions 4.");
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'circulate', 'manage_restrictions'), "PermissionManager, grant all subpermissions of module:> Borrower has all permissions 5.");

    ##Testing superlibrarian permission
    $permissionManager->revokeAllPermissions($borrowers->{'1A01'});
    $permissionManager->grantPermission($borrowers->{'1A01'}, 'superlibrarian', 'superlibrarian');
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'staffaccess', 'staff_access_permissions'), "PermissionManager, superuser permission:> Superuser has all permissions 1.");
    ok($permissionManager->hasPermission($borrowers->{'1A01'}, 'tools', 'batch_upload_patron_images'), "PermissionManager, superuser permission:> Superuser has all permissions 2.");

    # getPermissionModuleFromPermission
    is($permissionManager->getPermissionModuleFromPermission('override_renewals')->module, 'circulate', 'PermissionManager, getPermissionModuleFromPermission:> override_renewals belongs to circulate permission module');
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
