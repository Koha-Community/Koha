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
use Encode;

use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::AtomicUpdateFactory;
use t::lib::TestObjects::FileFactory;
use Koha::AtomicUpdater;

my $testContext = {};
my $atomicupdates = t::lib::TestObjects::AtomicUpdateFactory->createTestGroup([
                           {filename => 'Bug-12-WatchExMachinaYoullLikeIt.pl'},
                           {filename => 'Bug-14-ReturnOfZorro.perl'},
                           {filename => 'KD-14-RobotronInDanger.sql'},
                           {filename => 'KD-15-ILikedPrometheusButAlienWasBetter.pl'},
                           ], undef, $testContext);

#Make sure we get the correct update order, otherwise we get unpredictable results.
{ #Overload existing subroutines to provide a Mock implementation
    no warnings 'redefine';
    package Koha::AtomicUpdater;
    sub _getGitCommits { #instead of requiring a Git repository, we just mock the input.
        return [#Newest commit
                '2e8a39762b506738195f21c8ff67e4e7bfe6dbba Bug_01243-SingleUpdate',
                '2e8a39762b506738195f21c8ff67e4e7bfe6d7ab KD:55 : Fiftyfive',
                '2e8a39762b506738195f21c8ff67e4e7bfe6d7ab KD-54 - KohaCon in Finland next year',
                'b447b595acacb0c4823582acf9d8a08902118e59 KD-53 - Place to be.pl',
                '2e8a39762b506738195f21c8ff67e4e7bfe6d7ab bug 112 - Lapinlahden linnut',
                '5ac7101d4071fe11f7a5d1445bb97ed1a603a9b5 Bug:911 - What are you going to do?',
                '1d54601b9cac0bd75ee97e071cf52ed49daef8bd KD-911 - Who are you going to call',
                '1d54601b9cac0bd75ee97e071cf52ed49daef8bd bug 30 - Feature Yes yes',
                '5ac7101d4071fe11f7a5d1445bb97ed1a603a9b5 KD-29 - Bug squashable',
                '2e8a39762b506738195f21c8ff67e4e7bfe6d7ab Bug : 28 - Feature Squash',
                'b447b595acacb0c4823582acf9d8a08902118e59 BUG 27 - Bug help',
                #Oldest commit
                ];
    }
}

subtest "Followup naming convention" => \&followupNamingConvention;
sub followupNamingConvention {
    eval {
        my $au = Koha::AtomicUpdate->new({filename => "Bug-535455-1-TestingFollowups.pl"});
        is($au->issue_id, "Bug-535455-1", "Followup Bug-535455-1 recognized");
    };
    if ($@) {
        ok(0, $@);
    }
}

subtest "Create update order from Git repository" => \&createUpdateOrderFromGit;
sub createUpdateOrderFromGit {
    eval {
        #Create the _updateorder-file to a temp directory and prepare it for autocleanup.
        my $files = t::lib::TestObjects::FileFactory->createTestGroup([
                        {   filepath => 'atomicupdate/',
                            filename => '_updateorder',
                            content  => '',},
                        ],
                        undef, undef, $testContext);
        #Instantiate the AtomicUpdater to operate on a temp directory.
        my $atomicUpdater = Koha::AtomicUpdater->new({
                                        scriptDir => $files->{'_updateorder'}->dirname(),
                            });

        #Start real testing.
        my $issueIds = $atomicUpdater->buildUpdateOrderFromGit(4);

        is($issueIds->[0],
           'Bug-27',
           "First atomicupdate to deploy");
        is($issueIds->[1],
           'Bug-28',
           "Second atomicupdate to deploy");
        is($issueIds->[2],
           'KD-29',
           "Third atomicupdate to deploy");
        is($issueIds->[3],
           'Bug-30',
           "Last atomicupdate to deploy");

        #Testing file access
        $issueIds = $atomicUpdater->getUpdateOrder();
        is($issueIds->[0],
           'Bug-27',
           "First atomicupdate to deploy, from _updateorder");
        is($issueIds->[1],
           'Bug-28',
           "Second atomicupdate to deploy, from _updateorder");
        is($issueIds->[2],
           'KD-29',
           "Third atomicupdate to deploy, from _updateorder");
        is($issueIds->[3],
           'Bug-30',
           "Last atomicupdate to deploy, from _updateorder");
    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "List all deployed atomicupdates" => \&listAtomicUpdates;
sub listAtomicUpdates {
    eval {
    my $atomicUpdater = Koha::AtomicUpdater->new();
    my $text = $atomicUpdater->listToConsole();
    print $text;

    ok($text =~ m/Bug-12-WatchExMachinaYoullLik/,
       "Bug12-WatchExMachinaYoullLikeIt");
    ok($text =~ m/Bug-14-ReturnOfZorro.perl/,
       "Bug14-ReturnOfZorro");
    ok($text =~ m/KD-14-RobotronInDanger.sql/,
       "KD-14-RobotronInDanger");
    ok($text =~ m/KD-15-ILikedPrometheusButAli/,
       "KD-15-ILikedPrometheusButAlienWasBetter");

    };
    if ($@) {
        ok(0, $@);
    }
}

subtest "Delete an atomicupdate entry" => \&deleteAtomicupdate;
sub deleteAtomicupdate {
    eval {
    my $atomicUpdater = Koha::AtomicUpdater->new();
    my $atomicupdate = $atomicUpdater->cast($atomicupdates->{'Bug-12'}->id);
    ok($atomicupdate,
       "AtomicUpdate '".$atomicupdates->{'Bug-12'}->issue_id."' exists prior to deletion");

    $atomicUpdater->removeAtomicUpdate($atomicupdate->issue_id);
    $atomicupdate = $atomicUpdater->find($atomicupdates->{'Bug-12'}->id);
    ok(not($atomicupdate),
       "AtomicUpdate '".$atomicupdates->{'Bug-12'}->issue_id."' deleted");

    };
    if ($@) {
        ok(0, $@);
    }
}

subtest "Insert an atomicupdate entry" => \&insertAtomicupdate;
sub insertAtomicupdate {
    eval {
    my $atomicUpdater = Koha::AtomicUpdater->new();
    my $subtestContext = {};
    my $atomicupdates = t::lib::TestObjects::AtomicUpdateFactory->createTestGroup([
                           {issue_id => 'Bug-15',
                            filename => 'Bug-15-Inserted.pl'},
                           ], undef, $subtestContext, $testContext);
    my $atomicupdate = $atomicUpdater->find('Bug-15');
    ok($atomicupdate,
       "Bug-15-Inserted.pl");

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

    $atomicupdate = $atomicUpdater->find('Bug-15');
    ok(not($atomicupdate),
       "Bug-15-Inserted.pl deleted");
    };
    if ($@) {
        ok(0, $@);
    }
}

subtest "List pending atomicupdates" => \&listPendingAtomicupdates;
sub listPendingAtomicupdates {
    my ($atomicUpdater, $files, $text, $atomicupdates);
    my $subtestContext = {};
    eval {
    ##Test adding update scripts and deploy them, confirm that no pending scripts detected
    $files = t::lib::TestObjects::FileFactory->createTestGroup([
                        {   filepath => 'atomicupdate/',
                            filename => 'KD-911-WhoYouGonnaCall.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS} = 1;',},
                        {   filepath => 'atomicupdate/',
                            filename => 'Bug-911-WhatchaGonnaDo.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS}++;',},
                        {   filepath => 'atomicupdate/',
                            filename => 'Bug-112-LapinlahdenLinnut.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS}++;',},
                        ],
                        undef, $subtestContext, $testContext);
    $atomicUpdater = Koha::AtomicUpdater->new({
                            scriptDir => $files->{'KD-911-WhoYouGonnaCall.pl'}->dirname()
                        });

$DB::single=1;
    $text = $atomicUpdater->listPendingToConsole();
    #print $text;
    ok($text =~ m/KD-911-WhoYouGonnaCall.pl/,
       "KD-911-WhoYouGonnaCall is pending");
    ok($text =~ m/Bug-911-WhatchaGonnaDo.pl/,
       "Bug-911-WhatchaGonnaDo is pending");
    ok($text =~ m/Bug-112-LapinlahdenLinnut.pl/,
       'Bug-112-LapinlahdenLinnut is pending');
$DB::single=1;
    $atomicupdates = $atomicUpdater->applyAtomicUpdates();
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicupdates, undef, $subtestContext, $testContext); #Keep track of changes

    is($atomicupdates->{'KD-911'}->issue_id,
       'KD-911',
       "KD-911-WhoYouGonnaCall.pl deployed");
    is($atomicupdates->{'Bug-112'}->issue_id,
       'Bug-112',
       'Bug-112-LapinlahdenLinnut.pl deployed');
    is($atomicupdates->{'Bug-911'}->issue_id,
       'Bug-911',
       "Bug-911-WhatchaGonnaDo.pl deployed");

    ##Test adding scripts to the atomicupdates directory and how we deal with such change.
    $files = t::lib::TestObjects::FileFactory->createTestGroup([
                        {   filepath => 'atomicupdate/',
                            filename => 'KD-53-PlaceToBe.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS}++;',},
                        {   filepath => 'atomicupdate/',
                            filename => 'KD-54-KohaConInFinlandNextYear.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS}++;',},
                        {   filepath => 'atomicupdate/',
                            filename => 'KD-55-Fiftyfive.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS}++;',},
                        ],
                        undef, $subtestContext, $testContext);

    $text = $atomicUpdater->listPendingToConsole();
    print $text;

    ok($text =~ m/KD-53-PlaceToBe.pl/,
       "KD-53-PlaceToBe.pl is pending");
    ok($text =~ m/KD-54-KohaConInFinlandNextYear.pl/,
       "KD-54-KohaConInFinlandNextYear.pl is pending");
    ok($text =~ m/KD-55-Fiftyfive.pl/u,
       'KD-55-Fiftyfive.pl');

    $atomicupdates = $atomicUpdater->applyAtomicUpdates();
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicupdates, undef, $subtestContext, $testContext); #Keep track of changes

    is($atomicupdates->{'KD-53'}->issue_id,
       'KD-53',
       "KD-53-PlaceToBe.pl deployed");
    is($atomicupdates->{'KD-54'}->issue_id,
       'KD-54',
       'KD-54-KohaConInFinlandNextYear.pl deployed');
    is($atomicupdates->{'KD-55'}->issue_id,
       'KD-55',
       "KD-55-Fiftyfive.pl deployed");

    is($ENV{ATOMICUPDATE_TESTS},
       6,
       "All configured AtomicUpdates deployed");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::AtomicUpdateFactory->tearDownTestContext($subtestContext);
}

subtest "Apply single atomicupdate from file" => \&applySingleAtomicUpdateFromFile;
sub applySingleAtomicUpdateFromFile {
    my $subtestContext = {};
    eval {
    my $files = t::lib::TestObjects::FileFactory->createTestGroup([
                        {   filepath => 'atomicupdate/',
                            filename => 'Bug_01243-SingleUpdate.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS_2} = 10;',},
                        ],
                        undef, $subtestContext, $testContext);
    ###  Try first as a dry-run  ###
    my $atomicUpdater = Koha::AtomicUpdater->new({
                                                  scriptDir => $files->{'Bug_01243-SingleUpdate.pl'}->dirname(),
                                                  dryRun => 1,
                                                });

    $atomicUpdater->applyAtomicUpdate($files->{'Bug_01243-SingleUpdate.pl'}->stringify);
    my $atomicUpdate = $atomicUpdater->find('Bug-01243');

    ok(not($atomicUpdate),
       "--dry-run doesn't add anything");
    is($ENV{ATOMICUPDATE_TESTS_2},
       undef,
       "--dry-run doesn't execute anything");

    ###  Make a change!  ###
    $atomicUpdater = Koha::AtomicUpdater->new({
                                                  scriptDir => $files->{'Bug_01243-SingleUpdate.pl'}->dirname(),
                                                });

    $atomicUpdater->applyAtomicUpdate($files->{'Bug_01243-SingleUpdate.pl'}->stringify);
    $atomicUpdate = $atomicUpdater->find('Bug-01243');
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicUpdate, undef, $subtestContext, $testContext); #Keep track of changes

    is($atomicUpdate->filename,
       "Bug_01243-SingleUpdate.pl",
       "Bug_01243-SingleUpdate.pl added to DB");
    is($ENV{ATOMICUPDATE_TESTS_2},
       10,
       "Bug_01243-SingleUpdate.pl executed");

    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}

subtest 'Support community dev atomicupdates (.perl files, see skeleton.perl)'
        => \&applyCommunityDevUpdate;
sub applyCommunityDevUpdate {
    my $subtestContext = {};
    my $dev_update = q{
$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "SHOW TABLES" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    $ENV{ATOMICUPDATE_TESTS_VAL}++;
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
};
    my $dev_update_invalid = q{
$DBversion = '16.00.00';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "SHOW TABLES" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    $ENV{ATOMICUPDATE_TESTS_INV}++;
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
};
    eval {
    my $files = t::lib::TestObjects::FileFactory->createTestGroup([
                        {
                            filepath => 'atomicupdate/',
                            filename => 'Bug_00001-First-update.perl',
                            content  => $dev_update,
                        },
                        {
                            filepath => 'atomicupdate/',
                            filename => 'Bug_00002-Invalid-update.perl',
                            content  => $dev_update_invalid,
                        }
                        ],
                        undef, $subtestContext, $testContext);

    my $atomicUpdater = Koha::AtomicUpdater->new({
            scriptDir => $files->{'Bug_00001-First-update.perl'}->dirname(),
    });
    my $atomicUpdater_invalid = Koha::AtomicUpdater->new({
            scriptDir => $files->{'Bug_00002-Invalid-update.perl'}->dirname(),
    });

    $atomicUpdater->applyAtomicUpdate(
        $files->{'Bug_00001-First-update.perl'}->stringify
    );
    $atomicUpdater_invalid->applyAtomicUpdate(
        $files->{'Bug_00002-Invalid-update.perl'}->stringify
    );

    my $atomicUpdate = $atomicUpdater->find('Bug-00001');
    my $atomicUpdate_invalid = $atomicUpdater->find('Bug-00002');
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicUpdate, undef,
                                                $subtestContext, $testContext);
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicUpdate_invalid,
                                         undef, $subtestContext, $testContext);

    is($atomicUpdate->filename,
       "Bug_00001-First-update.perl",
       "Bug_00001-First-update.perl added to DB");
    is($atomicUpdate_invalid->filename,
       "Bug_00002-Invalid-update.perl",
       "Bug_00002-Invalid-update.perl added to DB");
    is($ENV{ATOMICUPDATE_TESTS_VAL}, 1, "First update execution success.");
    is($ENV{ATOMICUPDATE_TESTS_INV}, undef, "Invalid update execution failed.");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}

subtest 'Mark all atomicupdates as installed (for fresh installs), but do not'
       .' execute them' => \&addAllAtomicUpdates;
sub addAllAtomicUpdates {
    my $subtestContext = {};
    eval {
    my $files = t::lib::TestObjects::FileFactory->createTestGroup([
                        {
                            filepath => 'atomicupdate/',
                            filename => 'Bug_00001-First-update.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS_3}++;',
                        },
                        {
                            filepath => 'atomicupdate/',
                            filename => 'Bug_00002-Second-update.pl',
                            content  => '$ENV{ATOMICUPDATE_TESTS_3}++;',
                        },
                        ],
                        undef, $subtestContext, $testContext);

    my $atomicUpdater = Koha::AtomicUpdater->new({
            scriptDir => $files->{'Bug_00001-First-update.pl'}->dirname(),
    });

    $atomicUpdater->addAllAtomicUpdates;
    my $atomicUpdate = $atomicUpdater->find('Bug-00001');
    my $atomicUpdate2 = $atomicUpdater->find('Bug-00002');
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicUpdate, undef,
                                                $subtestContext, $testContext);
    t::lib::TestObjects::AtomicUpdateFactory->addToContext($atomicUpdate2, undef,
                                                $subtestContext, $testContext);

    is($atomicUpdate->filename,
       "Bug_00001-First-update.pl",
       "Bug_00001-First-update.pl added to DB");
    is($atomicUpdate2->filename,
       "Bug_00002-Second-update.pl",
       "Bug_00002-Second-update.pl added to DB");
    is($ENV{ATOMICUPDATE_TESTS_3}, undef, "However, updates were not executed.");
    };
    if ($@) {
        ok(0, $@);
    }
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
}

t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing;
