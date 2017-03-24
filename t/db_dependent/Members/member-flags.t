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
use Scalar::Util qw(blessed);

use t::lib::Page::Members::MemberFlags;
use t::lib::TestObjects::PatronFactory;
use Koha::Auth::PermissionManager;


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

    testGrantRevokePermissions();

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

sub testGrantRevokePermissions {
    my $permissionManager = Koha::Auth::PermissionManager->new();
    $permissionManager->grantPermissions($borrowers->{'1A01'}, {permissions => 'set_permissions',
                                                                catalogue => 'staff_login',
                                                                staffaccess => 'staff_access_permissions',
                                                                circulate => 'override_renewals',
                                                                borrowers => 'view_borrowers',
                                                              });

    my $memberflags = t::lib::Page::Members::MemberFlags->new({borrowernumber => $borrowers->{'1A01'}->borrowernumber});

    $memberflags->isPasswordLoginAvailable()->doPasswordLogin($borrowers->{'1A01'}->userid, $password)
                ->togglePermission('editcatalogue', 'delete_all_items') #Add this
                ->togglePermission('editcatalogue', 'edit_items') #Add this
                ->togglePermission('circulate', 'override_renewals') #Remove this permission
                ->submitPermissionTree();

    ok($permissionManager->hasPermissions($borrowers->{'1A01'},{editcatalogue => ['delete_all_items', 'edit_items']}),
    "member-flags.pl:> Granting new permissions succeeded.");

    my $failureCaughtFlag = 0;
    try {
        $permissionManager->hasPermission($borrowers->{'1A01'}, 'circulate', 'override_renewals');
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::NoPermission')) {
            $failureCaughtFlag = 1;
        }
        else {
            die $_; #Somekind of another problem arised and rethrow it.
        }
    };
    ok($failureCaughtFlag, "member-flags.pl:> Revoking permissions succeeded.");

    $permissionManager->revokeAllPermissions($borrowers->{'1A01'});
}