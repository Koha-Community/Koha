#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;
use YAML;

use CGI qw ( -utf8 );
use C4::Serials;
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;
use C4::Debug;
use C4::Biblio;
use C4::Budgets;
use C4::Items;
use Koha::DateUtils;
use Koha::Acquisition::Booksellers;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::More tests => 48;

BEGIN {
    use_ok('C4::Serials');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new();

# This could/should be used for all untested methods
my @methods = ('updateClaim');
can_ok('C4::Serials', @methods);

$dbh->do(q|UPDATE marc_subfield_structure SET value_builder="callnumber.pl" where kohafield="items.itemcallnumber" and frameworkcode=''|);

my $bookseller = Koha::Acquisition::Bookseller->new(
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
    budget_period_startdate   => '2015-01-01',
    budget_period_enddate     => '2015-12-31',
    budget_period_description => "budget desc"
});

my $budget_id = AddBudget({
    budget_code        => "ABCD",
    budget_amount      => "123.132",
    budget_name        => "Périodiques",
    budget_notes       => "This is a note",
    budget_period_id   => $bpid
});

my $frequency_id = AddSubscriptionFrequency({ description => "Test frequency 1" });
my $pattern_id = AddSubscriptionNumberpattern({
    label => 'Test numberpattern 1',
    description => 'Description for numberpattern 1',
    numberingmethod => '{X}',
    label1 => q{},
    add1 => 1,
    every1 => 1,
    every1 => 1,
    numbering1 => 1,
    whenmorethan1 => 1,
});

my $notes = 'notes';
my $internalnotes = 'intnotes';
my $subscriptionid = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber,
    '2013-01-01', $frequency_id, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          $notes,undef, '2013-01-01', undef, $pattern_id,
    undef,       undef,  0,    $internalnotes,  0,
    undef, undef, 0,          undef,         '2013-12-31', 0
);

my $subscriptioninformation = GetSubscription( $subscriptionid );

is( $subscriptioninformation->{notes}, $notes, 'NewSubscription should set notes' );
is( $subscriptioninformation->{internalnotes}, $internalnotes, 'NewSubscription should set internalnotes' );

my $subscription_history = C4::Serials::GetSubscriptionHistoryFromSubscriptionId($subscriptionid);
is( $subscription_history->{opacnote}, '', 'NewSubscription should not set subscriptionhistory opacnotes' );
is( $subscription_history->{librariannote}, '', 'NewSubscription should not set subscriptionhistory librariannotes' );

my @subscriptions = SearchSubscriptions({string => $subscriptioninformation->{bibliotitle}, orderby => 'title' });
isa_ok( \@subscriptions, 'ARRAY' );

@subscriptions = SearchSubscriptions({ issn => $subscriptioninformation->{issn}, orderby => 'title' });
isa_ok( \@subscriptions, 'ARRAY' );

@subscriptions = SearchSubscriptions({ ean => $subscriptioninformation->{ean}, orderby => 'title' });
isa_ok( \@subscriptions, 'ARRAY' );

@subscriptions = SearchSubscriptions({ biblionumber => $subscriptioninformation->{bibnum}, orderby => 'title' });
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
    $subscriptioninformation->{serialsadditems} = 1;

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

ok(C4::Serials::GetSubscriptionHistoryFromSubscriptionId($subscriptionid), 'test getting history from sub-scription');

my ($serials_count, @serials) = GetSerials($subscriptionid);
ok($serials_count > 0, 'Subscription has at least one serial');
my $serial = $serials[0];

ok(C4::Serials::GetSerialStatusFromSerialId($serial->{serialid}), 'test getting Serial Status From Serial Id');

isa_ok(C4::Serials::GetSerialInformation($serial->{serialid}), 'HASH', 'test getting Serial Information');

subtest 'Values should not be erased on editing' => sub {

    plan tests => 1;

    ( $biblionumber, $biblioitemnumber ) = get_biblio();
    my ( $icn_tag, $icn_sf ) = GetMarcFromKohaField( 'items.itemcallnumber', '' );
    my ( $it_tag, $it_sf )   = GetMarcFromKohaField( 'items.itype', '' );

    my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};
    my $itemcallnumber = 'XXXmy itemcallnumberXXX';

    my $item_record    = new MARC::Record;

    $item_record->append_fields(
        MARC::Field->new( '080', '', '', "a" => "default" ),
        MARC::Field->new(
            $icn_tag, '', '',
            $icn_sf => $itemcallnumber,
            $it_sf  => $itemtype
        )
    );
    my ( undef, undef, $itemnumber ) = C4::Items::AddItemFromMarc( $item_record, $biblionumber );
    my $serialid = C4::Serials::NewIssue( "serialseq", $subscriptionid, $biblionumber,
                                          1, undef, undef, "publisheddatetext", "notes" );
    C4::Serials::AddItem2Serial( $serialid, $itemnumber );
    my $serial_info = C4::Serials::GetSerialInformation($serialid);
    my ($itemcallnumber_info) = grep { $_->{kohafield} eq 'items.itemcallnumber' }
                                     @{ $serial_info->{items}[0]->{iteminformation} };
    like( $itemcallnumber_info->{marc_value}, qr|value="$itemcallnumber"| );
};

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

is(C4::Serials::findSerialsByStatus(), 0, 'test finding serial by status with no parameters');

is(C4::Serials::NewIssue(), undef, 'test getting 0 when nothing is entered');

is(C4::Serials::HasSubscriptionStrictlyExpired(), undef, 'test if the subscriptions has expired');
is(C4::Serials::HasSubscriptionExpired(), undef, 'test if the subscriptions has expired');

is(C4::Serials::GetLateOrMissingIssues(), undef, 'test getting last or missing issues');

subtest 'test_updateClaim' => sub {
    plan tests => 11;

    my $today = output_pref({ dt => dt_from_string, dateonly => 1 });
    # Given ... nothing much
    # When ... Then ...
    my $result_0 = C4::Serials::updateClaim(undef);
    is($result_0, undef, 'Got the expected undef from update claim with nothin');

    # Given ... 3 serial. 2 of them updated.
    my $serialids_1   = [90980, 90981];
    my $claimdate_1   = dt_from_string('2001-01-13'); # arbitrary date some time in the past.
    my $claim_count_1 = 5;
    Koha::Serial->new( { serialid => $serialids_1->[0], serialseq => 'serialseq', subscriptionid => $subscriptionid, status => 3,
                         biblionumber => 12345, claimdate => $claimdate_1, claims_count => $claim_count_1, } )->store();
    Koha::Serial->new( { serialid => $serialids_1->[1], serialseq => 'serialseq', subscriptionid => $subscriptionid, status => 3,
                         biblionumber => 12345, claimdate => $claimdate_1, claims_count => $claim_count_1,  } )->store();
    Koha::Serial->new( { serialid => 90982, serialseq => 'serialseq', subscriptionid => $subscriptionid, status => 3,
                         biblionumber => 12345, claimdate => $claimdate_1, claims_count => $claim_count_1,  } )->store();

    # When ...
    my $result_1 = C4::Serials::updateClaim($serialids_1);

    # Then ...
    is($result_1, 2, 'Got the expected 2 from update claim with 2 serial ids');

    my @late_or_missing_issues_1_0 = C4::Serials::GetLateOrMissingIssues(undef, $serialids_1->[0]);
    is($late_or_missing_issues_1_0[0]->{claimdate}, $today, 'Got the expected first different claim date from update claim');
    is($late_or_missing_issues_1_0[0]->{claims_count}, $claim_count_1+1, 'Got the expected first claim count from update claim');
    is($late_or_missing_issues_1_0[0]->{status}, 7, 'Got the expected first claim status from update claim');

    my @late_or_missing_issues_1_1 = C4::Serials::GetLateOrMissingIssues(undef, $serialids_1->[1]);
    is($late_or_missing_issues_1_1[0]->{claimdate}, $today, 'Got the expected second different claim date from update claim');
    is($late_or_missing_issues_1_1[0]->{claims_count}, $claim_count_1+1, 'Got the expected second claim count from update claim');
    is($late_or_missing_issues_1_1[0]->{status}, 7, 'Got the expected second claim status from update claim');

    my @late_or_missing_issues_1_2 = C4::Serials::GetLateOrMissingIssues(undef, 90982);
    is($late_or_missing_issues_1_2[0]->{claimdate}, output_pref({ dt => $claimdate_1, dateonly => 1}), 'Got the expected unchanged claim date from update claim');
    is($late_or_missing_issues_1_2[0]->{claims_count}, $claim_count_1, 'Got the expected unchanged claim count from update claim');
    is($late_or_missing_issues_1_2[0]->{status}, 3, 'Got the expected unchanged claim status from update claim');
};

is(C4::Serials::check_routing(), undef, 'test checking route');

is(C4::Serials::addroutingmember(),undef, 'test adding route member');


# Unit tests for statuses management (Bug 11689)
$subscriptionid = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber,
    '2013-01-01', $frequency_id, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          $notes,undef, '2013-01-01', undef, $pattern_id,
    undef,       undef,  0,    $internalnotes,  0,
    undef, undef, 0,          undef,         '2013-12-31', 0
);
my $total_issues;
( $total_issues, @serials ) = C4::Serials::GetSerials( $subscriptionid );
is( $total_issues, 1, "NewSubscription created a first serial" );
is( @serials, 1, "GetSerials returns the serial" );
my $subscription = C4::Serials::GetSubscription($subscriptionid);
my $pattern = C4::Serials::Numberpattern::GetSubscriptionNumberpattern($subscription->{numberpattern});
( $total_issues, @serials ) = C4::Serials::GetSerials( $subscriptionid );
my $publisheddate = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
( $total_issues, @serials ) = C4::Serials::GetSerials( $subscriptionid );
my $nextpublisheddate = C4::Serials::GetNextDate($subscription, $publisheddate, 1);
my @statuses = qw( 2 2 3 3 3 3 3 4 4 41 42 43 44 5 );
# Add 14 serials
my $counter = 0;
for my $status ( @statuses ) {
    my $serialseq = "No.".$counter;
    my ( $expected_serial ) = GetSerials2( $subscriptionid, [1] );
    C4::Serials::ModSerialStatus( $expected_serial->{serialid}, $serialseq, $publisheddate, $publisheddate, $publisheddate, $statuses[$counter], 'an useless note' );
    $counter++;
}
# Here we have 15 serials with statuses : 2*2 + 5*3 + 2*4 + 1*41 + 1*42 + 1*43 + 1*44 + 1*5 + 1*1
my @serialsByStatus = C4::Serials::findSerialsByStatus(2,$subscriptionid);
is(@serialsByStatus,2,"findSerialsByStatus returns all serials with chosen status");
( $total_issues, @serials ) = C4::Serials::GetSerials( $subscriptionid );
is( $total_issues, @statuses + 1, "GetSerials returns total_issues" );
my @arrived_missing = map { my $status = $_->{status}; ( grep { /^$status$/ } qw( 2 4 41 42 43 44 5 ) ) ? $_ : () } @serials;
my @others = map { my $status = $_->{status}; ( grep { /^$status$/ } qw( 2 4 41 42 43 44 5 ) ) ? () : $_ } @serials;
is( @arrived_missing, 5, "GetSerials returns 5 arrived/missing by default" );
is( @others, 6, "GetSerials returns all serials not arrived and not missing" );

( $total_issues, @serials ) = C4::Serials::GetSerials( $subscriptionid, 10 );
is( $total_issues, @statuses + 1, "GetSerials returns total_issues" );
@arrived_missing = map { my $status = $_->{status}; ( grep { /^$status$/ } qw( 2 4 41 42 43 44 5 ) ) ? $_ : () } @serials;
@others = map { my $status = $_->{status}; ( grep { /^$status$/ } qw( 2 4 41 42 43 44 5 ) ) ? () : $_ } @serials;
is( @arrived_missing, 9, "GetSerials returns all arrived/missing if count given" );
is( @others, 6, "GetSerials returns all serials not arrived and not missing if count given" );

$subscription = C4::Serials::GetSubscription($subscriptionid); # Retrieve the updated subscription

my @serialseqs;
for my $am ( @arrived_missing ) {
    if ( grep {/^$am->{status}$/} qw( 4 41 42 43 44 ) ) {
        push @serialseqs, $am->{serialseq}
    } elsif ( grep {/^$am->{status}$/} qw( 5 ) ) {
        push @serialseqs, 'not issued ' . $am->{serialseq};
    }
}
is( $subscription->{missinglist}, join('; ', @serialseqs), "subscription missinglist is updated after ModSerialStatus" );

subtest "Do not generate an expected if one already exists" => sub {
    plan tests => 2;
    my ($expected_serial) = GetSerials2( $subscriptionid, [1] );

    #Find serialid for serial with status Expected
    my $serialexpected = ( C4::Serials::findSerialsByStatus( 1, $subscriptionid ) )[0];

    #delete serial with status Expected
    C4::Serials::ModSerialStatus( $serialexpected->{serialid}, $serialexpected->{serialseq}, $publisheddate, $publisheddate, $publisheddate, '1', 'an useless note' );
    @serialsByStatus = C4::Serials::findSerialsByStatus( 1, $subscriptionid );
    is( @serialsByStatus, 1, "ModSerialStatus delete corectly serial expected and create another if not exist" );

    # add 1 serial with status=Expected 1
    C4::Serials::ModSerialStatus( $expected_serial->{serialid}, 'NO.20', $publisheddate, $publisheddate, $publisheddate, '1', 'an useless note' );

    #Now we have two serials it have status expected
    #put status delete for last serial
    C4::Serials::ModSerialStatus( $serialexpected->{serialid}, $serialexpected->{serialseq}, $publisheddate, $publisheddate, $publisheddate, '1', 'an useless note' );

    #try if create or not another serial with status is expected
    @serialsByStatus = C4::Serials::findSerialsByStatus( 1, $subscriptionid );
    is( @serialsByStatus, 1, "ModSerialStatus delete corectly serial expected and not create another if exists" );
};

$dbh->rollback;

sub get_biblio {
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
    my ($bibnum, $bibitemnum) = AddBiblio($bib, '');
    return ($bibnum, $bibitemnum);
}
