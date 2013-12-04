#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 37;

use C4::Context;
use Koha::AdditionalField;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do( q|DELETE FROM additional_fields| );
$dbh->do( q|DELETE FROM additional_field_values| );

my $afs = Koha::AdditionalField->all;
is( scalar( @$afs ), 0, "all: there is no additional field" );

my $af1_name = q|af1|;
my $af1 = Koha::AdditionalField->new({
    tablename => 'subscription',
    name => $af1_name,
    authorised_values_category => '',
    marcfield => '',
    searchable => 1,
});
is ( $af1->name, $af1_name, "new: name value is kept" );

$af1->insert;
like ( $af1->id, qr|^\d+$|, "new: populate id value" );

my $af2_name = q|af2|;
my $af2_marcfield = q|200$a|;
my $af2_searchable = 1;
my $af2_tablename = q|subscription|;
my $af2_avc = q|LOST|;
my $af2 = Koha::AdditionalField->new({
    tablename => $af2_tablename,
    name => $af2_name,
    authorised_value_category => $af2_avc,
    marcfield => $af2_marcfield,
    searchable => $af2_searchable,
});
$af2->insert;
my $af2_id = $af2->id;
$af2 = Koha::AdditionalField->new({ id => $af2_id })->fetch;
is( ref($af2) , q|Koha::AdditionalField|, "fetch: return an object" );
is( $af2->id, $af2_id, "fetch: id for af2" );
is( $af2->tablename, $af2_tablename, "fetch: tablename for af2" );
is( $af2->name, $af2_name, "fetch: name for af2" );
is( $af2->authorised_value_category, $af2_avc, "fetch: authorised_value_category for af2" );
is( $af2->marcfield, $af2_marcfield, "fetch: marcfield for af2" );
is( $af2->searchable, $af2_searchable, "fetch: searchable for af2" );

my $af3 = Koha::AdditionalField->new({
    tablename => 'a_table',
    name => q|af3|,
    authorised_value_category => '',
    marcfield => '',
    searchable => 1,
});
$af3->insert;

my $af_common = Koha::AdditionalField->new({
    tablename => 'subscription',
    name => q|common|,
    authorised_value_category => '',
    marcfield => '',
    searchable => 1,
});
$af_common->insert;

# update
$af3->{tablename} = q|another_table|;
$af3->{name} = q|af3_mod|;
$af3->{authorised_value_category} = q|LOST|;
$af3->{marcfield} = q|200$a|;
$af3->{searchable} = 0;
my $updated = $af3->update;
$af3 = Koha::AdditionalField->new({ id => $af3->id })->fetch;
is( $updated, 1, "update: return number of affected rows" );
is( $af3->tablename, q|a_table|, "update: tablename is *not* updated, there is no sense to copy a field to another table" );
is( $af3->name, q|af3_mod|, "update: name" );
is( $af3->authorised_value_category, q|LOST|, "update: authorised_value_category" );
is( $af3->marcfield, q|200$a|, "update: marcfield" );
is( $af3->searchable, q|0|, "update: searchable" );

# fetch all
$afs = Koha::AdditionalField->all;
is( scalar( @$afs ), 4, "all: got 4 additional fields" );
$afs = Koha::AdditionalField->all({tablename => 'subscription'});
is( scalar( @$afs ), 3, "all: got 3 additional fields for the subscription table" );
$afs = Koha::AdditionalField->all({searchable => 1});
is( scalar( @$afs ), 3, "all: got 3 searchable additional fields" );
$af3->delete;
$afs = Koha::AdditionalField->all;
is( scalar( @$afs ), 3, "all: got 3 additional fields after deleting one" );


# Testing additional field values

## Creating 2 subscriptions
use C4::Acquisition;
use C4::Biblio;
use C4::Budgets;
use C4::Serials;
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;

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
    budget_period_enddate   => '01-01-2016',
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

my $subscriptionid1 = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber,
    '2013-01-01', $frequency_id, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "notes",undef, '2013-01-01', undef, $pattern_id,
    undef,       undef,  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '2013-01-01', 0
);

my $subscriptionid2 = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber,
    '2013-01-01', $frequency_id, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "notes",undef, '2013-01-01', undef, $pattern_id,
    undef,       undef,  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '2013-01-01', 0
);

# insert
my $af1_values = {
    $subscriptionid1 => "value_for_af1_$subscriptionid1",
    $subscriptionid2 => "value_for_af1_$subscriptionid2",
};
$af1->{values} = $af1_values;
$af1->insert_values;

my $af2_values = {
    $subscriptionid1 => "old_value_for_af2_$subscriptionid1",
    $subscriptionid2 => "old_value_for_af2_$subscriptionid2",
};
$af2->{values} = $af2_values;
$af2->insert_values;
my $new_af2_values = {
    $subscriptionid1 => "value_for_af2_$subscriptionid1",
    $subscriptionid2 => "value_for_af2_$subscriptionid2",
};
$af2->{values} = $new_af2_values;
$af2->insert_values; # Insert should replace old values

my $common_values = {
    $subscriptionid1 => 'common_value',
    $subscriptionid2 => 'common_value',
};

$af_common->{values} = $common_values;
$af_common->insert_values;

# fetch_values
$af1 = Koha::AdditionalField->new({ id => $af1->id })->fetch;
$af2 = Koha::AdditionalField->new({ id => $af2->id })->fetch;

$af1->fetch_values;
is_deeply ( $af1->values, {$subscriptionid1 => qq|value_for_af1_$subscriptionid1|, $subscriptionid2 => qq|value_for_af1_$subscriptionid2| }, "fetch_values: without argument, returns 2 records" );
$af1->fetch_values({ record_id => $subscriptionid1 });
is_deeply ( $af1->values, {$subscriptionid1 => qq|value_for_af1_$subscriptionid1|}, "fetch_values: values for af1 and subscription1" );
$af2->fetch_values({ record_id => $subscriptionid2 });
is_deeply ( $af2->values, {$subscriptionid2 => qq|value_for_af2_$subscriptionid2|}, "fetch_values: values for af2 and subscription2" );

# fetch_all_values
eval{
    $af1->fetch_all_values;
};
like ( $@, qr|^BAD CALL|, 'fetch_all_values: fail if called with a blessed object' );

my $fetched_values = Koha::AdditionalField->fetch_all_values({ tablename => 'subscription' });
my $expected_values = {
    $subscriptionid1 => {
        $af1_name => qq|value_for_af1_$subscriptionid1|,
        $af2_name => qq|value_for_af2_$subscriptionid1|,
        'common' => q|common_value|,
    },
    $subscriptionid2 => {
        $af1_name => qq|value_for_af1_$subscriptionid2|,
        $af2_name => qq|value_for_af2_$subscriptionid2|,
        'common' => q|common_value|,
    }
};
is_deeply ( $fetched_values, $expected_values, "fetch_all_values: values for table subscription" );

my $expected_values_1 = {
    $subscriptionid1 => {
        $af1_name => qq|value_for_af1_$subscriptionid1|,
        $af2_name => qq|value_for_af2_$subscriptionid1|,
        common => q|common_value|,
    }
};
my $fetched_values_1 = Koha::AdditionalField->fetch_all_values({ tablename => 'subscription', record_id => $subscriptionid1 });
is_deeply ( $fetched_values_1, $expected_values_1, "fetch_all_values: values for subscription1" );

# get_matching_record_ids
eval{
    $af1->get_matching_record_ids;
};
like ( $@, qr|^BAD CALL|, 'get_matching_record_ids: fail if called with a blessed object' );

my $matching_record_ids = Koha::AdditionalField->get_matching_record_ids;
is_deeply ( $matching_record_ids, [], "get_matching_record_ids: return [] if no argument given" );
$matching_record_ids = Koha::AdditionalField->get_matching_record_ids({ tablename => 'subscription' });
is_deeply ( $matching_record_ids, [], "get_matching_record_ids: return [] if no field given" );

my $fields = [
    {
        name => $af1_name,
        value => qq|value_for_af1_$subscriptionid1|
    }
];
$matching_record_ids = Koha::AdditionalField->get_matching_record_ids({ tablename => 'subscription', fields => $fields });
is_deeply ( $matching_record_ids, [ $subscriptionid1 ], "get_matching_record_ids: field $af1_name: value_for_af1_$subscriptionid1 matches subscription1" );

$fields = [
    {
        name => $af1_name,
        value => qq|value_for_af1_$subscriptionid1|
    },
    {
        name => $af2_name,
        value => qq|value_for_af2_$subscriptionid1|,
    }
];
$matching_record_ids = Koha::AdditionalField->get_matching_record_ids({ tablename => 'subscription', fields => $fields });
is_deeply ( $matching_record_ids, [ $subscriptionid1 ], "get_matching_record_ids: fields $af1_name:value_for_af1_$subscriptionid1 and $af2_name:value_for_af2_$subscriptionid1 match subscription1" );

$fields = [
    {
        name => 'common',
        value => q|common_value|,
    }
];
$matching_record_ids = Koha::AdditionalField->get_matching_record_ids({ tablename => 'subscription', fields => $fields });
my $exists = grep /$subscriptionid1/, @$matching_record_ids;
is ( $exists, 1, "get_matching_record_ids: field common: common_value matches subscription1" );
$exists = grep /$subscriptionid2/, @$matching_record_ids;
is ( $exists, 1, "get_matching_record_ids: field common: common_value matches subscription2 too" );
$exists = grep /not_existent_id/, @$matching_record_ids;
is ( $exists, 0, "get_matching_record_ids: field common: common_value does not inexistent id" );

$fields = [
    {
        name => 'common',
        value => q|common|,
    }
];
$matching_record_ids = Koha::AdditionalField->get_matching_record_ids({ tablename => 'subscription', fields => $fields, exact_match => 0 });
$exists = grep /$subscriptionid1/, @$matching_record_ids;
is ( $exists, 1, "get_matching_record_ids: field common: common% matches subscription1" );
$exists = grep /$subscriptionid2/, @$matching_record_ids;
is ( $exists, 1, "get_matching_record_ids: field common: common% matches subscription2 too" );
$exists = grep /not_existent_id/, @$matching_record_ids;
is ( $exists, 0, "get_matching_record_ids: field common: common% does not inexistent id" );


$dbh->rollback;
