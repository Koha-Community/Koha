
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

subtest("Age limit threshold tests", sub {
    $schema->storage->txn_begin;
    my ($b, $ilsPatron, $rv);
    eval { #start

    ## Set the age limit ##
    C4::Context->set_preference("SSRules",'15:PT S');

    my $user = $builder->build({
        source => 'Borrower',
        value => {
            cardnumber => '11A01',
            categorycode => 'PT',
            dateofbirth => $todayYmd,
            lost     => 0,
            branchcode => 'CPL',
            gonenoaddress => 0

        }
    });
    my $b = Koha::Patrons->find($user->{borrowernumber});
    C4::Members::Attributes::SetBorrowerAttributes($b->borrowernumber, [{ code => 'SST&C', value => '1' }]);
    $ilsPatron = C4::SIP::ILS::Patron->new($b->cardnumber);

    try {
        $rv = C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor');
        ok(0 , "Underage user has no permission");
    } catch {
        ok(blessed($_) && $_->isa('Koha::Exception::SelfService::Underage') , "Underage user has no permission");
    };

    ## Disable age limit alltogether ##
    C4::Context->set_preference("SSRules",'0:PT S');

    ok(C4::SelfService::CheckSelfServicePermission($ilsPatron, 'CPL', 'accessMainDoor'),
       "Underage user agreed to T&C but still has no permission.");

    ##Check for log entries
    my $logs = C4::SelfService::GetAccessLogs($ilsPatron->{borrowernumber});
    t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 0, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'underage', $userenv);
    t::db_dependent::KohaSuomi::SelfService_context::testLogs($logs, 1, $b->borrowernumber, 'accessMainDoor', $todayYmd, 'granted',  $userenv);

    }; #stop
    if ($@) {
        ok(0, $@);
    }
    C4::SelfService::FlushLogs();
    $schema->storage->txn_rollback;
});

done_testing();
