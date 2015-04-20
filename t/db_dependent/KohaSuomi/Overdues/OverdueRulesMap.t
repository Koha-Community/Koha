#!/usr/bin/perl

use Modern::Perl;

use Koha::Database;
use Koha::Overdues::Calendar;
use Koha::DateUtils;

use t::lib::TestBuilder;

use Test::More tests => 10;

use_ok('Koha::Overdues::OverdueRulesMap');

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

# $dbh->do(q|DELETE FROM overduerules|);
# $dbh->do(q|DELETE FROM overduerules_transport_types|);

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $orm = Koha::Overdues::OverdueRulesMap->new();

my $params = {  branchCode => 'CPL',
                borrowerCategory => 'STAFF',
                letterNumber => 1,
                delay => 20,
                letterCode => 'ODUE1',
                debarred => 1,
                fine => 2.5,
                messageTransportTypes => { email => 1, print => 1,
                },
             };     

my ($overdueRule, $error) = $orm->upsertOverdueRule( $params );

$orm->store();

#is($orm, "Koha::Overdues::OverdueRulesMap", "Overdue rules has been populated.");

my $lastoverduerule = $orm->getLastOverdueRules();
isa_ok($lastoverduerule, "ARRAY");

my $newOverdueRule;
($newOverdueRule, $error) = Koha::Overdues::OverdueRule->new($params);
my $oldOverdueRule = $orm->getOverdueRule( $params->{branchCode}, $params->{borrowerCategory}, $params->{letterNumber} );

last unless is_deeply($oldOverdueRule, $newOverdueRule, "We got what we put");
last unless isa_ok($newOverdueRule, 'Koha::Overdues::OverdueRule');

$params->{messageTransportTypes} = "email";

($overdueRule, $error) = $orm->upsertOverdueRule($params);

is($error, 'NOTRANSPORTTYPES', "Adding a bad overdueRule failed.");

$oldOverdueRule = $orm->getOverdueRule( $params->{branchCode}, $params->{borrowerCategory}, $params->{letterNumber} );
isa_ok($oldOverdueRule, 'Koha::Overdues::OverdueRule');

$error = $orm->deleteOverdueRule($oldOverdueRule);

$orm->store();

#Test from $orm internal memory structure
$newOverdueRule = $orm->getOverdueRule( $params->{branchCode}, $params->{borrowerCategory}, $params->{letterNumber} );
is($newOverdueRule, undef, 'OverdueRule succesfully deleted from internal memory');

#Refresh the $orm from DB
$orm = Koha::Overdues::OverdueRulesMap->new();
$newOverdueRule = $orm->getOverdueRule( $params->{branchCode}, $params->{borrowerCategory}, $params->{letterNumber} );

is($newOverdueRule, undef, 'OverdueRule succesfully deleted from the DB');

($overdueRule, $error) = $orm->upsertOverdueRule( $params );

$orm->store();

#is(ref($orm), "Koha::Overdues::OverdueRulesMap", "Overdue rules has been populated again.");
$lastoverduerule = $orm->getLastOverdueRules();
isa_ok($lastoverduerule, "ARRAY");

$orm->deleteAllOverdueRules();

$orm = Koha::Overdues::OverdueRulesMap->new();
$lastoverduerule = $orm->getLastOverdueRules();
is(@$lastoverduerule, 0, 'OverdueRules succesfully deleted from internal memory');

$schema->storage->txn_rollback;