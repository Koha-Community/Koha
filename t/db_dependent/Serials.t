#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;
use YAML;

use CGI;
use C4::Serials;
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;
use C4::Debug;
use C4::Bookseller;
use C4::Biblio;
use C4::Budgets;
use Test::More tests => 35;

BEGIN {
    use_ok('C4::Serials');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');

my $budgetid;
my $bpid = AddBudgetPeriod({
    budget_period_startdate => '01-01-2015',
    budget_period_enddate   => '12-31-2015',
    budget_description      => "budget desc"
});

my $budget_id = AddBudget({
    budget_code        => "ABCD",
    budget_amount      => "123.132",
    budget_name        => "Périodiques",
    budget_notes       => "This is a note",
    budget_description => "Serials",
    budget_active      => 1,
    budget_period_id   => $bpid
});

my $frequency_id = AddSubscriptionFrequency({ description => "Test frequency 1" });
my $pattern_id = AddSubscriptionNumberpattern({
    label => 'Test numberpattern 1',
    numberingmethod => '{X}'
});

my $subscriptionid = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber,
    '2013-01-01', $frequency_id, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "notes",undef, '2013-01-01', undef, $pattern_id,
    undef,       undef,  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '2013-12-31', 0
);

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
ok( $expirationdate, "expiration date is not NULL" );

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

$dbh->rollback;
