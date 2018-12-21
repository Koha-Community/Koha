#!perl

BEGIN {
    $ENV{LOG4PERL_VERBOSITY_CHANGE} = 6;
}

use Modern::Perl '2015';
use Data::Printer;
use Test::Most tests => 5;

use C4::SelfService::BlockManager;

use Koha::AuthUtils;
use Koha::Database;

use C4::SIP::ILS;
use C4::SIP::Sip::MsgType;

###   Set up global test context   ###
use t::lib::TestBuilder;
#my $schema  = Koha::Database->new->schema;  ## For some reason the SIP2-server modules use a different instance of $dbh than the one that sets up the transaction here. Thus the tests fail if transactions are enabled.
#$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new();
my $blockedBorrower = $builder->build({ source => 'Borrower', value => {
    branchcode => 'CPL',
    password   => Koha::AuthUtils::hash_password('1234'),
} });
my $terminal = $builder->build({ source => 'Borrower', value => {
    branchcode => 'FPL',
    password   => Koha::AuthUtils::hash_password('termPw'),
} });


C4::Context->_new_userenv('DUMMY SESSION');
ok(my $userenv = C4::Context->set_userenv($terminal->{borrowernumber},$terminal->{userid},'SSAPIUser','firstname','surname', 'FPL', 'FPL', 0, '', ''),
    "Given a logged in librarian");

$C4::SIP::Sip::protocol_version = 2; #Overload the protocol version, which is normally inferred from v2-type login
my $server = {
    config      => {
        delimiter  => "|",
    },
    institution => {
        id => $terminal->{branchcode},
    },
    account     => {
        id          => $terminal->{userid},
        password    => 'termPw',
        institution => $terminal->{branchcode},
        terminator  => "CR",
        encoding    => 'utf8',
    },
};
ok($server->{ils} = C4::SIP::ILS->new( $server->{institution}, $server->{account} ),
    "And a SIP2-server");

subtest("63/64 without a self-service branch-specific block", sub {
    plan tests => 3;

    ok(my ($status, $stdout) = do63_64('CPL', $blockedBorrower->{userid}, 'termPw', '1234'),
        "When a 63-message is sent");

    is($status, 63,
        "Then the status matches");

    like($stdout, qr/64.+\|PA1\|/,
        "And the printed message explicitly has no self-service branch-specific block");
});

subtest("63/64 not blocked due to the Sip2-device being in a different branch", sub {
    plan tests => 4;

    ok(C4::SelfService::BlockManager::storeBlock( C4::SelfService::BlockManager::createBlock({
        borrowernumber => $blockedBorrower->{borrowernumber},
        branchcode     => 'CPL',
    })),
        "Given a self-service block to a branch where the device is not logged in");

    ok(my ($status, $stdout) = do63_64('CPL', $blockedBorrower->{userid}, 'termPw', '1234'),
        "When a 63-message is sent");

    is($status, 63,
        "Then the status matches");

    like($stdout, qr/64.+\|PA1\|/,
        "And the printed message explicitly has no self-service branch-specific block");
});

subtest("63/64 access type blocked", sub {
    plan tests => 4;

    ok(C4::SelfService::BlockManager::storeBlock( C4::SelfService::BlockManager::createBlock({
        borrowernumber => $blockedBorrower->{borrowernumber},
        branchcode     => 'FPL',
    })),
        "Given a self-service block to the branch where the device is at");

    ok(my ($status, $stdout) = do63_64('FPL', $blockedBorrower->{userid}, 'termPw', '1234'),
        "When a 63-message is sent");

    is($status, 63,
        "Then the status matches");

    like($stdout, qr/64.+\|PA0\|/,
        "And the access type field 'PA' says no access '0'");
});



done_testing();



sub do63_64 {
    my ($institutionId, $patronId, $termPw, $patronPw) = @_;
    my $stdout = '';
    open(my $CAPTURE_STDOUT, '>', \$stdout) or die("Couldn't open FH to a variable: $!");
    select($CAPTURE_STDOUT) or die("Couldn't select a new default print handle: $!");
    my $status = C4::SIP::Sip::MsgType::handle( "6300020060329    201700Y         AO$institutionId|AA$patronId|AC$termPw|AD$patronPw|", $server, q{} );
    select(STDOUT) or die("Couldn't re-select STDOUT: $!");
    close($CAPTURE_STDOUT) or die("Couldn't close \$CAPTURE_OUTPUT: $!");
    return ($status, $stdout);
}

#$schema->storage->txn_rollback;
