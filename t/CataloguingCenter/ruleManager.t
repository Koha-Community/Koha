# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Test::More;
use Try::Tiny;
use Scalar::Util qw(blessed);
use Hash::Merge::Simple;

use C4::Breeding;
use C4::BatchOverlay::RuleManager;

use Koha::Z3950Servers;

use t::lib::TestObjects::ObjectFactory;
use t::CataloguingCenter::z3950Params;

my $testContext = {};

my $cataloguingCenterZ3950 = t::CataloguingCenter::z3950Params::getCataloguingCenterZ3950params();
unless ($cataloguingCenterZ3950 = Koha::Z3950Servers->search($cataloguingCenterZ3950)->next) {
    $cataloguingCenterZ3950 = Koha::Z3950Server->new($cataloguingCenterZ3950)->store;
}
$cataloguingCenterZ3950 = $cataloguingCenterZ3950->unblessed;

use t::CataloguingCenter::ContextSysprefs;
t::CataloguingCenter::ContextSysprefs::createBatchOverlayRules($testContext);


subtest "alterAllRules() happy path", \&alterAllRules_happy;
sub alterAllRules_happy {
    my $subtestContext = {};
    eval {
    t::CataloguingCenter::ContextSysprefs::createBatchOverlayRulesWithCandidateCriteria($subtestContext);

    my $oldRules = C4::BatchOverlay::RuleManager::loadRules();
    my $change = {default => {remoteTargetCode => 'CHANGED'}};
    my $expectedRules = Hash::Merge::Simple::merge($oldRules, $change);

    ok($oldRules, "Given existing configuration");

    my $mash = C4::BatchOverlay::RuleManager::alterAllRules($change);
    ok($mash, "When Old config is mashed together with the new config");

    is_deeply($mash, $expectedRules, "Then the existing configuration is properly changed");

    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}

subtest "alterAllRules() sad path", \&alterAllRules_sad;
sub alterAllRules_sad {
    my $subtestContext = {};
    eval {
    t::CataloguingCenter::ContextSysprefs::createBatchOverlayRulesWithCandidateCriteria($subtestContext);

    my $oldRules = C4::BatchOverlay::RuleManager::loadRules();
    is($oldRules->{default}->{remoteTargetCode}, 'CATALOGUING_CENTER',
       "Given existing configuration 'remoteTargetCode'");

    ok(1, "When Old config is mashed together with the new empty config");
    my $mash;
    eval {
        $mash = C4::BatchOverlay::RuleManager::alterAllRules({default => {remoteTargetCode => ''}});
    };
    like($@, qr/remoteTargetCode/,
       "Then an exception is thrown about missing configuration");

    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}


subtest "testRemoteTargetConnections", \&testRemoteTargetConnections;
sub testRemoteTargetConnections {
    my ();
    eval {
        my $ruleManager = C4::BatchOverlay::RuleManager->new();
        my $statuses = $ruleManager->testRemoteTargetConnections();
        is($statuses->[0]->{server},
           $cataloguingCenterZ3950->{name},
           "Connection name");

        if ($statuses->[0]->{errors}) {
            die join(' ', @{$statuses->[0]->{errors}}).' to '.$statuses->[0]->{server};
        }

        is($statuses->[0]->{errors},
           undef,
           "Connection has no errors");
        is($statuses->[1],
           undef,
           "No more connections");
    };
    if ($@) {
        ok(0, $@);
    }
}



t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing();
