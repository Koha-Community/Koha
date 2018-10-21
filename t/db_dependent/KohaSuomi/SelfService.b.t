#!perl

use Modern::Perl '2014';
use Test::Most tests => 2;
use Test::MockModule;
use Try::Tiny;

use DateTime;
use Scalar::Util qw(blessed);
use File::Basename;

use C4::SelfService;
use C4::Members::Attributes;
use Koha::Patrons;
use Koha::Patron::Debarments;

use t::db_dependent::KohaSuomi::SelfService_context;
use t::db_dependent::opening_hours_context;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::Account::Line;


use Koha::Libraries;
use Koha::Exception::FeatureUnavailable;
use Koha::Exception::BadSystemPreference;
use Koha::Exception::NoSystemPreference;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $todayYmd = DateTime->now()->ymd('-');
my $hours;

C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv(0,0,'SSAPIUser','firstname','surname', 'BRANCH1', 'Library 1', 0, '', '');
my $userenv = C4::Context->userenv;

subtest("Scenario: User with all possible blocks and bans tries to access a Self-Service resource. Testing that exceptions are reported in the correct order.", sub {
    plan tests => 16;

    $schema->storage->txn_begin;
    my $debarment; #Debarment of the scenario borrower
    my $f; #Fines of the scenario borrower

    my $user = $builder->build({
        source => 'Borrower',
        value => {
            cardnumber => '11A01',
            categorycode => 'ST',
            dateofbirth => $todayYmd,
            dateexpiry => '2001-01-01',
            lost     => 1,
            branchcode => 'CPL',
            gonenoaddress => 0,
        }
    });
    my $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

    subtest("Set opening hours", sub {
        plan tests => 1;

        $hours = t::db_dependent::opening_hours_context::createContext;
        C4::Context->set_preference("OpeningHours",$hours);
        ok(1, $hours);
    });
    subtest("Clear system preference 'SSRules'", sub {
        plan tests => 1;

        C4::Context->set_preference("SSRules",'');
        Koha::Caches->get_instance()->clear_from_cache('SSRules');
        ok(1, "Step ok");
    });
    subtest("Given a user with all relevant blocks and bans", sub {
        plan tests => 2;

        C4::Members::Attributes::SetBorrowerAttributes($b->{borrowernumber}, [{ code => 'SSBAN', value => '1' }]);

        Koha::Patron::Debarments::AddDebarment({borrowernumber => $b->{borrowernumber}});
        ok($debarment = Koha::Patron::Debarments::GetDebarments({borrowernumber => $b->{borrowernumber}})->[0],
           "Debarment given");

        ok($f = Koha::Account::Line->new({ borrowernumber => $b->{borrowernumber}, amountoutstanding => 1000, note => 'fid' })->store(),
           "Fine given");
    });
    subtest("Self-service resource accessing is not properly configured", sub {
        plan tests => 1;

        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::FeatureUnavailable',
                  "System preferences not properly set");
    });
    subtest("Given a system preference 'SSRules'", sub {
        plan tests => 1;

        C4::Context->set_preference("SSRules",
            "---\n".
            "TaC: 1\n".
            "Permission: 1\n".
            "BorrowerCategories: PT S\n".
            "MinimumAge: 15\n".
            "MaxFines: 1\n".
            "CardExpired: 1\n".
            "CardLost: 1\n".
            "Debarred: 1\n".
            "OpeningHours: 1\n".
            "\n");
        Koha::Caches->get_instance()->clear_from_cache('SSRules');
        ok(1, "Step ok");
    });
    subtest("Self-service feature works, but terms and conditions are not accepted", sub {
        plan tests => 1;

        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService::TACNotAccepted',
                  "Finely behaving user hasn't agreed to terms and conditions of self-service usage");
    });
    subtest("Self-service terms and conditions accepted, but user's self-service permissions have been revoked", sub {
        plan tests => 1;

        C4::Members::Attributes::SetBorrowerAttributes($b->{borrowernumber}, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '1' }]);
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService::PermissionRevoked',
                  "User Self-Service permission revoked");
    });
    subtest("Self-service permission reinstituted, but the user has a wrong borrower category", sub {
        plan tests => 1;

        C4::Members::Attributes::SetBorrowerAttributes($b->{borrowernumber}, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '0' }]);
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService::BlockedBorrowerCategory',
                  "User's borrower category is not whitelisted");
    });
    subtest("Borrower category changed, but the user is still underaged", sub {
        plan tests => 5;

        $b->{categorycode} = ('PT'); C4::Members::ModMember(%$b);

        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});
        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService::Underage',
                  "Underage user has no permission");

        $b->{dateofbirth} = DateTime->now(time_zone => C4::Context->tz())->subtract(years => 15)->add(days => 1)->iso8601();
        ok(C4::Members::ModMember(%$b),
                  "Underage user is one day to 15 years old");
        throws_ok(sub {C4::SelfService::_CheckMinimumAge($b, {MinimumAge => 15})}, 'Koha::Exception::SelfService::Underage',
                  "Underage user has no permission");

        $b->{dateofbirth} = DateTime->now(time_zone => C4::Context->tz())->subtract(years => 15)->iso8601();
        ok(C4::Members::ModMember(%$b),
                  "Underage user is 15 years and some seconds old");

        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});
        lives_ok(sub {C4::SelfService::_CheckMinimumAge($b, {MinimumAge => 15})},
                  "Underage user is no longer underage");
    });
    subtest("Borrower grew up, but his card is now expired", sub {
        plan tests => 2;

        $b->{dateofbirth} = ('2000-01-01'); C4::Members::ModMember(%$b);
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService',
                  "User has no permission");
        like($@, qr/Card expired/, "And the card is expired");
    });
    subtest("Borrower renewed his card, but he lost his card!", sub {
        plan tests => 2;

        $b->{dateexpiry} = ('2075-01-01'); C4::Members::ModMember(%$b); #For sure Koha is no longer used in 2075
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService',
                  "User has no permission");
        like($@, qr/Card lost/, "And the card is lost");
    });
    subtest("Borrower found his card, but is still debarred", sub {
        plan tests => 2;

        $b->{lost} = 0; C4::Members::ModMember(%$b);
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService',
                  "User has no permission");
        like($@, qr/Debarred/, "And is debarred");
    });
    subtest("Borrower debarment lifted, but still has too many fines", sub {
        plan tests => 2;

        Koha::Patron::Debarments::DelDebarment($debarment->{borrower_debarment_id});
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService',
                  "User has no permission");
        like($@, qr/Too many fines '1000/, "And has too many fines");
    });
    subtest("Borrower is cleaned from his sins, but still the library is closed", sub {
        plan tests => 1;

        my $account = Koha::Account->new({ patron_id => $b->{borrowernumber} });
        $account->pay( { amount => 1000 } );
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});
        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'UPL', 'accessMainDoor')}, 'Koha::Exception::SelfService::OpeningHours',
                  "Library is closed");
    });
    subtest("Borrower tries another library and is allowed access", sub {
        plan tests => 1;

        C4::Members::Attributes::SetBorrowerAttributes($b->{borrowernumber}, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '0' }]);
        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        ok(C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor'),
           "Finely behaving user accesses a self-service resource.");
    });
    subtest("Check the log entries", sub {
        plan tests => 66;

        my $logs = C4::SelfService::GetAccessLogs($b->{borrowernumber});
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 0, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'misconfigured', $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 1, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'missingT&C',    $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 2, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'revoked',       $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 3, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'blockBorCat',   $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 4, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'underage',      $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 5, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'denied',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 6, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'denied',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 7, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'denied',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 8, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'denied',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 9, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'closed',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 10, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'granted',       $userenv);
    });

    C4::SelfService::FlushLogs();
    $schema->storage->txn_rollback;
});


subtest("Scenario: User with all possible blocks and bans tries to access a Self-Service resource. Library only checks for too many fines.", sub {
    plan tests => 5;

    $schema->storage->txn_begin;
    my $debarment; #Debarment of the scenario borrower
    my $f; #Fines of the scenario borrower

    my $user = $builder->build({
        source => 'Borrower',
        value => {
            cardnumber => '11A01',
            categorycode => 'ST',
            dateofbirth => $todayYmd,
            dateexpiry => '2001-01-01',
            lost     => 1,
            branchcode => 'CPL',
            gonenoaddress => 0,
        }
    });
    my $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

    subtest("Given a user with all relevant blocks and bans", sub {
        plan tests => 2;

        C4::Members::Attributes::SetBorrowerAttributes($b->{borrowernumber}, [{ code => 'SSBAN', value => '1' }]);

        Koha::Patron::Debarments::AddDebarment({borrowernumber => $b->{borrowernumber}});
        ok($debarment = Koha::Patron::Debarments::GetDebarments({borrowernumber => $b->{borrowernumber}})->[0],
           "Debarment given");

        ok($f = Koha::Account::Line->new({ borrowernumber => $b->{borrowernumber}, amountoutstanding => 1000, note => 'fid' })->store(),
           "Fine given");
    });
    subtest("Given a system preference 'SSRules'", sub {
        plan tests => 1;

        C4::Context->set_preference("SSRules",
            "---\n".
            "MaxFines: 1\n".
            "\n");
        Koha::Caches->get_instance()->clear_from_cache('SSRules');
        ok(1, "Step ok");
    });
    subtest("Borrower tries to access the library, but has too many fines", sub {
        plan tests => 2;

        $b = C4::Members::GetMember(borrowernumber => $user->{borrowernumber});

        throws_ok(sub {C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor')}, 'Koha::Exception::SelfService',
                  "User has no permission");
        like($@, qr/Too many fines '1000/, "And has too many fines");
    });
    subtest("Borrower pays his fines and is allowed access", sub {
        plan tests => 2;

        my $account = Koha::Account->new({ patron_id => $b->{borrowernumber} });
        ok($account->pay( { amount => 1000 } ),
           "Fines paid");

        ok(C4::SelfService::CheckSelfServicePermission($b, 'CPL', 'accessMainDoor'),
           "Naughty user accesses a self-service resource.");
    });
    subtest("Check the log entries", sub {
        plan tests => 12;

        my $logs = C4::SelfService::GetAccessLogs($b->{borrowernumber});
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 0, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'denied',  $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 1, $b->{borrowernumber}, 'accessMainDoor', $todayYmd, 'granted', $userenv);
    });

    C4::SelfService::FlushLogs();
    $schema->storage->txn_rollback;
});


done_testing();
