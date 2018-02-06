#!/usr/bin/perl

use C4::Context;
use Test::More tests => 95;
use Modern::Perl;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

use C4::Serials::Numberpattern;

# Start by deleting all numberpatterns.
my @numberpatterns = GetSubscriptionNumberpatterns();
foreach my $n (@numberpatterns) {
    DelSubscriptionNumberpattern($n->{id});
}

@numberpatterns = GetSubscriptionNumberpatterns();
is(scalar @numberpatterns, 0, "There is no numberpatterns in database");

my $numberpattern = GetSubscriptionNumberpattern(1);
is($numberpattern, undef, "GetSubscriptionNumberpattern(1) returns undef");

my $rv = ModSubscriptionNumberpattern($numberpattern);
is($rv, undef, "ModSubscriptionNumberpattern(undef) returns undef");
$numberpattern = {};
$rv = ModSubscriptionNumberpattern($numberpattern);
is($rv, undef, "ModSubscriptionNumberpattern({}) returns undef");
# returns 0 because id doesn't exist
$numberpattern = { id => 1, label => "Test numberpattern 1", description => '' };
$rv = ModSubscriptionNumberpattern($numberpattern);
is($rv, '0E0', "ModSubscriptionNumberpattern({id=1,label=>'Test numberpattern 1'}) returns '0 but true'");

$numberpattern = undef;
my $id = AddSubscriptionNumberpattern($numberpattern);
is($id, undef, "AddSubscriptionNumberpattern(undef) returns undef");
$numberpattern = {};
$id = AddSubscriptionNumberpattern($numberpattern);
is($id, undef, "AddSubscriptionNumberpattern({}) returns undef");
$numberpattern = { label => "Test numberpattern 1", numberingmethod => "{X}", description => '' };
$id = AddSubscriptionNumberpattern($numberpattern);
ok((defined($id) && ($id > 0)), "AddSubscriptionNumberpattern({label => 'Test numberpattern 1', numberingmethod => '{X}'}) returns numberpattern id");

$numberpattern = GetSubscriptionNumberpattern($id);
isa_ok($numberpattern, 'HASH', "GetSubscriptionNumberpattern($id)");
is($numberpattern->{label}, "Test numberpattern 1", "label OK");
is($numberpattern->{numberingmethod}, '{X}', "unit OK");
is($numberpattern->{description}, '', "description OK");
is($numberpattern->{displayorder}, undef, "displayorder OK");
foreach my $key (qw(label add every setto whenmorethan numbering)) {
    foreach my $index (1,2,3) {
        ok(exists $numberpattern->{$key . $index}, "$key$index exists");
        is($numberpattern->{$key . $index}, undef, "$key$index is undef");
    }
}

$numberpattern->{label} = $numberpattern->{label} . " (modified)";
$numberpattern->{displayorder} = 1;
my $i = 0;
foreach my $key (qw(label add every setto whenmorethan numbering)) {
    foreach my $index (1,2,3) {
        $numberpattern->{$key . $index} = $i++;
    }
}
$rv = ModSubscriptionNumberpattern($numberpattern);
is($rv, 1, "ModSubscriptionNumberpattern(\$numberpattern) returns 1");

$numberpattern = GetSubscriptionNumberpattern($id);
isa_ok($numberpattern, 'HASH', "GetSubscriptionNumberpattern($id)");
is($numberpattern->{label}, "Test numberpattern 1 (modified)", "label OK");
is($numberpattern->{numberingmethod}, '{X}', "unit OK");
is($numberpattern->{description}, '', "description OK");
is($numberpattern->{displayorder}, 1, "displayorder OK");
$i = 0;
foreach my $key (qw(label add every setto whenmorethan numbering)) {
    foreach my $index (1,2,3) {
        ok(exists $numberpattern->{$key . $index}, "$key$index exists");
        is($numberpattern->{$key . $index}, $i++, "$key$index is $i");
    }
}

@numberpatterns = GetSubscriptionNumberpatterns();
is(scalar @numberpatterns, 1, "There is one numberpattern");

# Add another numberpattern
undef $numberpattern->{id};
my $id2 = AddSubscriptionNumberpattern($numberpattern);

@numberpatterns = GetSubscriptionNumberpatterns();
is(scalar @numberpatterns, 2, "There are two numberpatterns");

# Delete one numberpattern
DelSubscriptionNumberpattern($id);
@numberpatterns = GetSubscriptionNumberpatterns();
is(scalar @numberpatterns, 1, "There is one numberpattern");

# Delete the other numberpattern
DelSubscriptionNumberpattern($id2);
@numberpatterns = GetSubscriptionNumberpatterns();
is(scalar @numberpatterns, 0, "There is no numberpattern");

$dbh->rollback;
