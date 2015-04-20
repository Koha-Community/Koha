#!/usr/bin/perl

use Modern::Perl;

use Koha::Database;
use Koha::Overdues::Calendar;
use Koha::DateUtils;

use t::lib::TestBuilder;

use Test::More tests => 13;

use_ok('Koha::Overdues::Calendar');

my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

#### Note: this test should never run on production environment ####

my $library = $builder->build({
    source => 'Branch',
});

my $calendar = Koha::Overdues::Calendar->new();

## Clearung the tables first ##
$calendar->deleteAllWeekdays();
$calendar->deleteAllExceptiondays();

## Start testing ##
$calendar->upsertWeekdays($library->{branchcode},'1,2,3,4,5,6,7');
is(ref($calendar), "Koha::Overdues::Calendar", 'Returned hashref');

my $branches = $calendar->getNotifiableBranches();
is(ref($branches), 'ARRAY', 'Returned array');
is($branches->[0], $library->{branchcode}, 'Branch matched');

is($calendar->getWeekdays(), undef, 'Branchcode was not set');
is($calendar->getWeekdays($library->{branchcode}), '1,2,3,4,5,6,7', 'Correct weekdays');

ok($calendar->getBranchesWithWeekday('1'), 'There are branches with weekday 1.');
my $two_days_ahead = DateTime->today(time_zone => C4::Context->tz())->add( days => 2 );
my $date = output_pref({ dt => dt_from_string( $two_days_ahead ), dateonly => 1, dateformat => 'iso'});
$calendar->upsertException($library->{branchcode}, $date);

my ($oldException, $error) = $calendar->getException($library->{branchcode}, $date);

is($oldException->ymd(), $date, 'Date exception has been set');
is($error, undef, 'No error message');

($oldException, $error) = $calendar->getException($library->{branchcode}, '');

is($error, 'NODATE', 'Date was not set');

my $today = dt_from_string();
$calendar->upsertException($library->{branchcode}, $today);
my $availableforgathering = $calendar->getNotifiableBranches($today);
is($availableforgathering->[0], $library->{branchcode}, 'Branch is available for gathering');

$calendar->deleteException($library->{branchcode});
is($calendar->getException($library->{branchcode}, $date), undef, 'Exception date has been removed');

$calendar->deleteWeekdays($library->{branchcode});
is($calendar->getWeekdays($library->{branchcode}), undef, 'Week days has been removed');