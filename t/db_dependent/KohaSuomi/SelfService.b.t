#!perl

use Modern::Perl '2014';
use Test::More;
use Test::MockModule;
use Try::Tiny;

use DateTime;
use Scalar::Util qw(blessed);
use File::Basename;

use C4::SelfService;
use C4::Members::Attributes;
use Koha::Patrons;
use Koha::Patron::Debarments;
use C4::SIP::ILS::Patron;

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
    $schema->storage->txn_begin;
    my $ilsPatron; #Scenario ILS patron
    my $debarment; #Debarment of the scenario borrower
    my $f; #Fines of the scenario borrower

    my $user = $builder->build({
        source => 'Borrower',
        value => {
            cardnumber => '11A01',
            categorycode => 'ST',
            dateofbirth => $todayYmd,
            lost     => 0,
            branchcode => 'CPL',
            gonenoaddress => 0

        }
    });
    my $b = Koha::Patrons->find($user->{borrowernumber});
    eval {
    subtest("Set opening hours", sub {
        $hours = t::db_dependent::opening_hours_context::createContext;
        C4::Context->set_preference("OpeningHours",$hours);
        ok(1, $hours);
    });
    subtest("Clear system preference 'SSRules'", sub {
        C4::Context->set_preference("SSRules",'');
        ok(1, "Step ok");
    });
    subtest("Given a user with all relevant blocks and bans", sub {
        C4::Members::Attributes::SetBorrowerAttributes($b->borrowernumber, [{ code => 'SSBAN', value => '1' }]);

        Koha::Patron::Debarments::AddDebarment({borrowernumber => $b->borrowernumber});
        $debarment = Koha::Patron::Debarments::GetDebarments({borrowernumber => $b->borrowernumber})->[0];
        $f = Koha::Account::Line->new({ borrowernumber => $b->borrowernumber, amountoutstanding => 1000, note => 'fid' })->store();
        ok(1, "Step ok");
    });
    subtest("Self-service resource accessing is not properly configured", sub {
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::FeatureUnavailable') , "System preferences not properly set");
        };
    });
    subtest("Given a system preference 'SSRules', which has age limit of 15 years and allows borrower categories 'PT S'", sub {
        C4::Context->set_preference("SSRules",'15:PT S');
        ok(1, "Step ok");
    });
    subtest("Self-service feature works, but terms and conditions are not accepted", sub {
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService::TACNotAccepted') , "Finely behaving user hasn't agreed to terms and conditions of self-service usage");
        };
    });
    subtest("Self-service terms and conditions accepted, but user's self-service permissions have been revoked", sub {
        C4::Members::Attributes::SetBorrowerAttributes($b->borrowernumber, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '1' }]);
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService::PermissionRevoked') , "User Self-Service permission revoked");
        };
    });
    subtest("Self-service permission reinstituted, but the user has a wrong borrower category", sub {
        C4::Members::Attributes::SetBorrowerAttributes($b->borrowernumber, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '0' }]);
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService::BlockedBorrowerCategory') , "User's borrower category is not whitelisted");
        };
    });
    subtest("Borrower category changed, but the user is still underaged", sub {
        $b->categorycode('PT'); $b->store();
        C4::Members::Attributes::SetBorrowerAttributes($b->borrowernumber, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '0' }]);
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);
        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService::Underage') , "Underage user has no permission");
        };
    });
    subtest("Borrower grew up, but is still debarred", sub {
        $b->dateofbirth('2000-01-01'); $b->store();
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService') , "User has no permission");
        };
    });
    subtest("Borrower debarment lifted, but still has too many fines", sub {
        Koha::Patron::Debarments::DelDebarment($debarment->{borrower_debarment_id});
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService') , "User has no permission");
        };
    });
    subtest("Borrower is cleaned from his sins, but still the library is closed", sub {
        my $account = Koha::Account->new({ patron_id => $b->id });
        $account->pay( { amount => 1000 } );
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);
        try {
            C4::SelfService::CheckSelfServicePermission($ilsPatron, 'UPL', 'accessMainDoor');
            ok(0 , "EXPECTED EXCEPTION");
        } catch {
            ok(blessed($_) && $_->isa('Koha::Exception::SelfService::OpeningHours') , "Library is closed");
        };
    });
    subtest("Borrower tries another library and is allowed access", sub {
        C4::Members::Attributes::SetBorrowerAttributes($b->borrowernumber, [{ code => 'SST&C', value => '1' },
                                                                            { code => 'SSBAN', value => '0' }]);
        $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);
        
        ok(C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor'),
           "Finely behaving user accesses a self-service resource.");
    });
    subtest("Check the log entries", sub {
        my $logs = C4::SelfService::GetAccessLogs($b->borrowernumber);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 0, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'misconfigured', $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 1, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'missingT&C',    $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 2, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'revoked',       $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 3, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'blockBorCat',   $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 4, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'underage',      $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 5, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'denied',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 6, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'denied',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 7, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'closed',        $userenv);
        t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 8, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'granted',       $userenv);
    });
    };
    if ($@) {
        ok(0, $@);
    }
    C4::SelfService::FlushLogs();
    $schema->storage->txn_rollback;
});
done_testing();

