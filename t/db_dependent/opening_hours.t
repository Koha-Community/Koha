use Modern::Perl;
use Test::More tests => 3;
use DateTime;
use Try::Tiny;
use Scalar::Util qw(blessed);
use Koha::Logger;
Koha::Logger->setConsoleVerbosity(4);

use t::db_dependent::opening_hours_context;

use Koha::Libraries;
use Koha::Exception::FeatureUnavailable;
use Koha::Exception::BadSystemPreference;
use Koha::Exception::NoSystemPreference;

my $now = DateTime->now(
            time_zone => C4::Context->tz,
            ##Introduced as a infile-package
            formatter => HMFormatter->new()
);
#If it is not monday, turn back time until it is.
my $weekday = $now->day_of_week;
my $startOfWeek = ($weekday > 1) ? $now->clone->subtract(days => $weekday-1) : $now->clone;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $hours = t::db_dependent::opening_hours_context::createContext;

subtest 'Opening hours happy path' => sub {
    C4::Context->set_preference("OpeningHours",$hours);
    eval {

    ok(Koha::Libraries::isOpen('CPL'),
        'Branch CPL is open now');
    ok(Koha::Libraries::isOpen('FFL'),
        'Branch FFL has just opened');
    sleep(1); #Wait a second, because ending time is inclusive.
    ok(! Koha::Libraries::isOpen('IPL'),
        'Branch IPL has just closed');
    ok(! Koha::Libraries::isOpen('MPL'),
        'Branch MPL is closed');

    };
    ok(0, $@) if $@;
};

subtest 'Opening hours exceptions' => sub {
    my ($testName, $today);
    eval {

    ##TEST 1
    $testName = 'LPL throws exception because it is completely missing opening hours.';
    try {
        Koha::Libraries::isOpen('LPL');
        ok(0, "Test: $testName failed. We should get exception instead!");
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::FeatureUnavailable')) {
            ok(1, $testName);
        } else {
            ok(0, "Test: $testName failed. $_");
        }
    };


    ##TEST 1.1
    $testName = 'IPT throws exception because it is missing opening hours for one day.';
    try {
        #Rewind to Sunday, Sunday is missing opening hours.
        $today = $startOfWeek->clone->add(days => 6);
        Koha::Libraries::isOpen('IPT', $today);
        ok(0, "Test: $testName failed. We should get exception instead!");
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::FeatureUnavailable')) {
            ok(1, $testName);
        } else {
            ok(0, "Test: $testName failed. $_");
        }
    };


    ##TEST 2
    $testName = 'Throws exception because OpeningHours-syspref is malformed.';
    C4::Context->set_preference("OpeningHours",'{
                         CPL => {
                             startTime => $now->clone->subtract(hours => 3)->iso8601,
                             endTime   => $now->clone->add(     hours => 3)->iso8601,
                         },
                     }');

    try {
        Koha::Libraries::isOpen('CPL');
        ok(0, "Test: $testName failed. We should get exception instead!");
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::BadSystemPreference')) {
            ok(1, $testName);
        } else {
            ok(0, "Test: $testName failed. $_");
        }
    };


    ##TEST 3
    $testName = 'Throws exception because OpeningHours-syspref is missing.';
    C4::Context->set_preference("OpeningHours",'');

    try {
        Koha::Libraries::isOpen('IPT');
        ok(0, "Test: $testName failed. We should get exception instead!");
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::NoSystemPreference')) {
            ok(1, $testName);
        } else {
            ok(0, "Test: $testName failed. $_");
        }
    };


    };
    ok(0, $@) if $@;
};

subtest 'Daily opening hours' => sub {
    my ($today);

    C4::Context->set_preference("OpeningHours",$hours);

    eval {

    ok(1, 'Given we are accessing branch IPT');
    ok($today = $startOfWeek->clone->set_hour(6)->set_minute(45),
        'And today is monday 06:45');
    ok(! Koha::Libraries::isOpen('IPT', $today),
        'Then the branch is closed');

    ok($today = $today->set_hour(7)->set_minute(0),
        'Given today is monday 07:00');
    ok(Koha::Libraries::isOpen('IPT', $today),
        'Then the branch has just opened');

    ok($today = $today->set_hour(20)->set_minute(0),
        'Given today is monday 20:00');
    ok(! Koha::Libraries::isOpen('IPT', $today),
        'Then the branch has just closed');

    ok($today = $today->set_hour(19)->set_minute(59),
        'Given today is monday 19:59');
    ok(Koha::Libraries::isOpen('IPT', $today),
        'Then the branch is open but just closing');

    ok($today = $startOfWeek->clone->set_hour(9)->set_minute(45)->add(days => 5),
        'And today is saturday 09:45');
    ok(! Koha::Libraries::isOpen('IPT', $today),
        'Then the branch is closed');

    ok($today = $today->set_hour(10)->set_minute(0),
        'Given today is saturday 10:00');
    ok(Koha::Libraries::isOpen('IPT', $today),
        'Then the branch has just opened');

    ok($today = $today->set_hour(17)->set_minute(55),
        'Given today is saturday 17:55');
    ok(Koha::Libraries::isOpen('IPT', $today),
        'Then the branch is just closing');

    ok($today = $today->set_hour(18)->set_minute(0),
        'Given today is saturday 18:00');
    ok(! Koha::Libraries::isOpen('IPT', $today),
        'Then the branch has just closed');

    };
    ok(0, $@) if $@;
};

$schema->storage->txn_rollback;
