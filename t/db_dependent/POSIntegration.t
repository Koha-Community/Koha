#!/usr/bin/env perl

# Copyright 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
#$ENV{KOHA_PAGEOBJECT_DEBUG} = 1;
use Modern::Perl;

use Test::More;
use Try::Tiny; #Even Selenium::Remote::Driver uses Try::Tiny :)

use Koha::Database;
use Koha::Auth::PermissionManager;
use Koha::PaymentsTransaction;
use Koha::PaymentsTransactions;

use t::lib::Page::Mainpage;
use t::lib::Page::Members::Boraccount;
use t::lib::Page::Members::Pay;
use t::lib::Page::Members::Paycollect;

use t::lib::TestObjects::PatronFactory;
use t::lib::TestObjects::SystemPreferenceFactory;
use t::lib::TestObjects::FinesFactory;

#### THIS TEST REQUIRES A CPU SIMULATOR SERVER
#### and proper KOHA_CONF configurations
#### KOHA_CONF -> pos -> CPU -> url http://127.0.0.1:3000/maksu.html
like(
   C4::Context->config('pos')->{'CPU'}->{'url'},
    qr/^.*\/maksu.html$/,
    'Payment test server configured'
);
my $intradir = C4::Context->config('intranetdir');
my $url = C4::Context->config('pos')->{'CPU'}->{'url'};
my ($port) = $url =~ m/:(\d+)\//;
eval {
    unless (`pgrep -f misc/cpu_server_simulator.pl`) {
        system("/usr/bin/perl $intradir/misc/cpu_server_simulator.pl daemon -l http://*:$port &");
    }
};

##Setting up the test context
my $testContext = {};

my $password = '1234';
my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
my $borrowers = $borrowerFactory->createTestGroup([
            {firstname  => 'Testthree',
             surname    => 'Testfour',
             cardnumber => 'superuberadmin',
             branchcode => 'MPL',
             userid     => 'god',
             address    => 'testi',
             city       => 'joensuu',
             zipcode    => '80100',
             password   => $password,
            },
            {firstname  => 'Iral',
             surname    => 'Aluksat',
             cardnumber => 'superuberadmin2',
             branchcode => 'CPL',
             userid     => 'god2',
             address    => 'testi',
             city       => 'joensuu',
             zipcode    => '80100',
             password   => $password,
            },
        ], undef, $testContext);

my $systempreferences = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
            {preference => 'POSIntegration',
             value      => 'Default:
  POSInterface: CPU
  Default: demo_001',
            },
        ], undef, $testContext);

my $fines = t::lib::TestObjects::FinesFactory->createTestGroup([
    {
        note => "First",
        cardnumber => $borrowers->{'superuberadmin'}->cardnumber,
        amount => int(rand(9)+1) . "" . int(rand(10)) . "." . int(rand(10)) . "" . int(rand(10))
    },
    {
        note => "Second",
        cardnumber => $borrowers->{'superuberadmin'}->cardnumber,
        amount => int(rand(9)+1) . "" . int(rand(10)) . "." . int(rand(10)) . "" . int(rand(10))
    },
    {
        note => "First2",
        cardnumber => $borrowers->{'superuberadmin2'}->cardnumber,
        amount => int(rand(9)+1) . "" . int(rand(10)) . "." . int(rand(10)) . "" . int(rand(10))
    },
    {
        note => "Second2",
        cardnumber => $borrowers->{'superuberadmin2'}->cardnumber,
        amount => int(rand(9)+1) . "" . int(rand(10)) . "." . int(rand(10)) . "" . int(rand(10))
    },
], undef, $testContext);

my $permissionManager = Koha::Auth::PermissionManager->new();
$permissionManager->grantPermissions($borrowers->{'superuberadmin'}, {superlibrarian => 'superlibrarian'});
$permissionManager->grantPermissions($borrowers->{'superuberadmin2'}, {superlibrarian => 'superlibrarian'});
eval {
    MakeFullPayment($fines);
    MakePartialPayment($fines);
    CheckStatistics();
};
if ($@) { #Catch all leaking errors and gracefully terminate.
    warn $@;
    tearDown();
    exit 1;
}

##All tests done, tear down test context
tearDown();
done_testing;

sub tearDown {
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
    eval {
        if (`pgrep -f misc/cpu_server_simulator.pl`) {
            system("pkill -f misc/cpu_server_simulator.pl");
        }
    };
}



sub MakeFullPayment {
    my ($fines) = @_;
    # Make random amount for payments
    my $firstAmount = $fines->{"First"}->{amount};
    my $secondAmount = $fines->{"Second"}->{amount};

    # staff client
    my $boraccount = t::lib::Page::Members::Boraccount->new({borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber, op => 'modify', destination => 'circ', categorycode => 'PT'});

    $boraccount = $boraccount->doPasswordLogin($borrowers->{'superuberadmin2'}->userid(), $password)
    ->findFine("First")     # find the two fines created...
    ->findFine("Second")    # ...by FinesFactory
    ->isFineAmountOutstanding("First", $firstAmount)
    ->isFineAmountOutstanding("Second", $secondAmount)
    ->navigateToPayFinesTab()
    ->PaySelected()
    ->addNoteToSelected("Transaction that pays everything ;)")
    ->openAddNewCashRegister()
    ->addNewCashRegister(100) # add cash register number 100
    ->selectCashRegister(100) # and select it
    ->sendPaymentToPOS()
    ->paymentLoadingScreen()
    ->waitUntilPaymentIsAcceptedAtPOS();

    # Get transaction ids
    my $transactions = Koha::PaymentsTransactions->find({ borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber });

    # Check that there is a transaction completed
    foreach my $transaction ($transactions){
        $boraccount = $boraccount->isTransactionComplete($transaction->transaction_id);
        $boraccount
        ->isFinePaid("Transaction that pays everything ;)") # note of transaction
        ->isFineAmount("Transaction that pays everything ;)", "-".sprintf("%.2f",$firstAmount+$secondAmount));
        is($transaction->manager_id, $borrowers->{'superuberadmin2'}->borrowernumber, 'Correct manager id');
    }
    $boraccount
    ->isFineAmount("First", $firstAmount)
    ->isFineAmount("Second", $secondAmount)
    ->isFinePaid("First")       # Make sure fines are paid
    ->isFinePaid("Second");     # Also the second :)
}

sub MakePartialPayment {
    my ($fines) = @_;
    # Make random amount for payments
    my $firstAmount = $fines->{"First2"}->{amount};
    my $secondAmount = $fines->{"Second2"}->{amount};

    my $partialPayment = $firstAmount-(int(rand(9)+1) . "." . int(rand(10)) . "" . int(rand(10)));
    # staff client
    my $boraccount = t::lib::Page::Members::Boraccount->new({borrowernumber => $borrowers->{'superuberadmin2'}->borrowernumber, op => 'modify', destination => 'circ', categorycode => 'PT'});

    $boraccount = $boraccount->doPasswordLogin($borrowers->{'superuberadmin'}->userid(), $password)
    ->findFine("First2")     # find the two fines created...
    ->findFine("Second2")    # ...by FinesFactory
    ->isFineAmountOutstanding("First2", $firstAmount)
    ->isFineAmountOutstanding("Second2", $secondAmount)
    ->navigateToPayFinesTab()
    ->PaySelected()
    ->setAmount($partialPayment)
    ->addNoteToSelected("Transaction that pays everything ;)2")
    ->openAddNewCashRegister()
    ->addNewCashRegister(100) # add cash register number 100
    ->selectCashRegister(100) # and select it
    ->sendPaymentToPOS()
    ->paymentLoadingScreen()
    ->waitUntilPaymentIsAcceptedAtPOS();

    # Get transaction ids
    my $transactions = Koha::PaymentsTransactions->find({ borrowernumber => $borrowers->{'superuberadmin2'}->borrowernumber });

    # Check that there is a transaction completed
    foreach my $transaction ($transactions){
        $boraccount = $boraccount->isTransactionComplete($transaction->transaction_id);
        $boraccount
        ->isFinePaid("Transaction that pays everything ;)2") # note of transaction
        ->isFineAmount("Transaction that pays everything ;)2", "-".(sprintf("%.2f",$partialPayment)));
        is($transaction->manager_id, $borrowers->{'superuberadmin'}->borrowernumber, 'Correct manager id');
    }
    $boraccount
    ->isFineAmount("First2", $firstAmount)
    ->isFineAmount("Second2", $secondAmount)
    ->isFineAmountOutstanding("First2", sprintf("%.2f",$firstAmount-$partialPayment))
    ->isFineAmountOutstanding("Second2", $secondAmount);
}

sub CheckStatistics {
    my $schema = Koha::Database->schema;

    my $count = $schema->resultset('Statistic')->search({
        branch     => 'CPL',
        type       => 'payment',
        borrowernumber => { '-in' => [
            $borrowers->{'superuberadmin'}->borrowernumber,
            $borrowers->{'superuberadmin2'}->borrowernumber,
            ]
        }
    }, { order_by => { -asc => 'datetime' } })->count;
    is($count, 2, 'Found two payments in statistics table');
}
