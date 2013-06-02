#!/usr/bin/perl

use Modern::Perl;
use C4::Context;

use Test::More tests => 49;
use Test::MockModule;

use_ok('C4::Acquisition');

my $module = new Test::MockModule('C4::Context');
$module->mock('_new_dbh', sub {
    my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
        || die "Cannot create handle: $DBI::errstr\n";
    return $dbh;
});

my $dbh = C4::Context->dbh;

# We need to add a resultset to avoid DBI fail
# ("DBI bind_columns: invalid number of arguments...")
my $rs = [
    [qw(one two three four)],
    [1, 2, 3, 4]
];

$dbh->{mock_add_resultset} = $rs;
my @invoices = C4::Acquisition::GetInvoices(
    supplierid => "supplierid",
    invoicenumber => "invoicenumber",
    suppliername => "suppliername",
    shipmentdatefrom => "shipmentdatefrom",
    shipmentdateto => "shipmentdateto",
    billingdatefrom => "billingdatefrom",
    billingdateto => "billingdateto",
    isbneanissn => "isbneanissn",
    title => "title",
    author => "author",
    publisher => "publisher",
    publicationyear => "publicationyear",
    branchcode => "branchcode",
);
my $history = $dbh->{mock_all_history};

is(scalar(@$history), 1);
my @bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 15);
is($bound_params[0], 'supplierid');
is($bound_params[1], '%invoicenumber%');
is($bound_params[2], '%suppliername%');
is($bound_params[3], 'shipmentdatefrom');
is($bound_params[4], 'shipmentdateto');
is($bound_params[5], 'billingdatefrom');
is($bound_params[6], 'billingdateto');
is($bound_params[7], 'isbneanissn');
is($bound_params[8], 'isbneanissn');
is($bound_params[9], 'isbneanissn');
is($bound_params[10], 'title');
is($bound_params[11], 'author');
is($bound_params[12], 'publisher');
is($bound_params[13], 'publicationyear');
is($bound_params[14], 'branchcode');

$dbh->{mock_clear_history} = 1;
$dbh->{mock_add_resultset} = $rs;
GetInvoice(42);
$history = $dbh->{mock_all_history};
is(scalar(@$history), 1);
@bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 1);
is($bound_params[0], 42);

$dbh->{mock_clear_history} = 1;
$dbh->{mock_add_resultset} = $rs;
$dbh->{mock_add_resultset} = $rs;
my $invoice = GetInvoiceDetails(42);
$history = $dbh->{mock_all_history};
is(scalar(@$history), 2);
@bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 1);
is($bound_params[0], 42);
@bound_params = @{ $history->[1]->{bound_params} };
is(scalar(@bound_params), 1);
is($bound_params[0], 42);
ok(exists $invoice->{orders});

$dbh->{mock_clear_history} = 1;
is(AddInvoice(booksellerid => 1), undef);   # Fails because of a missing parameter
$history = $dbh->{mock_all_history};
is(scalar(@$history), 0);

$dbh->{mock_clear_history} = 1;
AddInvoice(invoicenumber => 'invoice', booksellerid => 1, unknown => "unknown");
$history = $dbh->{mock_all_history};
is(scalar(@$history), 1);
@bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 2);
ok(grep /^1$/, @bound_params);
ok(grep /^invoice$/, @bound_params);
ok(not grep /unknown/, @bound_params);

$dbh->{mock_clear_history} = 1;
is(ModInvoice(booksellerid => 1), undef);   # Fails because of a missing parameter
$history = $dbh->{mock_all_history};
is(scalar(@$history), 0);

$dbh->{mock_clear_history} = 1;
ModInvoice(invoiceid => 3, invoicenumber => 'invoice', unknown => "unknown");
$history = $dbh->{mock_all_history};
is(scalar(@$history), 1);
@bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 2);
ok(grep /^3$/, @bound_params);
ok(grep /^invoice$/, @bound_params);
ok(not grep /unknown/, @bound_params);

$dbh->{mock_clear_history} = 1;
CloseInvoice(42);
$history = $dbh->{mock_all_history};
is(scalar(@$history), 1);
@bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 1);
is($bound_params[0], 42);

$dbh->{mock_clear_history} = 1;
ReopenInvoice(42);
$history = $dbh->{mock_all_history};
is(scalar(@$history), 1);
@bound_params = @{ $history->[0]->{bound_params} };
is(scalar(@bound_params), 1);
is($bound_params[0], 42);
my $checkordersrs = [
    [qw(COUNT)],
    [2]
];

$dbh->{mock_add_resultset} = $checkordersrs;
is(DelInvoice(42), undef, "Invoices with items don't get deleted");

$checkordersrs = [
    [qw(COUNT)],
    [0]
];

my $deleters = [
    [qw(COUNT)],
    [1]
];

$dbh->{mock_add_resultset} = $checkordersrs;
$dbh->{mock_add_resultset} = $deleters;
ok(DelInvoice(42), "Invoices with items do get deleted");
