#!/usr/bin/perl

use C4::Context;
use Test::More tests => 27;
use Modern::Perl;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

use C4::Serials::Frequency;

# Start by deleting all frequencies.
my @frequencies = GetSubscriptionFrequencies();
foreach my $f (@frequencies) {
    DelSubscriptionFrequency($f->{id});
}

@frequencies = GetSubscriptionFrequencies();
is(scalar @frequencies, 0, "There is no frequencies in database");

my $frequency = GetSubscriptionFrequency(1);
is($frequency, undef, "GetSubscriptionFrequency(1) returns undef");

my $rv = ModSubscriptionFrequency($frequency);
is($rv, undef, "ModSubscriptionFrequency(undef) returns undef");
$frequency = {};
$rv = ModSubscriptionFrequency($frequency);
is($rv, undef, "ModSubscriptionFrequency({}) returns undef");
# returns 0 because id doesn't exist
$frequency = { id => 1, description => "Test frequency 1" };
$rv = ModSubscriptionFrequency($frequency);
is($rv, '0E0', "ModSubscriptionFrequency({id=1,description=>'Test frequency 1'}) returns '0 but true'");

$frequency = undef;
my $id = AddSubscriptionFrequency($frequency);
is($id, undef, "AddSubscriptionFrequency(undef) returns undef");
$frequency = {};
$id = AddSubscriptionFrequency($frequency);
is($id, undef, "AddSubscriptionFrequency({}) returns undef");
$frequency = { description => "Test frequency 1" };
$id = AddSubscriptionFrequency($frequency);
ok((defined($id) && ($id > 0)), "AddSubscriptionFrequency({description => 'Test frequency 1'}) returns frequency id");

$frequency = GetSubscriptionFrequency($id);
isa_ok($frequency, 'HASH', "GetSubscriptionFrequency($id)");
is($frequency->{description}, "Test frequency 1", "description OK");
is($frequency->{unit}, undef, "unit OK");
is($frequency->{issuesperunit}, 1, "issuesperunit OK");
is($frequency->{unitsperissue}, 1, "unitsperissue OK");
is($frequency->{expectedissuesayear}, undef, "expectedissuesayear OK");
is($frequency->{displayorder}, undef, "displayorder OK");

$frequency->{description} = $frequency->{description} . " (modified)";
$frequency->{unit} = 'day';
$frequency->{unitsperissue} = 3;
$frequency->{displayorder} = 1;
$rv = ModSubscriptionFrequency($frequency);
is($rv, 1, "ModSubscriptionFrequency(\$frequency) returns 1");

$frequency = GetSubscriptionFrequency($id);
isa_ok($frequency, 'HASH', "GetSubscriptionFrequency($id)");
is($frequency->{description}, "Test frequency 1 (modified)", "description OK");
is($frequency->{unit}, 'day', "unit OK");
is($frequency->{issuesperunit}, 1, "issuesperunit OK");
is($frequency->{unitsperissue}, 3, "unitsperissue OK");
is($frequency->{expectedissuesayear}, undef, "expectedissuesayear OK");
is($frequency->{displayorder}, 1, "displayorder OK");

@frequencies = GetSubscriptionFrequencies();
is(scalar @frequencies, 1, "There is one frequency");

# Add another frequency
undef $frequency->{id};
my $id2 = AddSubscriptionFrequency($frequency);

@frequencies = GetSubscriptionFrequencies();
is(scalar @frequencies, 2, "There are two frequencies");

# Delete one frequency
DelSubscriptionFrequency($id);
@frequencies = GetSubscriptionFrequencies();
is(scalar @frequencies, 1, "There is one frequency");

# Delete the other frequency
DelSubscriptionFrequency($id2);
@frequencies = GetSubscriptionFrequencies();
is(scalar @frequencies, 0, "There is no frequency");

$dbh->rollback;
