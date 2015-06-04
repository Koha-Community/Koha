#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 7;
use C4::Acquisition;
use C4::Biblio;
use C4::Bookseller;
use C4::Budgets;
use MARC::Record;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Acquisition::Order;

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

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
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
    }
);

my $budget = C4::Budgets::GetBudget( $budgetid );

my ($biblionumber1, $biblioitemnumber1) = AddBiblio(MARC::Record->new, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');


# returns undef and croaks if basketno, quantity, biblionumber or budget_id is missing
my $order = eval { Koha::Acquisition::Order->new->insert };
my $return_error = $@;
ok(
    ( ! defined $order )
      && ( defined $return_error ),
    "Inserting an order with no params returns undef and croaks"
);

my $mandatoryparams = {
    basketno     => $basketno,
    quantity     => 24,
    biblionumber => $biblionumber1,
    budget_id    => $budgetid,
};
my @mandatoryparams_keys = keys %$mandatoryparams;
foreach my $mandatoryparams_key (@mandatoryparams_keys) {
    my %test_missing_mandatoryparams = %$mandatoryparams;
    delete $test_missing_mandatoryparams{$mandatoryparams_key};
    $order = eval {
          Koha::Acquisition::Order->new( \%test_missing_mandatoryparams )->insert;
    };
    $return_error = $@;
    my $expected_error = "Cannot insert order: Mandatory parameter $mandatoryparams_key is missing";
    ok(
        ( !( defined $order ) )
          && ( index( $return_error, $expected_error ) >= 0 ),
"Inserting an order with no $mandatoryparams_key returns undef and croaks with expected error message"
    );
}

$order = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 24,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
)->insert;
my $ordernumber = $order->{ordernumber};
$order = Koha::Acquisition::Order->fetch({ ordernumber => $ordernumber });
is( $order->{quantityreceived}, 0, 'Koha::Acquisition::Order->insert set quantityreceivedto 0 if undef is given' );
is( $order->{entrydate}, output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 }), 'Koha::Acquisition::Order->insert set entrydate to today' );

$schema->storage->txn_rollback();