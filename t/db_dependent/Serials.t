#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use YAML;

use C4::Serials;
use C4::Debug;
use Test::More tests => 33;

BEGIN {
    use_ok('C4::Serials');
}

my $subscriptionid = 1;
my $subscriptioninformation = GetSubscription( $subscriptionid );
$debug && warn Dump($subscriptioninformation);
my @subscriptions = GetSubscriptions( $$subscriptioninformation{bibliotitle} );
isa_ok( \@subscriptions, 'ARRAY' );
$debug && warn scalar(@subscriptions);
@subscriptions = GetSubscriptions( undef, $$subscriptioninformation{issn} );
isa_ok( \@subscriptions, 'ARRAY' );
$debug && warn scalar(@subscriptions);
@subscriptions = GetSubscriptions( undef,undef ,$$subscriptioninformation{bibnum} );
isa_ok( \@subscriptions, 'ARRAY' );
$debug && warn scalar(@subscriptions);
if ($subscriptioninformation->{periodicity} % 16==0){
	$subscriptioninformation->{periodicity}=7;
	ModSubscription(@$subscriptioninformation{qw(librarian,           branchcode,      aqbooksellerid,    cost,             aqbudgetid,    startdate,   periodicity,   firstacquidate,
        dow,             irregularity,    numberpattern,     numberlength,     weeklength,    monthlength, add1,          every1,
        whenmorethan1,   setto1,          lastvalue1,        innerloop1,       add2,          every2,      whenmorethan2, setto2,
        lastvalue2,      innerloop2,      add3,              every3,           whenmorethan3, setto3,      lastvalue3,    innerloop3,
        numberingmethod, status,          biblionumber,      callnumber,       notes,         letter,      hemisphere,    manualhistory,
        internalnotes,   serialsadditems, staffdisplaycount, opacdisplaycount, graceperiod,   location,    enddate,       subscriptionid
)});
}
my $expirationdate = GetExpirationDate(1) ;
ok( $expirationdate, "not NULL" );
$debug && warn "$expirationdate";

is(C4::Serials::GetLateIssues(),"0", 'test getting late issues');

ok(C4::Serials::GetSubscriptionHistoryFromSubscriptionId(), 'test getting history from sub-scription');

ok(C4::Serials::GetSerialStatusFromSerialId(), 'test getting Serial Status From Serial Id');

ok(C4::Serials::GetSerialInformation(), 'test getting Serial Information');

ok(C4::Serials::AddItem2Serial(), 'test adding item to serial');

ok(C4::Serials::UpdateClaimdateIssues(), 'test updating claim date');

ok(C4::Serials::GetFullSubscription(), 'test getting full subscription');

ok(C4::Serials::PrepareSerialsData(), 'test preparing serial data');

ok(C4::Serials::GetSubscriptionsFromBiblionumber(), 'test getting subscriptions form biblio number');

is(C4::Serials::GetSerials(),"0", 'test getting serials when you enter nothing');
is(C4::Serials::GetSerials2(),"0", 'test getting serials when you enter nothing');

ok(C4::Serials::GetLatestSerials(), 'test getting lastest serials');

is(C4::Serials::GetDistributedTo(),"0", 'test getting distributed when nothing is entered');

is(C4::Serials::GetNextSeq(),"0", 'test getting next seq when you enter nothing');

is(C4::Serials::GetSeq(),undef, 'test getting seq when you enter nothing');

is(C4::Serials::CountSubscriptionFromBiblionumber(),"0", 'test counting subscription when nothing is entered');

is(C4::Serials::ModSubscriptionHistory(),"0", 'test modding subscription history');

is(C4::Serials::ModSerialStatus(),undef, 'test modding serials');

is(C4::Serials::NewIssue(),"0", 'test getting 0 when nothing is entered');

is(C4::Serials::ItemizeSerials(),undef, 'test getting nothing when nothing is entered');

ok(C4::Serials::HasSubscriptionStrictlyExpired(), 'test if the subscriptions has expired');
is(C4::Serials::HasSubscriptionExpired(),"0", 'test if the subscriptions has expired');

is(C4::Serials::GetLateOrMissingIssues(),"0", 'test getting last or missing issues');

is(C4::Serials::removeMissingIssue(),undef, 'test removing a missing issue');

is(C4::Serials::updateClaim(),undef, 'test updating claim');

is(C4::Serials::getsupplierbyserialid(),undef, 'test getting supplier idea');

is(C4::Serials::check_routing(),"0", 'test checking route');

is(C4::Serials::addroutingmember(),undef, 'test adding route member');
