#!/usr/bin/perl

use Modern::Perl;
use Test::More;
use Test::More tests => 1;
use Try::Tiny;

use C4::Koha;

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{RaiseError} = 1;
# Setup stage
$dbh->do("DELETE FROM quotes");
##populate test context
$dbh->do("INSERT INTO `quotes` VALUES
    (10,'Dusk And Her Embrace','Unfurl thy limbs breathless succubus<br/>How the full embosomed fog<br/>Imparts the night to us....','0000-00-00 00:00:00');
");

my $expected_quote = {
    id          => 10,
    source      => 'Dusk And Her Embrace',
    text        => 'Unfurl thy limbs breathless succubus<br/>How the full embosomed fog<br/>Imparts the night to us....',
    timestamp   => '0000-00-00 00:00:00',
};


subtest "GetDailyQuoteForInterface", \&GetDailyQuoteForInterfaceTest;
sub GetDailyQuoteForInterfaceTest {
    my ($quote);

    ##Set interface and get nothing because syspref is not set.
    C4::Context->interface('opac');
    $quote = C4::Koha::GetDailyQuoteForInterface(id => 10);
    ok(not($quote), "'QuoteOfTheDay'-syspref not set so nothing returned");

    ##Set 'QuoteOfTheDay'-syspref to not include current interface 'opac'
    C4::Context->set_preference('QuoteOfTheDay', 'intra commandline sip2 api yo-mama');
    $quote = C4::Koha::GetDailyQuoteForInterface(id => 10);
    ok(not($quote), "'QuoteOfTheDay'-syspref doesn't include 'opac'");

    ##Set 'QuoteOfTheDay'-syspref to include current interface 'opac'
    C4::Context->set_preference('QuoteOfTheDay', 'intraopaccommandline');
    $quote = C4::Koha::GetDailyQuoteForInterface(id => 10);
    is_deeply($quote, $expected_quote, "Got the expected quote");

}

# teardown
C4::Context->set_preference('QuoteOfTheDay', undef);
$dbh->do("DELETE FROM quotes");