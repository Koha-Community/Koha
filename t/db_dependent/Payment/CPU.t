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
use Try::Tiny;

use Koha::Auth::PermissionManager;
use Koha::Payment::Online;
use Koha::PaymentsTransaction;
use Koha::PaymentsTransactions;

use t::lib::Page::Opac::OpacMain;
use t::lib::Page::Opac::OpacAccount;
use t::lib::Page::Opac::OpacPaycollect;

use t::lib::TestObjects::PatronFactory;
use t::lib::TestObjects::SystemPreferenceFactory;
use t::lib::TestObjects::FinesFactory;
use t::lib::TestObjects::ItemFactory;

##Setting up the test context
my $testContext = {};

my $password = '1234';
my $item_product_code = 'demo_002';
my $other_product_code = 'demo_001';
my $borrower_home_branch = 'CPL';
my $item_home_branch = 'TPL';

# This test requires you to run simulator server
# See misc/cpu_server_simulator.pl

# Remember to configure $KOHA_CONF with appropriate configurations
# provided in etc/koha-conf.xml at "online_payments"
unless (C4::Context->config('online_payments')->{CPU}) {
    ok(0, 'Please configure $KOHA_CONF first.'
       .' See etc/koha-conf.xml for online_payments');
}

my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
my $borrowers = $borrowerFactory->createTestGroup([
            {firstname  => 'Testthree',
             surname    => 'Testfour',
             cardnumber => 'superuberadmin',
             branchcode => $borrower_home_branch,
             userid     => 'god',
             address    => 'testi',
             city       => 'joensuu',
             zipcode    => '80100',
             password   => $password,
            },
        ], undef, $testContext);

my $systempreferences = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
            {preference => 'OnlinePayments',
             value      => '
             '.$item_home_branch.':
               OnlinePaymentsInterface: CPU
               Default: '.$item_product_code.'
             Default:
               OnlinePaymentsInterface: CPU
               Default: '.$other_product_code.'
             ',
            },
            {
                preference  => 'OnlinePaymentMinTotal',
                value       => '5.00',
            }
        ], undef, $testContext);
my $biblios = t::lib::TestObjects::BiblioFactory->createTestGroup([
                        {'biblio.title' => 'I wish I met your mother',
                         'biblio.author'   => 'Pertti Kurikka',
                         'biblio.copyrightdate' => '1960',
                         'biblioitems.isbn'     => '9519671580',
                         'biblioitems.itemtype' => 'BK',
                        },
                    ], 'biblioitems.isbn', undef, undef, $testContext);
my $items = t::lib::TestObjects::ItemFactory->createTestGroup([
    {
        biblionumber => $biblios->{9519671580}->{biblionumber},
        barcode => '167Nabe0001',
        homebranch => $item_home_branch,
        holdingbranch => $borrower_home_branch,
        price     => '0.50',
        replacementprice => '0.50',
        itype => 'BK',
        biblioisbn => '9519671580',
        itemcallnumber => 'PK 84.2',
    }
], 'barcode', undef, undef, $testContext);
my $fines = t::lib::TestObjects::FinesFactory->createTestGroup([
    {
        note => "First",
        description => "First",
        cardnumber => $borrowers->{'superuberadmin'}->cardnumber,
        amount => int(rand(9)+1) . "" . int(rand(10)) . "." . int(rand(10)) . "" . int(rand(10)),
        itemnumber => $items->{'167Nabe0001'}->itemnumber,
    },
    {
        note => "Second",
        description => "Second",
        cardnumber => $borrowers->{'superuberadmin'}->cardnumber,
        amount => int(rand(9)+1) . "" . int(rand(10)) . "." . int(rand(10)) . "" . int(rand(10))
    },
], undef, $testContext);

my $permissionManager = Koha::Auth::PermissionManager->new();
$permissionManager->grantPermissions($borrowers->{'superuberadmin'}, {superlibrarian => 'superlibrarian'});
eval {
    MakeOnlinePayment($fines);
    IsCorrectProductCodes();
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
}



sub MakeOnlinePayment {
    my ($fines) = @_;
    # Make random amount for payments
    my $firstAmount = $fines->{"First"}->{amount};
    my $secondAmount = $fines->{"Second"}->{amount};

    my $opacaccount = t::lib::Page::Opac::OpacMain->new({borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber});

    $opacaccount = $opacaccount->doPasswordLogin($borrowers->{'superuberadmin'}->userid(), $password)
    ->navigateYourFines()
    ->findFine("First")     # find the two fines created...
    ->findFine("Second")    # ...by FinesFactory
    ->isFineAmountOutstanding("First", $firstAmount)
    ->isFineAmountOutstanding("Second", $secondAmount)
    ->PayFines()
    ->isPreparing()
    ->isPaymentPaid()
    ->navigateYourFines()
    ->isFineAmount("First", $firstAmount)
    ->isFineAmount("Second", $secondAmount)
    ->isFinePaid("First")       # Make sure fines are paid
    ->isFinePaid("Second")     # Also the second :)
    ->isEverythingPaid();      # and make sure total due is 0.00
}

sub IsCorrectProductCodes {
    my $transaction = Koha::PaymentsTransactions->search({
        borrowernumber => $borrowers->{'superuberadmin'}->borrowernumber
    })->next();
    my $payment = Koha::Payment::Online->new({ branch => C4::Context::mybranch() });

    my $products = $payment->get_prepared_products(
                                    $transaction->GetProducts(),
                                    $borrowers->{'superuberadmin'}->branchcode);
    foreach my $product (@$products){
        if ($product->{'Description'} eq ($fines->{"First"}->{description}." ".$items->{'167Nabe0001'}->itemnumber)){
            is($product->{'Code'}, $item_product_code, "Product code (".$item_product_code.") has been fetched from item's home library product code mapping");
        } else {
            is($product->{'Code'}, $other_product_code, "Product code (".$other_product_code.") has been fetched from user's home branch product code mapping");
        }
    }
}
