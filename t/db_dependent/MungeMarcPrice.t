#!/usr/bin/perl

use strict;
use warnings;
use C4::Biblio;
use C4::Budgets;
use Test::More;
use utf8;

# work around wide character warnings
binmode Test::More->builder->output, ":encoding(UTF-8)";
binmode Test::More->builder->failure_output, ":encoding(UTF-8)";

# start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# set some test price strings and expected output
my @prices2test=( { string => '25,5 £, $34,55, $LD35',       expected => '34.55' },
                  { string => '32 EUR, 42.50$ USD, 54 CAD',  expected=>'42.50' },
                  { string => '38.80 Ksh, ¥300, 51,50 USD',  expected => '51.50' },
                  { string => '44 $, 33 €, 64 Br, £30',      expected => '44' },
                  { string => '9 EUR,$34,55 USD,$7.35 CAN',  expected => '34.55' },
                  { string => '$55.32',                      expected => '55.32' },
                  { string => '9.99 USD (paperback)',        expected => '9.99' },
                  { string => '$9.99 USD (paperback)',       expected => '9.99' },
                  { string => '18.95 (U.S.)',                expected => '18.95' },
                  { string => '$5.99 ($7.75 CAN)',           expected => '5.99' },
                  { string => '5.99 (7.75 CAN)',             expected => '5.99' },
                );

plan tests => scalar  @prices2test;

# set active currency test data
my $CURRENCY = 'TEST';
my $SYMBOL = '$';
my $ISOCODE = 'USD';
my $RATE= 1;

# disables existing active currency if necessary.
my $active_currency = C4::Budgets->GetCurrency();
my $curr;
if ($active_currency) {
    $curr = $active_currency->{'currency'};
    $dbh->do("UPDATE currency set active = 0 where currency = '$curr'");
}

$dbh->do("INSERT INTO currency ( currency,symbol,isocode,rate,active )
          VALUES ('$CURRENCY','$SYMBOL','$ISOCODE','$RATE',1)");
foreach my $price (@prices2test) {
    my $mungemarcprice=MungeMarcPrice($price->{'string'});
    my $expected=$price->{'expected'};
    ok ($mungemarcprice eq $expected, "must return $price->{'expected'} from initial string : $price->{'string'}");
}
# Cleanup
$dbh->rollback;
