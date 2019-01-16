#!/usr/bin/perl

# Tests for SIP::ILS::Transaction
# Current state is very rudimentary. Please help to extend it!

use Modern::Perl;
use Test::More tests => 4;

use Koha::Database;
use t::lib::TestBuilder;
use t::lib::Mocks;
use C4::SIP::ILS::Patron;
use C4::SIP::ILS::Transaction::RenewAll;
use C4::SIP::ILS::Transaction::Checkout;

use C4::Reserves;
use Koha::IssuingRules;

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
    plan tests => 5;


    my $category = $builder->build({ source => 'Category' });
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

    Koha::IssuingRule->new({
        categorycode     => $borrower->{categorycode},
        itemtype         => $itype->{itemtype},
        branchcode       => $branch->{branchcode},
        onshelfholds     => 1,
        reservesallowed  => 3,
        holds_per_record => 3,
        issuelength      => 5,
        lengthunit       => 'days',
        maxissueqty      => 10,
    })->store;

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
    $transaction->do_checkout();
    is( $bib->holds->count(), 1, "Bib has 1 holds remaining");


};
$schema->storage->txn_rollback;
