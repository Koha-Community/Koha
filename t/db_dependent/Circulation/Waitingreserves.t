#!/usr/bin/perl

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
use Try::Tiny;

use t::lib::Page::Circulation::Waitingreserves;
use t::lib::TestBuilder;
use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::HoldFactory;
use t::lib::TestObjects::SystemPreferenceFactory;
use Koha::Auth::PermissionManager;
use Koha::Database;
use Koha::IssuingRules;

##Enable debug mode for PageObject tests.
#$ENV{KOHA_PAGEOBJECT_DEBUG} = 1;
my $builder = t::lib::TestBuilder->new();
my @stored_rules = Koha::IssuingRules->search->as_list;

##Setting up the test context
my $testContext = {};

my $password = '1234';
my ($holds, $borrowers);
subtest "Setting up test context" => \&settingUpTestContext;
sub settingUpTestContext {
    eval { #run in a eval-block so we don't die without tearing down the test context

        Koha::IssuingRules->search->delete;
        $builder->build({
            source => 'Issuingrule',
            value => {
                branchcode => '*',
                categorycode => '*',
                itemtype =>'*',
                ccode => '*',
                permanent_location => '*',
                hold_max_pickup_delay => 6,
            }
        });
        t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
            {preference => 'PickupExpiredHoldsOverReportDuration',
             value => 2,
            },
            {preference => 'ExpireReservesMaxPickUpDelay',
             value => 1,
            },
            ], undef, $testContext);

        my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
        $borrowers = $borrowerFactory->createTestGroup([
                    {firstname  => 'Olli-Antti',
                     surname    => 'Kivi',
                     othernames => 'AlasValas',
                     cardnumber => '1A01',
                     branchcode => 'CPL',
                     userid     => 'mini_admin',
                     password   => $password,
                    },
                ], undef, $testContext);
        my $permissionManager = Koha::Auth::PermissionManager->new();
        $permissionManager->grantPermission($borrowers->{'1A01'}, 'circulate', 'circulate_remaining_permissions');

        $holds = t::lib::TestObjects::HoldFactory->createTestGroup([
            {cardnumber  => '1A01',
             isbn        => '987Kivi',
             barcode     => '1N01',
             branchcode  => 'CPL',
             waitingdate => DateTime->now(time_zone => C4::Context->tz())->subtract(days => 9)->iso8601(),
             reservenotes => 'expire3daysAgo',
            },
            {cardnumber  => '1A01',
             isbn        => '987Kivi',
             barcode     => '1N02',
             branchcode  => 'CPL',
             waitingdate => DateTime->now(time_zone => C4::Context->tz())->subtract(days => 8)->iso8601(),
             reservenotes => 'expire2daysAgo',
            },
            {cardnumber  => '1A01',
             isbn        => '987Kivi',
             barcode     => '1N03',
             branchcode  => 'CPL',
             waitingdate => DateTime->now(time_zone => C4::Context->tz())->subtract(days => 7)->iso8601(),
             reservenotes => 'expire1dayAgo1',
            },
            {cardnumber  => '1A01',
             isbn        => '987Kivi',
             barcode     => '1N04',
             branchcode  => 'CPL',
             waitingdate => DateTime->now(time_zone => C4::Context->tz())->subtract(days => 7)->iso8601(),
             reservenotes => 'expire1dayAgo2',
            },
            {cardnumber  => '1A01',
             isbn        => '987Kivi',
             barcode     => '1N05',
             branchcode  => 'CPL',
             waitingdate => DateTime->now(time_zone => C4::Context->tz())->subtract(days => 6)->iso8601(),
             reservenotes => 'expiresToday',
            },
            {cardnumber  => '1A01',
             isbn        => '987Kivi',
             barcode     => '1N06',
             branchcode  => 'CPL',
             waitingdate => DateTime->now(time_zone => C4::Context->tz())->subtract(days => 5)->iso8601(),
             reservenotes => 'expiresTomorrow',
            },
        ], undef, $testContext);

        C4::Reserves::CancelExpiredReserves();

        ok(1, "Test context set without crashing");

    };
    if ($@) { #Catch all leaking errors and gracefully terminate.
        ok(0, "Test context set without crashing");
        warn $@;
        tearDown();
        exit 1;
    }
}

subtest "Display expired waiting reserves" => \&displayExpiredWaitingReserves;
sub displayExpiredWaitingReserves {
    eval { #run in a eval-block so we don't die without tearing down the test context

        my $expectedExpiredHoldsInOrder = [
            $holds->{expire3daysAgo},
            $holds->{expire2daysAgo},
            $holds->{expire1dayAgo1},
            $holds->{expire1dayAgo2},
        ];

        my $waitingreserves = t::lib::Page::Circulation::Waitingreserves->new();
        $waitingreserves->doPasswordLogin($borrowers->{'1A01'}->userid(), $password)
            ->showHoldsOver()->assertHoldRowsVisible($expectedExpiredHoldsInOrder)
            ->doPasswordLogout();
        $waitingreserves->quit();

    };
    if ($@) { #Catch all leaking errors and gracefully terminate.
        ok(0, "Subtest crashed");
        warn $@;
    }
}

##All tests done, tear down test context
tearDown();
done_testing;

sub tearDown {
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
    Koha::IssuingRules->delete;
    foreach my $rule (@stored_rules) {
        Koha::IssuingRule->new($rule->unblessed)->store;
    }
}
