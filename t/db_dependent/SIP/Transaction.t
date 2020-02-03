#!/usr/bin/perl

# Tests for SIP::ILS::Transaction
# Current state is very rudimentary. Please help to extend it!

use Modern::Perl;
use Test::More tests => 6;

use Koha::Database;
use t::lib::TestBuilder;
use t::lib::Mocks;
use C4::SIP::ILS::Patron;
use C4::SIP::ILS::Transaction::RenewAll;
use C4::SIP::ILS::Transaction::Checkout;
use C4::SIP::ILS::Transaction::FeePayment;
use C4::SIP::ILS::Transaction::Hold;

use C4::Reserves;
use Koha::CirculationRules;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $borr1 = $builder->build({ source => 'Borrower' });
my $card = $borr1->{cardnumber};
my $sip_patron = C4::SIP::ILS::Patron->new( $card );

# Create transaction RenewAll, assign patron, and run (no items)
my $transaction = C4::SIP::ILS::Transaction::RenewAll->new();
is( ref $transaction, "C4::SIP::ILS::Transaction::RenewAll", "New transaction created" );
is( $transaction->patron( $sip_patron ), $sip_patron, "Patron assigned to transaction" );
isnt( $transaction->do_renew_all, undef, "RenewAll on zero items" );

subtest fill_holds_at_checkout => sub {
    plan tests => 6;


    my $category = $builder->build({ source => 'Category', value => { category_type => 'A' }});
    my $branch   = $builder->build({ source => 'Branch' });
    my $borrower = $builder->build({ source => 'Borrower', value =>{
        branchcode => $branch->{branchcode},
        categorycode=>$category->{categorycode}
        }
    });
    t::lib::Mocks::mock_userenv({ branchcode => $branch->{branchcode}, flags => 1 });

    my $itype = $builder->build({ source => 'Itemtype', value =>{notforloan=>0} });
    my $biblio = $builder->build({ source => 'Biblio' });
    my $biblioitem = $builder->build({ source => 'Biblioitem', value=>{biblionumber=>$biblio->{biblionumber}} });
    my $item1 = $builder->build({ source => 'Item', value => {
        barcode       => 'barcode4test',
        homebranch    => $branch->{branchcode},
        holdingbranch => $branch->{branchcode},
        biblionumber  => $biblio->{biblionumber},
        itype         => $itype->{itemtype},
        notforloan       => 0,
        }
    });
    my $item2 = $builder->build({ source => 'Item', value => {
        homebranch    => $branch->{branchcode},
        holdingbranch => $branch->{branchcode},
        biblionumber  => $biblio->{biblionumber},
        itype         => $itype->{itemtype},
        notforloan       => 0,
        }
    });

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

    my $reserve1 = AddReserve($branch->{branchcode},$borrower->{borrowernumber},$biblio->{biblionumber});
    my $reserve2 = AddReserve($branch->{branchcode},$borrower->{borrowernumber},$biblio->{biblionumber});
    my $bib = Koha::Biblios->find( $biblio->{biblionumber} );
    is( $bib->holds->count(), 2, "Bib has 2 holds");

    my $sip_patron = C4::SIP::ILS::Patron->new( $borrower->{cardnumber} );
    my $sip_item   = C4::SIP::ILS::Item->new( $item1->{barcode} );
    my $transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is( ref $transaction, "C4::SIP::ILS::Transaction::Checkout", "New transaction created" );
    is( $transaction->patron( $sip_patron ), $sip_patron, "Patron assigned to transaction" );
    is( $transaction->item( $sip_item ), $sip_item, "Item assigned to transaction" );
    my $checkout = $transaction->do_checkout();
    use Data::Dumper; # Temporary debug statement
    is( $bib->holds->count(), 1, "Bib has 1 holds remaining") or diag Dumper $checkout;

    t::lib::Mocks::mock_preference('itemBarcodeInputFilter', 'whitespace');
    $sip_item   = C4::SIP::ILS::Item->new( ' barcode 4 test ');
    $transaction = C4::SIP::ILS::Transaction::Checkout->new();
    is( $sip_item->{barcode}, $item1->{barcode}, "Item assigned to transaction" );
};

subtest "FeePayment->pay tests" => sub {

    plan tests => 5;

    # Create a borrower and add some outstanding debts to their account
    my $patron = $builder->build( { source => 'Borrower' } );
    my $account =
      Koha::Account->new( { patron_id => $patron->{borrowernumber} } );
    my $debt1 = $account->add_debit(
        { type => 'ACCOUNT', amount => 100, interface => 'commandline' } );
    my $debt2 = $account->add_debit(
        { type => 'ACCOUNT', amount => 200, interface => 'commandline' } );

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
    my $pay_type = '00';    # 00 - Cash, 01 - VISA, 02 - Creditcard
    my $ok =
      $trans->pay( $patron->{borrowernumber}, 100, $pay_type, $debt1->id, 0,
        0 );
    ok( $ok, "FeePayment transaction succeeded" );
    $debt1->discard_changes;
    is( $debt1->amountoutstanding + 0, 0,
        "Debt1 was reduced to 0 as expected" );
    my $offsets = Koha::Account::Offsets->search(
        { debit_id => $debt1->id, credit_id => { '!=' => undef } } );
    is( $offsets->count, 1, "FeePayment produced an offset line correctly" );
    my $credit = $offsets->next->credit;
    is( $credit->payment_type, 'SIP00', "Payment type was set correctly" );
};

subtest cancel_hold => sub {
    plan tests => 7;

    my $library = $builder->build_object ({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode, flags => 1 });

    my $item = $builder->build_sample_item({
        library       => $library->branchcode,
    });

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

    my $reserve1 =
      AddReserve( $library->branchcode, $patron->borrowernumber,
        $item->biblio->biblionumber,
        undef, undef, undef, undef, undef, undef, $item->itemnumber );
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib");
    is( $item->holds->count(),1,"Hold was placed on specific item");

    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $sip_item   = C4::SIP::ILS::Item->new( $item->barcode );
    my $transaction = C4::SIP::ILS::Transaction::Hold->new();
    is( ref $transaction, "C4::SIP::ILS::Transaction::Hold", "New transaction created" );
    is( $transaction->patron( $sip_patron ), $sip_patron, "Patron assigned to transaction" );
    is( $transaction->item( $sip_item ), $sip_item, "Item assigned to transaction" );
    my $hold = $transaction->drop_hold();
    is( $item->biblio->holds->count(), 0, "Bib has 0 holds remaining");
    is( $item->holds->count(), 0,  "Item has 0 holds remaining");
};

$schema->storage->txn_rollback;
