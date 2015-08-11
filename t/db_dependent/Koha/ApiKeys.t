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
use Koha::ApiKeys;

use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::PatronFactory;
use t::lib::Page::Members::Moremember;
use t::lib::Page::Opac::OpacMain;

##Setting up the test context
my $testContext = {};

my $password = '1234';
my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
my $borrowers = $borrowerFactory->createTestGroup([
            {firstname  => 'Olli-Antti',
             surname    => 'Kivi',
             cardnumber => '1A01',
             branchcode => 'CPL',
             password   => $password,
            },
            {firstname  => 'Alli-Ontti',
             surname    => 'Ivik',
             cardnumber => '1A02',
             branchcode => 'CPL',
             password   => $password,
            },
        ], undef, $testContext);
my $borrowerKivi = $borrowers->{'1A01'};
my $borrowerIvik = $borrowers->{'1A02'};
my $permissionManager = Koha::Auth::PermissionManager->new();
$permissionManager->grantPermission($borrowerKivi, 'borrowers', 'manage_api_keys');


##Test context set, starting testing:
eval { #run in a eval-block so we don't die without tearing down the test context
subtest "ApiKeys API Unit tests" => sub {
    my $borrowerKivi = $borrowers->{'1A01'};
    my $borrowerIvik = $borrowers->{'1A02'};


    my $apiKey = Koha::ApiKeys->grant($borrowerKivi);
    is($apiKey->borrowernumber, $borrowerKivi->borrowernumber, "ApiKey granted");

    Koha::ApiKeys->revoke($apiKey);
    is($apiKey->active, 0, "ApiKey revoked");

    Koha::ApiKeys->activate($apiKey);
    is($apiKey->active, 1, "ApiKey activated");

    Koha::ApiKeys->grant($borrowerIvik, $apiKey);
    is($apiKey->borrowernumber, $borrowerIvik->borrowernumber, "ApiKey granted to another Borrower");

    Koha::ApiKeys->delete($apiKey);
    $apiKey = Koha::ApiKeys->find({api_key_id => $apiKey->api_key_id});
    ok(not($apiKey), "ApiKey deleted");
}
};
if ($@) { #Catch all leaking errors and gracefully terminate.
    warn $@;
    tearDown();
    exit 1;
}

eval {
subtest "ApiKeys Intra Integration tests" => sub {
    my $agent = t::lib::Page::Members::Moremember->new({borrowernumber => $borrowerKivi->borrowernumber});
    $agent->doPasswordLogin($borrowerKivi->userid, $password)->navigateManageApiKeys()->generateNewApiKey();
    my @apiKeys = Koha::ApiKeys->search({borrowernumber => $borrowerKivi->borrowernumber});
    $agent->revokeApiKey($apiKeys[0]->api_key)->deleteApiKey($apiKeys[0]->api_key)
               ->quit();
}
};
if ($@) { #Catch all leaking errors and gracefully terminate.
    warn $@;
    tearDown();
    exit 1;
}

eval {
subtest "ApiKeys OPAC Integration tests" => sub {
    my $agent = t::lib::Page::Opac::OpacMain->new();
    $agent->doPasswordLogin($borrowerKivi->userid, $password)->navigateYourAPIKeys()->generateNewApiKey();
    my @apiKeys = Koha::ApiKeys->search({borrowernumber => $borrowerKivi->borrowernumber});
    $agent->revokeApiKey($apiKeys[0]->api_key)->deleteApiKey($apiKeys[0]->api_key)
               ->quit();
}
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
