#!/usr/bin/env perl

use Modern::Perl;

use Test::More;
use C4::Acquisition;
use C4::Biblio qw( AddBiblio DelBiblio );
use C4::Bookseller;
use C4::Budgets;

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my $basketno = C4::Acquisition::NewBasket(
    $booksellerid
);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_close_reopen",
        budget_name => "budget_name_test_close_reopen",
    }
);

my $budget = C4::Budgets::GetBudget( $budgetid );

my ($biblionumber1, $biblioitemnumber1) = AddBiblio(MARC::Record->new, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');

my ($ordernumber1, $ordernumber2);
( undef, $ordernumber1 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 24,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
);

( undef, $ordernumber2 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 42,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
);

my $nb_biblio = C4::Acquisition::GetBiblioCountByBasketno( $basketno );
is ( $nb_biblio, 2, "There are 2 biblio for this basket" );
my @orders = C4::Acquisition::GetOrders( $basketno );
is( scalar(@orders), 2, "2 orders are created" );
is ( scalar( map { $_->{orderstatus} == 0 ? 1 : () } @orders ), 2, "2 order are new before closing the basket" );

C4::Acquisition::CloseBasket( $basketno );
@orders = C4::Acquisition::GetOrders( $basketno );
is ( scalar( map { $_->{orderstatus} == 1 ? 1 : () } @orders ), 2, "2 orders are ordered, the basket is closed" );

C4::Acquisition::ReopenBasket( $basketno );
@orders = C4::Acquisition::GetOrders( $basketno );
is ( scalar( map { $_->{orderstatus} == 1 ? 1 : () } @orders ), 0, "No order are ordered, the basket is reopen" );
is ( scalar( map { $_->{orderstatus} == 0 ? 1 : () } @orders ), 2, "2 order are new, the basket is reopen" );


END {
    C4::Acquisition::DelOrder( 1, $ordernumber1 );
    C4::Acquisition::DelOrder( 2, $ordernumber2 );
    C4::Budgets::DelBudget( $budgetid );
    C4::Acquisition::DelBasket( $basketno );
    C4::Bookseller::DelBookseller( $booksellerid );
    C4::Biblio::DelBiblio($biblionumber1);
    C4::Biblio::DelBiblio($biblionumber2);
};

done_testing;
