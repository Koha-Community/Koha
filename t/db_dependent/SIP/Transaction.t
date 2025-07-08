#!/usr/bin/perl

# Tests for SIP::ILS::Transaction
# Current state is very rudimentary. Please help to extend it!

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 21;
use Test::Warn;

use DateTime;

use Koha::Database;
use t::lib::TestBuilder;
use t::lib::Mocks;
use C4::SIP::ILS;
use C4::SIP::ILS::Patron;
use C4::SIP::ILS::Transaction::RenewAll;
use C4::SIP::ILS::Transaction::Checkout;
use C4::SIP::ILS::Transaction::FeePayment;
use C4::SIP::ILS::Transaction::Hold;
use C4::SIP::ILS::Transaction::Checkout;
use C4::SIP::ILS::Transaction::Checkin;

use C4::Reserves qw( AddReserve ModReserve ModReserveAffect RevertWaitingStatus );
use Koha::CirculationRules;
use Koha::Item::Transfer;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Recalls;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder    = t::lib::TestBuilder->new();
my $borr1      = $builder->build( { source => 'Borrower' } );
my $card       = $borr1->{cardnumber};
my $sip_patron = C4::SIP::ILS::Patron->new($card);

# Create transaction RenewAll, assign patron, and run (no items)
my $transaction = C4::SIP::ILS::Transaction::RenewAll->new();
is( ref $transaction,                  "C4::SIP::ILS::Transaction::RenewAll", "New transaction created" );
is( $transaction->patron($sip_patron), $sip_patron,                           "Patron assigned to transaction" );
isnt( $transaction->do_renew_all, undef, "RenewAll on zero items" );

subtest fill_holds_at_checkout => sub {
    plan tests => 6;

    my $category = $builder->build( { source => 'Category', value => { category_type => 'A' } } );
    my $branch   = $builder->build( { source => 'Branch' } );
    my $borrower = $builder->build(
        {
            source => 'Borrower',
            value  => {
                branchcode   => $branch->{branchcode},
                categorycode => $category->{categorycode}
            }
        }
    );
    t::lib::Mocks::mock_userenv( { branchcode => $branch->{branchcode}, flags => 1 } );

    my $itype = $builder->build( { source => 'Itemtype', value => { notforloan => 0 } } );
    my $item1 = $builder->build_sample_item(
        {
            barcode       => 'barcode4test',
            homebranch    => $branch->{branchcode},
            holdingbranch => $branch->{branchcode},
            itype         => $itype->{itemtype},
            notforloan    => 0,
        }
    )->unblessed;
    my $item2 = $builder->build_sample_item(
        {
            homebranch    => $branch->{branchcode},
            holdingbranch => $branch->{branchcode},
            biblionumber  => $item1->{biblionumber},
            itype         => $itype->{itemtype},
            notforloan    => 0,
        }
    )->unblessed;

    Koha::CirculationRules->set_rules(
        {
            categorycode => $borrower->{categorycode},
            branchcode   => $branch->{branchcode},
            itemtype     => $itype->{itemtype},
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
            }
        }
    );

    my $reserve1 = AddReserve(
        {
            branchcode     => $branch->{branchcode},
            borrowernumber => $borrower->{borrowernumber},
            biblionumber   => $item1->{biblionumber}
        }
    );
    my $reserve2 = AddReserve(
        {
            branchcode     => $branch->{branchcode},
            borrowernumber => $borrower->{borrowernumber},
            biblionumber   => $item1->{biblionumber}
        }
    );

    my $bib = Koha::Biblios->find( $item1->{biblionumber} );
    is( $bib->holds->count(), 2, "Bib has 2 holds" );

    my $sip_patron  = C4::SIP::ILS::Patron->new( $borrower->{cardnumber} );
    my $sip_item    = C4::SIP::ILS::Item->new( $item1->{barcode} );
    my $transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is( ref $transaction,                  "C4::SIP::ILS::Transaction::Checkout", "New transaction created" );
    is( $transaction->patron($sip_patron), $sip_patron,                           "Patron assigned to transaction" );
    is( $transaction->item($sip_item),     $sip_item,                             "Item assigned to transaction" );
    my $checkout = $transaction->do_checkout();
    use Data::Dumper;    # Temporary debug statement
    is( $bib->holds->count(), 1, "Bib has 1 holds remaining" ) or diag Dumper $checkout;

    t::lib::Mocks::mock_preference( 'itemBarcodeInputFilter', 'whitespace' );
    $sip_item    = C4::SIP::ILS::Item->new(' barcode 4 test ');
    $transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is( $sip_item->{barcode}, $item1->{barcode}, "Item assigned to transaction" );
};

subtest "FeePayment->pay tests" => sub {

    plan tests => 5;

    # Create a borrower and add some outstanding debts to their account
    my $patron = $builder->build( { source => 'Borrower' } );
    my $account =
        Koha::Account->new( { patron_id => $patron->{borrowernumber} } );
    my $debt1 = $account->add_debit( { type => 'ACCOUNT', amount => 100, interface => 'commandline' } );
    my $debt2 = $account->add_debit( { type => 'ACCOUNT', amount => 200, interface => 'commandline' } );

    # Instantiate a new FeePayment transaction object
    my $trans = C4::SIP::ILS::Transaction::FeePayment->new();
    is(
        ref $trans,
        "C4::SIP::ILS::Transaction::FeePayment",
        "New fee transaction created"
    );

    # Test the 'pay' method
    # FIXME: pay should not require a borrowernumber
    # (we should reach out to the transaction which should contain a patron object)
    my $pay_type = '00';          # 00 - Cash, 01 - VISA, 02 - Creditcard
    my $ok       = $trans->pay(
        $patron->{borrowernumber}, 100, $pay_type, $debt1->id, 0,
        0
    );
    ok( $ok, "FeePayment transaction succeeded" );
    $debt1->discard_changes;
    is(
        $debt1->amountoutstanding + 0, 0,
        "Debt1 was reduced to 0 as expected"
    );
    my $offsets = Koha::Account::Offsets->search( { debit_id => $debt1->id, credit_id => { '!=' => undef } } );
    is( $offsets->count, 1, "FeePayment produced an offset line correctly" );
    my $credit = $offsets->next->credit;
    is( $credit->payment_type, 'SIP00', "Payment type was set correctly" );
};

subtest cancel_hold => sub {
    plan tests => 7;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            branchcode   => $library->branchcode,
            itemtype     => $item->effective_itemtype,
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
            }
        }
    );

    my $reserve1 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblio->biblionumber,
            itemnumber     => $item->itemnumber,
        }
    );
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib" );
    is( $item->holds->count(),         1, "Hold was placed on specific item" );

    my $sip_patron  = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item    = C4::SIP::ILS::Item->new( $item->barcode );
    my $transaction = C4::SIP::ILS::Transaction::Hold->new();
    is( ref $transaction,                  "C4::SIP::ILS::Transaction::Hold", "New transaction created" );
    is( $transaction->patron($sip_patron), $sip_patron,                       "Patron assigned to transaction" );
    is( $transaction->item($sip_item),     $sip_item,                         "Item assigned to transaction" );
    my $hold = $transaction->drop_hold();
    is( $item->biblio->holds->count(), 0, "Bib has 0 holds remaining" );
    is( $item->holds->count(),         0, "Item has 0 holds remaining" );
};

subtest cancel_waiting_hold => sub {
    plan tests => 14;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );
    t::lib::Mocks::mock_preference( 'HoldCancellationRequestSIP', 0 );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            branchcode   => $library->branchcode,
            itemtype     => $item->effective_itemtype,
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
            }
        }
    );

    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblio->biblionumber,
            itemnumber     => $item->itemnumber,
        }
    );
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib" );
    is( $item->holds->count(),         1, "Hold was placed on specific item" );

    my $sip_patron  = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item    = C4::SIP::ILS::Item->new( $item->barcode );
    my $transaction = C4::SIP::ILS::Transaction::Hold->new();
    is( ref $transaction,                  "C4::SIP::ILS::Transaction::Hold", "New transaction created" );
    is( $transaction->patron($sip_patron), $sip_patron,                       "Patron assigned to transaction" );
    is( $transaction->item($sip_item),     $sip_item,                         "Item assigned to transaction" );
    my $hold = $transaction->drop_hold();
    is( $item->biblio->holds->count(), 0, "Bib has 0 holds remaining" );
    is( $item->holds->count(),         0, "Item has 0 holds remaining" );

    t::lib::Mocks::mock_preference( 'HoldCancellationRequestSIP', 1 );

    $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblio->biblionumber,
            itemnumber     => $item->itemnumber,
        }
    );

    $hold = Koha::Holds->find($reserve_id);
    ok( $hold, 'Get hold object' );
    $hold->update( { found => 'W' } );
    $hold->get_from_storage;

    is( $hold->found, 'W', "Hold was correctly set to waiting." );

    $transaction = C4::SIP::ILS::Transaction::Hold->new();
    is( ref $transaction,                  "C4::SIP::ILS::Transaction::Hold", "New transaction created" );
    is( $transaction->patron($sip_patron), $sip_patron,                       "Patron assigned to transaction" );
    is( $transaction->item($sip_item),     $sip_item,                         "Item assigned to transaction" );
    $hold = $transaction->drop_hold();
    is( $item->biblio->holds->count(), 1, "Bib has 1 holds remaining" );
    is( $item->holds->count(),         1, "Item has 1 holds remaining" );
};

subtest do_hold => sub {
    plan tests => 8;

    my $library = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => { pickup_location => 1 }
        }
    );
    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_1->categorycode,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $reserve1 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron_1->borrowernumber,
            biblionumber   => $item->biblio->biblionumber,
            itemnumber     => $item->itemnumber,
        }
    );
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib" );
    is( $item->holds->count(),         1, "Hold was placed on specific item" );

    my $sip_patron  = C4::SIP::ILS::Patron->new( $patron_2->cardnumber );
    my $sip_item    = C4::SIP::ILS::Item->new( $item->barcode );
    my $transaction = C4::SIP::ILS::Transaction::Hold->new();
    is(
        ref $transaction,
        "C4::SIP::ILS::Transaction::Hold",
        "New transaction created"
    );
    is(
        $transaction->patron($sip_patron),
        $sip_patron, "Patron assigned to transaction"
    );
    is(
        $transaction->item($sip_item),
        $sip_item, "Item assigned to transaction"
    );
    my $hold = $transaction->do_hold();
    is( $item->biblio->holds->count(), 2, "Bib has 2 holds" );

    my $THE_hold = $patron_2->holds->next;
    is( $THE_hold->priority,   2,                     'Hold placed from SIP should have a correct priority of 2' );
    is( $THE_hold->branchcode, $patron_2->branchcode, 'Hold placed from SIP should have the branchcode set' );
};

subtest "Placing holds via SIP check CanItemBeReserved" => sub {
    plan tests => 4;

    my $library = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => { pickup_location => 0 }
        }
    );
    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    my $patron_2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_1->categorycode,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $sip_patron  = C4::SIP::ILS::Patron->new( $patron_2->cardnumber );
    my $sip_item    = C4::SIP::ILS::Item->new( $item->barcode );
    my $transaction = C4::SIP::ILS::Transaction::Hold->new();
    is(
        ref $transaction,
        "C4::SIP::ILS::Transaction::Hold",
        "New transaction created"
    );
    is(
        $transaction->patron($sip_patron),
        $sip_patron, "Patron assigned to transaction"
    );
    is(
        $transaction->item($sip_item),
        $sip_item, "Item assigned to transaction"
    );
    my $hold = $transaction->do_hold();

    is( $transaction->ok, 0, "Hold was not allowed" );
};

subtest do_checkin => sub {
    plan tests => 14;

    my $mockILS  = Test::MockObject->new;
    my $server   = { ils => $mockILS };
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron   = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    # Checkout
    my $sip_patron     = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item       = C4::SIP::ILS::Item->new( $item->barcode );
    my $co_transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is(
        $co_transaction->patron($sip_patron),
        $sip_patron, "Patron assigned to transaction"
    );
    is(
        $co_transaction->item($sip_item),
        $sip_item, "Item assigned to transaction"
    );
    my $checkout = $co_transaction->do_checkout();
    is( $patron->checkouts->count, 1, 'Checkout should have been done successfully' );

    # Checkin
    my $ci_transaction = C4::SIP::ILS::Transaction::Checkin->new();
    is(
        $ci_transaction->patron($sip_patron),
        $sip_patron, "Patron assigned to transaction"
    );
    is(
        $ci_transaction->item($sip_item),
        $sip_item, "Item assigned to transaction"
    );

    my $checkin = $ci_transaction->do_checkin( $library->branchcode, C4::SIP::Sip::timestamp );
    is( $patron->checkouts->count, 0, 'Checkin should have been done successfully' );

    # Test checkin without return date
    $co_transaction->do_checkout;
    is( $patron->checkouts->count, 1, 'Checkout should have been done successfully' );
    $ci_transaction->do_checkin( $library->branchcode, undef );
    is( $patron->checkouts->count, 0, 'Checkin should have been done successfully' );

    my $result   = $ci_transaction->do_checkin( $library2->branchcode, undef );
    my $transfer = $item->get_transfer;
    is( $ci_transaction->alert_type, '04', "Checkin of item no issued at another branch succeeds" );
    is_deeply(
        $result,
        {
            messages => {
                'NotIssued'       => $item->barcode,
                'WasTransfered'   => $transfer->branchtransfer_id,
                'TransferTo'      => $library->branchcode,
                'TransferTrigger' => 'ReturnToHome'
            }
        },
        "Messages show not issued and transferred"
    );
    is( $ci_transaction->item->destination_loc, $library->branchcode, "Item destination correctly set" );

    subtest 'Checkin an in transit item' => sub {

        plan tests => 5;

        my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );

        my $patron =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_1->branchcode, } } );
        my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
        my $item       = $builder->build_sample_item( { library => $library_1->branchcode } );
        my $sip_item   = C4::SIP::ILS::Item->new( $item->barcode );

        t::lib::Mocks::mock_userenv( { branchcode => $library_1->branchcode, flags => 1 } );

        my $reserve = AddReserve(
            {
                branchcode     => $library_1->branchcode,
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber,
            }
        );

        ModReserveAffect( $item->itemnumber, $patron->borrowernumber );    # Mark waiting

        my $ci_transaction = C4::SIP::ILS::Transaction::Checkin->new();
        is(
            $ci_transaction->patron($sip_patron),
            $sip_patron, "Patron assigned to transaction"
        );
        is(
            $ci_transaction->item($sip_item),
            $sip_item, "Item assigned to transaction"
        );

        my $checkin = $ci_transaction->do_checkin( $library_2->branchcode, C4::SIP::Sip::timestamp );

        my $hold = Koha::Holds->find($reserve);
        is( $hold->found,                                                          'T', );
        is( $hold->itemnumber,                                                     $item->itemnumber, );
        is( Koha::Checkouts->search( { itemnumber => $item->itemnumber } )->count, 0, );
    };

    subtest 'Checkin message' => sub {
        plan tests => 3;
        my $mockILS    = Test::MockObject->new;
        my $server     = { ils => $mockILS };
        my $library    = $builder->build_object( { class => 'Koha::Libraries' } );
        my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
        my $homebranch = $builder->build(
            {
                source => 'Branch',
                value  => {
                    branchcode => 'HMBR',
                    branchname => 'Homebranch'
                }
            }
        );

        my $institution = {
            id             => $library->id,
            implementation => "ILS",
            policy         => {
                checkin  => "true",
                renewal  => "true",
                checkout => "true",
                timeout  => 100,
                retries  => 5,
            }
        };
        my $ils  = C4::SIP::ILS->new($institution);
        my $item = $builder->build_sample_item(
            {
                library            => $library->branchcode,
                homebranch         => $homebranch->{'branchcode'},
                location           => 'My Location',
                permanent_location => 'My Permanent Location',
            }
        );
        my $circ = $ils->checkout( $patron->cardnumber, $item->barcode, undef, undef, $server->{account} );
        $circ = $ils->checkin(
            $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode, undef, undef,
            $server->{account}
        );
        is( $circ->{screen_msg}, '', "Checkin message is not displayed when show_checkin_message is disabled" );

        $server->{account}->{show_checkin_message} = 1;

        $circ = $ils->checkout( $patron->cardnumber, $item->barcode, undef, undef, $server->{account} );
        $circ = $ils->checkin(
            $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode, undef, undef,
            $server->{account}
        );
        is(
            $circ->{screen_msg}, 'Item checked-in: Homebranch - My Location.',
            "Checkin message when show_checkin_message is enabled and UseLocationAsAQInSIP is disabled"
        );

        t::lib::Mocks::mock_preference( 'UseLocationAsAQInSIP', '1' );

        $circ = $ils->checkout( $patron->cardnumber, $item->barcode, undef, undef, $server->{account} );
        $circ = $ils->checkin(
            $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode, undef, undef,
            $server->{account}
        );
        is(
            $circ->{screen_msg}, 'Item checked-in: My Permanent Location - My Location.',
            "Checkin message when both show_checkin_message and UseLocationAsAQInSIP are enabled"
        );

    };

    subtest 'Checkin with fines' => sub {
        plan tests => 2;

        my $mockILS     = Test::MockObject->new;
        my $server      = { ils => $mockILS };
        my $library     = $builder->build_object( { class => 'Koha::Libraries' } );
        my $institution = {
            id             => $library->id,
            implementation => "ILS",
            policy         => {
                checkin  => "true",
                renewal  => "true",
                checkout => "true",
                timeout  => 100,
                retries  => 5,
            }
        };
        my $ils  = C4::SIP::ILS->new($institution);
        my $item = $builder->build_sample_item(
            {
                library => $library->branchcode,
            }
        );

        # show_outstanding_amount disabled
        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    branchcode => $library->branchcode,
                }
            }
        );
        my $circ = $ils->checkout( $patron->cardnumber, $item->barcode, undef, undef, $server->{account} );
        my $fee1 = $builder->build(
            {
                source => 'Accountline',
                value  => {
                    borrowernumber    => $patron->borrowernumber,
                    amountoutstanding => 12,
                    debit_type_code   => 'OVERDUE',
                    itemnumber        => $item->itemnumber
                }
            }
        );
        $circ = $ils->checkin(
            $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode, undef, undef,
            $server->{account}
        );
        is( $circ->{screen_msg}, '', "The fine is not displayed on checkin when show_outstanding_amount is disabled" );

        # show_outstanding_amount enabled
        $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    branchcode => $library->branchcode,
                }
            }
        );
        $circ = $ils->checkout( $patron->cardnumber, $item->barcode, undef, undef, $server->{account} );

        $fee1 = $builder->build(
            {
                source => 'Accountline',
                value  => {
                    borrowernumber    => $patron->borrowernumber,
                    amountoutstanding => 12,
                    debit_type_code   => 'OVERDUE',
                    itemnumber        => $item->itemnumber
                }
            }
        );

        $server->{account}->{show_outstanding_amount} = 1;
        $circ = $ils->checkout( $patron->cardnumber, $item->barcode, undef, undef, $server->{account} );

        $circ = $ils->checkin(
            $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode, undef, undef,
            $server->{account}
        );
        is(
            $circ->{screen_msg}, 'You owe $12.00 for this item.',
            "The fine is displayed on checkin when show_outstanding_amount is enabled"
        );

    };
};

subtest do_checkout_with_sysprefs_override => sub {
    plan tests => 8;

    my $mockILS     = Test::MockObject->new;
    my $server      = { ils => $mockILS };
    my $library     = $builder->build_object( { class => 'Koha::Libraries' } );
    my $institution = {
        id             => $library->id,
        implementation => "ILS",
        policy         => {
            checkin  => "true",
            renewal  => "true",
            checkout => "true",
            timeout  => 100,
            retries  => 5,
        }
    };
    my $ils  = C4::SIP::ILS->new($institution);
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $patron_category = $builder->build(
        {
            source => 'Category',
            value  => {
                categorycode   => 'NOT_X', category_type => 'P', enrolmentfee => 0, noissueschargeguarantees => 0,
                noissuescharge => 0,       noissueschargeguarantorswithguarantees => 0
            }
        }
    );

    my $patron_under_noissuescharge = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_category->{categorycode},
            }
        }
    );

    my $fee_under_noissuescharge = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $patron_under_noissuescharge->borrowernumber,
                amountoutstanding => 4,
                debit_type_code   => 'OVERDUE',
            }
        }
    );

    my $patron_over_noissuescharge = $builder->build_object(

        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_category->{categorycode},
            }
        }
    );

    my $fee_over_noissuescharge = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $patron_over_noissuescharge->borrowernumber,
                amountoutstanding => 6,
                debit_type_code   => 'OVERDUE',
            }
        }
    );

    $server->{account}->{override_fine_on_checkout} = 0;

    t::lib::Mocks::mock_preference( 'AllFinesNeedOverride', '0' );
    t::lib::Mocks::mock_preference( 'AllowFineOverride',    '0' );
    my $circ =
        $ils->checkout( $patron_under_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_under_noissuescharge->checkouts->count, 1,
        'Checkout is allowed when the amount is under noissuecharge, AllFinesNeedOverride and AllowFineOverride disabled'
    );

    $circ = $ils->checkin( $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode );

    $circ = $ils->checkout( $patron_over_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_over_noissuescharge->checkouts->count, 0,
        'Checkout is blocked when the amount is over noissuecharge, AllFinesNeedOverride and AllowFineOverride disabled'
    );

    t::lib::Mocks::mock_preference( 'AllFinesNeedOverride', '0' );
    t::lib::Mocks::mock_preference( 'AllowFineOverride',    '1' );

    $circ =
        $ils->checkout( $patron_under_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_under_noissuescharge->checkouts->count, 1,
        'Checkout is allowed when the amount is under noissuecharge, AllFinesNeedOverride disabled and AllowFineOverride enabled'
    );

    $circ = $ils->checkin( $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode );

    $circ = $ils->checkout( $patron_over_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_over_noissuescharge->checkouts->count, 0,
        'Checkout is blocked when the amount is over noissuecharge, AllFinesNeedOverride disabled and AllowFineOverride enabled'
    );

    t::lib::Mocks::mock_preference( 'AllFinesNeedOverride', '1' );
    t::lib::Mocks::mock_preference( 'AllowFineOverride',    '0' );

    $circ =
        $ils->checkout( $patron_under_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_under_noissuescharge->checkouts->count, 0,
        'Checkout is blocked when the amount is under noissuecharge, AllFinesNeedOverride enabled and AllowFineOverride disabled'
    );

    $circ = $ils->checkout( $patron_over_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_over_noissuescharge->checkouts->count, 0,
        'Checkout is blocked when the amount is over noissuecharge, AllFinesNeedOverride enabled and AllowFineOverride disabled'
    );

    t::lib::Mocks::mock_preference( 'AllFinesNeedOverride', '1' );
    t::lib::Mocks::mock_preference( 'AllowFineOverride',    '1' );

    $circ =
        $ils->checkout( $patron_under_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_under_noissuescharge->checkouts->count, 0,
        'Checkout is blocked when the amount is under noissuecharge, AllFinesNeedOverride and AllowFineOverride enabled'
    );

    $circ = $ils->checkout( $patron_over_noissuescharge->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $patron_over_noissuescharge->checkouts->count, 0,
        'Checkout is blocked when the amount is over noissuecharge, AllFinesNeedOverride and AllowFineOverride enabled'
    );
};

subtest do_checkout_with_patron_blocked => sub {

    plan tests => 8;

    my $mockILS     = Test::MockObject->new;
    my $server      = { ils => $mockILS };
    my $library     = $builder->build_object( { class => 'Koha::Libraries' } );
    my $institution = {
        id             => $library->id,
        implementation => "ILS",
        policy         => {
            checkin  => "true",
            renewal  => "true",
            checkout => "true",
            timeout  => 100,
            retries  => 5,
        }
    };
    my $ils  = C4::SIP::ILS->new($institution);
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $patron_category = $builder->build(
        {
            source => 'Category',
            value  => {
                categorycode   => 'NOT_X2', category_type => 'P', enrolmentfee => 0, noissueschargeguarantees => 0,
                noissuescharge => 0,        noissueschargeguarantorswithguarantees => 0
            }
        }
    );

    my $date_expiry = DateTime->new( year => 2020, month => 1, day => 3 );

    my $expired_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
                dateexpiry => $date_expiry,
            }
        }
    );

    my $circ;

    foreach my $dateformat (qw{metric us iso dmydot}) {
        t::lib::Mocks::mock_preference( 'dateformat', $dateformat );
        $circ = $ils->checkout( $expired_patron->cardnumber, $item->barcode );
        is(
            $circ->{screen_msg},
            'Patron expired on ' . output_pref( { dt => dt_from_string( $date_expiry, 'iso' ), dateonly => 1 } ),
            "Got correct expired screen message"
        );
    }

    my $fines_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode   => $library->branchcode,
                categorycode => $patron_category->{categorycode},
            }
        }
    );
    my $fee1 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $fines_patron->borrowernumber,
                amountoutstanding => 10,
                debit_type_code   => 'OVERDUE',
            }
        }
    );

    my $fines_sip_patron = C4::SIP::ILS::Patron->new( $fines_patron->cardnumber );

    $circ = $ils->checkout( $fines_patron->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is( $circ->{screen_msg}, 'Patron has fines', "Got correct fines screen message" );

    $server->{account}->{show_outstanding_amount} = 1;
    $circ = $ils->checkout( $fines_patron->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is( $circ->{screen_msg}, 'Patron has fines - You owe $10.00.', "Got correct fines with amount screen message" );
    my $debarred_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
                debarred   => '9999/01/01',
            }
        }
    );
    my $debarred_sip_patron = C4::SIP::ILS::Patron->new( $debarred_patron->cardnumber );
    $circ = $ils->checkout( $debarred_patron->cardnumber, $item->barcode );
    is( $circ->{screen_msg}, 'Patron debarred', "Got correct debarred screen message" );

    my $overdue_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );

    my $odue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $overdue_patron->borrowernumber,
                date_due       => '2017-01-01',
            }
        }
    );
    t::lib::Mocks::mock_preference( 'OverduesBlockCirc', 'block' );
    my $overdue_sip_patron = C4::SIP::ILS::Patron->new( $overdue_patron->cardnumber );
    $circ = $ils->checkout( $overdue_patron->cardnumber, $item->barcode );
    is( $circ->{screen_msg}, 'Patron blocked', "Got correct blocked screen message" );

};

subtest do_checkout_with_noblock => sub {
    plan tests => 3;

    my $mockILS = Test::MockObject->new;
    my $server  = { ils => $mockILS };

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $institution = {
        id             => $library->id,
        implementation => "ILS",
        policy         => {
            checkin  => "true",
            renewal  => "true",
            checkout => "true",
            timeout  => 100,
            retries  => 5,
        }
    };
    my $ils = C4::SIP::ILS->new($institution);

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
                debarred   => '9999/01/01',
            },
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item   = C4::SIP::ILS::Item->new( $item->barcode );

    my $circ = $ils->checkout(
        $patron->cardnumber, $item->barcode, undef, undef,
        $server->{account},  '19990102    030405'
    );

    is(
        $patron->checkouts->count,
        1, 'No Block checkout was performed for debarred patron'
    );

    # Test Bug 32934: SIP checkout with no_block_due_date should honor the specified due date
    $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item_2  = C4::SIP::ILS::Item->new( $item->barcode );
    my $transaction = C4::SIP::ILS::Transaction::Checkout->new();

    $transaction->patron($sip_patron);
    $transaction->item($sip_item_2);

    # Set no_block_due_date to test the fix (YYYYMMDDZZZZHHMMSS)
    my $expected_due_date = '20250115    000000';
    my $checkout_result   = $transaction->do_checkout( undef, $expected_due_date );

    my $checkout_obj = $patron->checkouts->find( { itemnumber => $item->itemnumber } );
    isnt( $checkout_obj, undef, 'Checkout object exists after no block checkout' );
    like(
        dt_from_string( $checkout_obj->date_due )->ymd(''), qr/^20250115/,
        'No block due date is honored in SIP checkout'
    );
};

subtest do_checkout_with_holds => sub {
    plan tests => 7;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    my $patron2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $reserve = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron2->borrowernumber,
            biblionumber   => $item->biblionumber,
        }
    );

    my $sip_patron     = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item       = C4::SIP::ILS::Item->new( $item->barcode );
    my $co_transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is(
        $co_transaction->patron($sip_patron),
        $sip_patron, "Patron assigned to transaction"
    );
    is(
        $co_transaction->item($sip_item),
        $sip_item, "Item assigned to transaction"
    );

    # Test attached holds
    ModReserveAffect( $item->itemnumber, $patron->borrowernumber, 0, $reserve );    # Mark waiting (W)
    my $hold = Koha::Holds->find($reserve);
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout was not done due to attached hold (W)' );

    $hold->set_transfer;
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout was not done due to attached hold (T)' );

    $hold->set_processing;
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout was not done due to attached hold (P)' );

    # Test non-attached holds
    C4::Reserves::RevertWaitingStatus( { itemnumber => $hold->itemnumber } );
    t::lib::Mocks::mock_preference( 'AllowItemsOnHoldCheckoutSIP', '0' );
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout refused due to hold and AllowItemsOnHoldCheckoutSIP' );

    t::lib::Mocks::mock_preference( 'AllowItemsOnHoldCheckoutSIP', '1' );
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 1, 'Checkout allowed due to hold and AllowItemsOnHoldCheckoutSIP' );
};

subtest checkin_lost => sub {
    plan tests => 2;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    $item->itemlost(1)->itemlost_on(dt_from_string)->store();

    my $instituation = {
        id             => $library->id,
        implementation => "ILS",
        policy         => {
            checkin  => "true",
            renewal  => "true",
            checkout => "true",
            timeout  => 100,
            retries  => 5,
        }
    };
    my $ils = C4::SIP::ILS->new($instituation);

    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems', '1' );
    my $circ = $ils->checkin( $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode );
    is( $circ->{screen_msg}, 'Item lost, return not allowed', "Got correct screen message" );

    t::lib::Mocks::mock_preference( 'BlockReturnOfLostItems', '0' );
    $circ = $ils->checkin( $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode );
    is( $circ->{screen_msg}, 'Item not checked out', "Got 'Item not checked out' screen message" );
};

subtest checkin_withdrawn => sub {
    plan tests => 2;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    $item->withdrawn(1)->withdrawn_on(dt_from_string)->store();

    my $instituation = {
        id             => $library->id,
        implementation => "ILS",
        policy         => {
            checkin  => "true",
            renewal  => "true",
            checkout => "true",
            timeout  => 100,
            retries  => 5,
        }
    };
    my $ils = C4::SIP::ILS->new($instituation);

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', '1' );
    my $circ = $ils->checkin( $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode );
    is( $circ->{screen_msg}, 'Item withdrawn, return not allowed', "Got correct screen message" );

    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', '0' );
    $circ = $ils->checkin( $item->barcode, C4::SIP::Sip::timestamp, undef, $library->branchcode );
    is( $circ->{screen_msg}, 'Item not checked out', "Got 'Item not checked out' screen message" );
};

subtest _get_sort_bin => sub {
    plan tests => 24;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch   = $library->branchcode;
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $branch2  = $library2->branchcode;

    my $item_cd = $builder->build_sample_item(
        {
            library => $library->branchcode,
            itype   => 'CD'
        }
    );

    my $item_book = $builder->build_sample_item(
        {
            library        => $library->branchcode,
            itype          => 'BOOK',
            itemcallnumber => '200.01'
        }
    );

    my $item_book2 = $builder->build_sample_item(
        {
            library => $library2->branchcode,
            itype   => 'BOOK',
            ccode   => 'TEEN'
        }
    );

    my $item_dvd = $builder->build_sample_item(
        {
            library => $library2->branchcode,
            itype   => 'DVD'
        }
    );

    my $bin;

    my @line_endings = ( "\n", "\r\n", "\r" );
    my %eol_display  = ( "\n" => '\\n', "\r\n" => '\\r\\n', "\r" => '\\r' );

    foreach my $eol (@line_endings) {

        # Rules contain malformed line, empty line and a comment to prove they are skipped
        my $rules = join(
            $eol,
            (
                "$branch:homebranch:ne:\$holdingbranch:X",
                "$branch:effective_itemtype:eq:CD:0",
                "$branch:itemcallnumber:<:340:1",
                "$branch:itemcallnumber:<:370:2",
                "$branch:itemcallnumber:<:600:3",
                "$branch2:homebranch:ne:\$holdingbranch:X",
                "$branch2:effective_itemtype:eq:CD:4",
                "$branch2:itemcallnumber:>:600:5",
                "$branch2:effective_itemtype:eq:BOOK:ccode:eq:TEEN:6",
                "# Comment line to skip",
                "",                        # Empty line
                "$branch:homebranch:Z",    # Malformed line
            )
        );

        t::lib::Mocks::mock_preference( 'SIP2SortBinMapping', $rules );

        # Set holdingbranch as though item returned to library other than homebranch (As AddReturn would)
        $item_cd->holdingbranch( $library2->branchcode )->store();
        $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_cd, $library2->branchcode );
        is( $bin, 'X', "Item parameter on RHS of comparison works (ne comparator) with EOL '$eol_display{$eol}'" );

        # Reset holdingbranch as though item returned to home library
        $item_cd->holdingbranch( $library->branchcode )->store();
        $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_cd, $library->branchcode );
        is( $bin, '0', "Fixed value on RHS of comparison works (eq comparator) with EOL '$eol_display{$eol}'" );
        $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_book, $library->branchcode );
        is( $bin, '1', "Rules applied in order (< comparator) with EOL '$eol_display{$eol}'" );
        $item_book->itemcallnumber('350.20')->store();
        $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_book, $library->branchcode );
        is( $bin, '2', "Rules applied in order (< comparator) with EOL '$eol_display{$eol}'" );

        $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_book2, $library2->branchcode );
        is( $bin, '6', "Rules with multiple field matches with EOL '$eol_display{$eol}'" );

        warnings_are { $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_dvd, $library2->branchcode ); }
        ["Malformed preference line found: '$branch:homebranch:Z'"],
            "Comments and blank lines are skipped, Malformed lines are warned and skipped with EOL '$eol_display{$eol}'";

        # Reset for next loop
        $item_book->itemcallnumber('200.01')->store();
    }

    my $mixed_rules =
        "$branch:homebranch:ne:\$holdingbranch:X\n$branch:effective_itemtype:eq:CD:0\r\n$branch:itemcallnumber:<:340:1\r$branch:itemcallnumber:<:370:2\r\n$branch:itemcallnumber:<:600:3\n$branch2:homebranch:ne:\$holdingbranch:X\r$branch2:effective_itemtype:eq:CD:4\r\n$branch2:itemcallnumber:>:600:5\n$branch2:effective_itemtype:eq:BOOK:ccode:eq:TEEN:6\r# Comment line to skip\r\n\r\n\n$branch:homebranch:Z";
    t::lib::Mocks::mock_preference( 'SIP2SortBinMapping', $mixed_rules );

    # Set holdingbranch as though item returned to library other than homebranch (As AddReturn would)
    $item_cd->holdingbranch( $library2->branchcode )->store();
    $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_cd, $library2->branchcode );
    is( $bin, 'X', "Item parameter on RHS of comparison works (ne comparator) with mixed EOL" );

    # Reset holdingbranch as though item returned to home library
    $item_cd->holdingbranch( $library->branchcode )->store();
    $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_cd, $library->branchcode );
    is( $bin, '0', "Fixed value on RHS of comparison works (eq comparator) with mixed EOL" );
    $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_book, $library->branchcode );
    is( $bin, '1', "Rules applied in order (< comparator) with mixed EOL" );
    $item_book->itemcallnumber('350.20')->store();
    $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_book, $library->branchcode );
    is( $bin, '2', "Rules applied in order (< comparator) with mixed EOL" );

    $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_book2, $library2->branchcode );
    is( $bin, '6', "Rules with multiple field matches with mixed EOL" );

    warnings_are { $bin = C4::SIP::ILS::Transaction::Checkin::_get_sort_bin( $item_dvd, $library2->branchcode ); }
    ["Malformed preference line found: '$branch:homebranch:Z'"],
        "Comments and blank lines are skipped, Malformed lines are warned and skipped with mixed EOL";

};

subtest item_circulation_status => sub {
    plan tests => 8;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    my $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    my $status   = $sip_item->sip_circulation_status;
    is( $status, '03', "Item circulation status is available" );

    my $transfer = Koha::Item::Transfer->new(
        {
            itemnumber => $item->id,
            datesent   => '2020-01-01',
            frombranch => $library->branchcode,
            tobranch   => $library2->branchcode,
        }
    )->store();

    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    $status   = $sip_item->sip_circulation_status;
    is( $status, '10', "Item circulation status is in transit" );

    $transfer->delete;

    my $claim = Koha::Checkouts::ReturnClaim->new(
        {
            itemnumber     => $item->id,
            borrowernumber => $patron->id,
            created_by     => $patron->id,
        }
    )->store();

    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    $status   = $sip_item->sip_circulation_status;
    is( $status, '11', "Item circulation status is claimed returned" );

    $claim->delete;

    $item->itemlost(1)->store();
    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    $status   = $sip_item->sip_circulation_status;
    is( $status, '12', "Item circulation status is lost" );
    $status = $sip_item->sip_circulation_status( { account => { lost_status_for_missing => "1" } } );
    is( $status, '13', "Item circulation status is missing" );
    $item->itemlost(0)->store();

    my $location = $item->location;
    $item->location("CART")->store();
    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    $status   = $sip_item->sip_circulation_status;
    is( $status, '09', "Item circulation status is waiting to be re-shelved" );
    $item->location($location)->store();

    my $nfl = $item->notforloan;
    $item->notforloan(-1)->store();
    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    $status   = $sip_item->sip_circulation_status;
    is( $status, '02', "Item circulation status is on order" );
    $item->notforloan($nfl)->store();

    my $damaged = $item->damaged;
    $item->damaged(1)->store();
    $sip_item = C4::SIP::ILS::Item->new( $item->barcode );
    $status   = $sip_item->sip_circulation_status;
    is( $status, '01', "Item circulation status is damaged" );
    $item->damaged(0)->store();
};

subtest do_checkout_with_recalls => sub {
    plan tests => 7;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    my $patron2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    t::lib::Mocks::mock_preference( 'UseRecalls', 1 );
    Koha::CirculationRules->set_rule(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => 'recalls_allowed',
            rule_value   => '10',
        }
    );

    my $recall1 = Koha::Recall->new(
        {
            patron_id         => $patron2->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $item->biblio->biblionumber,
            pickup_library_id => $library->branchcode,
            item_id           => $item->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;

    my $sip_patron     = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item       = C4::SIP::ILS::Item->new( $item->barcode );
    my $co_transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is(
        $co_transaction->patron($sip_patron),
        $sip_patron, "Patron assigned to transaction"
    );
    is(
        $co_transaction->item($sip_item),
        $sip_item, "Item assigned to transaction"
    );

    # Test recalls made by another patron

    $recall1->set_waiting( { item => $item } );
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout was not done due to waiting recall' );

    $recall1->revert_waiting;
    $recall1->start_transfer( { item => $item } );
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout was not done due to recall in transit' );

    $recall1->revert_transfer;
    $recall1->update( { item_id => undef, item_level => 0 } );
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 0, 'Checkout was not done due to a biblio-level recall that this item could fill' );

    $recall1->set_cancelled;

    my $recall2 = Koha::Recall->new(
        {
            patron_id         => $patron->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $item->biblio->biblionumber,
            pickup_library_id => $library->branchcode,
            item_id           => $item->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;

    # Test recalls made by SIP patron

    $recall2->set_waiting( { item => $item } );
    $co_transaction->do_checkout();
    is( $patron->checkouts->count, 1, 'Checkout was done because recalled item was allocated to them' );
    $recall2 = Koha::Recalls->find( $recall2->id );
    is( $recall2->status, 'fulfilled', 'Recall is fulfilled by checked out item' );
};

subtest 'Checkin message' => sub {
    plan tests => 2;

    my $mockILS = Test::MockObject->new;
    my $server  = { ils => $mockILS };
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $institution = {
        id             => $library->id,
        implementation => "ILS",
        policy         => {
            checkin  => "true",
            renewal  => "true",
            checkout => "true",
            timeout  => 100,
            retries  => 5,
        }
    };
    my $ils  = C4::SIP::ILS->new($institution);
    my $item = $builder->build_sample_item(
        {
            library            => $library->branchcode,
            location           => 'My Location',
            permanent_location => 'My Permanent Location',
        }
    );

    t::lib::Mocks::mock_preference( 'AllowItemsOnLoanCheckoutSIP', '' );

    my $circ = $ils->checkout( $patron1->cardnumber, $item->barcode, undef, undef, $server->{account} );

    $circ = $ils->checkout( $patron2->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is(
        $circ->{screen_msg}, 'Item checked out to another patron',
        "Checked out item was not checked out to the next patron"
    );

    t::lib::Mocks::mock_preference( 'AllowItemsOnLoanCheckoutSIP', '1' );

    $circ = $ils->checkout( $patron2->cardnumber, $item->barcode, undef, undef, $server->{account} );
    is( $circ->{screen_msg}, '', "Checked out item was checked out to the next patron" );
};

$schema->storage->txn_rollback;
