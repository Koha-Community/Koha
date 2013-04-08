#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;
use YAML;

use CGI;
use C4::Serials;
use C4::Serials::Frequency;
use C4::Debug;
use Test::More tests => 35;

BEGIN {
    use_ok('C4::Serials');
}

my $subscriptionid = 1;
my $subscriptioninformation = GetSubscription( $subscriptionid );

my @subscriptions = GetSubscriptions( $$subscriptioninformation{bibliotitle} );
isa_ok( \@subscriptions, 'ARRAY' );

@subscriptions = GetSubscriptions( undef, $$subscriptioninformation{issn} );
isa_ok( \@subscriptions, 'ARRAY' );

@subscriptions = GetSubscriptions( undef, undef, $$subscriptioninformation{ean} );
isa_ok( \@subscriptions, 'ARRAY' );

@subscriptions = GetSubscriptions( undef, undef, undef, $$subscriptioninformation{bibnum} );
isa_ok( \@subscriptions, 'ARRAY' );

my $frequency = GetSubscriptionFrequency($subscriptioninformation->{periodicity});
my $old_frequency;
if (not $frequency->{unit}) {
    $old_frequency = $frequency->{id};
    $frequency->{unit} = "month";
    $frequency->{unitsperissue} = 1;
    $frequency->{issuesperunit} = 1;
    $frequency->{description} = "Frequency created by t/db_dependant/Serials.t";
    $subscriptioninformation->{periodicity} = AddSubscriptionFrequency($frequency);

    ModSubscription( @$subscriptioninformation{qw(
        librarian branchcode aqbooksellerid cost aqbudgetid startdate
        periodicity firstacquidate irregularity numberpattern locale
        numberlength weeklength monthlength lastvalue1 innerloop1 lastvalue2
        innerloop2 lastvalue3 innerloop3 status biblionumber callnumber notes
        letter manualhistory internalnotes serialsadditems staffdisplaycount
        opacdisplaycount graceperiod location enddate subscriptionid
        skip_serialseq
    )} );
}
my $expirationdate = GetExpirationDate($subscriptionid) ;
ok( $expirationdate, "not NULL" );

is(C4::Serials::GetLateIssues(), undef, 'test getting late issues');

ok(C4::Serials::GetSubscriptionHistoryFromSubscriptionId($subscriptionid), 'test getting history from sub-scription');

my ($serials_count, @serials) = GetSerials($subscriptionid);
ok($serials_count > 0, 'Subscription has at least one serial');
my $serial = $serials[0];

ok(C4::Serials::GetSerialStatusFromSerialId($serial->{serialid}), 'test getting Serial Status From Serial Id');

isa_ok(C4::Serials::GetSerialInformation($serial->{serialid}), 'HASH', 'test getting Serial Information');

# Delete created frequency
if ($old_frequency) {
    my $freq_to_delete = $subscriptioninformation->{periodicity};
    $subscriptioninformation->{periodicity} = $old_frequency;

    ModSubscription( @$subscriptioninformation{qw(
        librarian branchcode aqbooksellerid cost aqbudgetid startdate
        periodicity firstacquidate irregularity numberpattern locale
        numberlength weeklength monthlength lastvalue1 innerloop1 lastvalue2
        innerloop2 lastvalue3 innerloop3 status biblionumber callnumber notes
        letter manualhistory internalnotes serialsadditems staffdisplaycount
        opacdisplaycount graceperiod location enddate subscriptionid
        skip_serialseq
    )} );

    DelSubscriptionFrequency($freq_to_delete);
}


# Test calling subs without parameters
is(C4::Serials::AddItem2Serial(), undef, 'test adding item to serial');
is(C4::Serials::UpdateClaimdateIssues(), undef, 'test updating claim date');
is(C4::Serials::GetFullSubscription(), undef, 'test getting full subscription');
is(C4::Serials::PrepareSerialsData(), undef, 'test preparing serial data');
is(C4::Serials::GetSubscriptionsFromBiblionumber(), undef, 'test getting subscriptions form biblio number');

is(C4::Serials::GetSerials(), undef, 'test getting serials when you enter nothing');
is(C4::Serials::GetSerials2(), undef, 'test getting serials when you enter nothing');

is(C4::Serials::GetLatestSerials(), undef, 'test getting lastest serials');

is(C4::Serials::GetDistributedTo(), undef, 'test getting distributed when nothing is entered');

is(C4::Serials::GetNextSeq(), undef, 'test getting next seq when you enter nothing');

is(C4::Serials::GetSeq(), undef, 'test getting seq when you enter nothing');

is(C4::Serials::CountSubscriptionFromBiblionumber(), undef, 'test counting subscription when nothing is entered');

is(C4::Serials::ModSubscriptionHistory(), undef, 'test modding subscription history');

is(C4::Serials::ModSerialStatus(),undef, 'test modding serials');

is(C4::Serials::NewIssue(), undef, 'test getting 0 when nothing is entered');

is(C4::Serials::ItemizeSerials(),undef, 'test getting nothing when nothing is entered');

is(C4::Serials::HasSubscriptionStrictlyExpired(), undef, 'test if the subscriptions has expired');
is(C4::Serials::HasSubscriptionExpired(), undef, 'test if the subscriptions has expired');

is(C4::Serials::GetLateOrMissingIssues(), undef, 'test getting last or missing issues');

is(C4::Serials::removeMissingIssue(), undef, 'test removing a missing issue');

is(C4::Serials::updateClaim(),undef, 'test updating claim');

is(C4::Serials::getsupplierbyserialid(),undef, 'test getting supplier idea');

is(C4::Serials::check_routing(), undef, 'test checking route');

is(C4::Serials::addroutingmember(),undef, 'test adding route member');
