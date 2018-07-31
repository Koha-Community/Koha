#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 74;
use List::Util qw( shuffle );
use MARC::Field;
use MARC::Record;

use C4::Context;
use C4::Items;
use C4::Biblio;
use Koha::Database;

use t::lib::TestBuilder;

use_ok('C4::ShelfBrowser');

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM reserves|);
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);

my $library = $builder->build({
    source => 'Branch',
});

my $cn;

# 100.100 150.100 200.100 210.100 300.000 320.000 400.100 410.100 500.100 510.100 520.100 600.000 610.000 700.100 710.100 720.100 730.100 740.100 750.100
my @callnumbers = qw(
    100.100
    150.100
    200.100
    210.100
    300.000
    320.000
    400.100
    410.100
    500.100
    510.100
    520.100
    600.000
    610.000
    700.100
    710.100
    720.100
    730.100
    740.100
    750.100
);

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Donald E. Knuth.'),
    MARC::Field->new('245', ' ', ' ', a => 'The art of computer programming'),
);
my ( $biblionumber ) = C4::Biblio::AddBiblio($record, '');

for my $callnumber ( shuffle @callnumbers ) {
    my ( $biblionumber, undef, $itemnumber ) = C4::Items::AddItem({
        homebranch => $library->{branchcode},
        holdingbranch => $library->{branchcode},
        itemcallnumber => $callnumber,
    }, $biblionumber);
    $cn->{$callnumber} = {
        biblionumber => $biblionumber,
        itemnumber => $itemnumber,
        itemcallnumber => $callnumber,
    }
}

my $nearby;

$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'500.100'}{itemnumber} );
# We have
# < 320.000 400.100 410.100 500.100 510.100 520.100 600.000 >
#      6       7       8      [9]       10      11      12
# Clicking on previous, we want a link to 150.100
is( $nearby->{prev_item}{itemcallnumber}, '150.100', "Simple case: previous link 1/2" );
is( $nearby->{prev_item}{itemnumber}, $cn->{'150.100'}{itemnumber}, "Simple case: previous link 2/2" );
# Clicking on next, we want a link to 730.100
is( $nearby->{next_item}{itemcallnumber}, '720.100', "Simple case: next link 1/2" );
is( $nearby->{next_item}{itemnumber}, $cn->{'720.100'}{itemnumber}, "Simple case: next link 2/2" );

is( $nearby->{items}[0]{itemcallnumber}, '320.000', "Simple case: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '400.100', "Simple case: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '410.100', "Simple case: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '500.100', "Simple case: item 4");
is( $nearby->{items}[4]{itemcallnumber}, '510.100', "Simple case: item 5");
is( $nearby->{items}[5]{itemcallnumber}, '520.100', "Simple case: item 6");
is( $nearby->{items}[6]{itemcallnumber}, '600.000', "Simple case: item 7");

$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'500.100'}{itemnumber}, 2, 3 );
# We have
# < 400.100 410.100 500.100 510.100 520.100 >
#      7       8      [9]       10      11
# Clicking on previous, we want a link to 320.000
is( $nearby->{prev_item}{itemcallnumber}, '320.000', "Test gap: previous link 1/2" );
is( $nearby->{prev_item}{itemnumber}, $cn->{'320.000'}{itemnumber}, "Test gap: previous link 2/2" );
# Clicking on next, we want a link to 600.000
is( $nearby->{next_item}{itemcallnumber}, '600.000', "Test gap: next link 1/2" );
is( $nearby->{next_item}{itemnumber}, $cn->{'600.000'}{itemnumber}, "Test gap: next link 2/2" );

is( scalar( @{$nearby->{items}} ), 5, "Test gap: got 5 items" );
is( $nearby->{items}[0]{itemcallnumber}, '400.100', "Test gap: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '410.100', "Test gap: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '500.100', "Test gap: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '510.100', "Test gap: item 4");
is( $nearby->{items}[4]{itemcallnumber}, '520.100', "Test gap: item 5");

$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'300.000'}{itemnumber} );
# We have
# < 150.100 200.100 210.100 300.000 320.000 400.100 410.100 >
#      2       3       4      [5]      6       7       8
# Clicking on previous, we want a link to 100.100
is( $nearby->{prev_item}{itemcallnumber}, '100.100', "Test start shelf: previous link 1/2" );
is( $nearby->{prev_item}{itemnumber}, $cn->{'100.100'}{itemnumber}, "Test start shelf: previous link 2/2" );
# Clicking on next, we want a link to 600.000
is( $nearby->{next_item}{itemcallnumber}, '600.000', "Test start shelf: next link 1/2" );
is( $nearby->{next_item}{itemnumber}, $cn->{'600.000'}{itemnumber}, "Test start shelf: next link 2/2" );

is( $nearby->{items}[0]{itemcallnumber}, '150.100', "Test start shelf: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '200.100', "Test start shelf: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '210.100', "Test start shelf: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '300.000', "Test start shelf: item 4");
is( $nearby->{items}[4]{itemcallnumber}, '320.000', "Test start shelf: item 5");
is( $nearby->{items}[5]{itemcallnumber}, '400.100', "Test start shelf: item 6");
is( $nearby->{items}[6]{itemcallnumber}, '410.100', "Test start shelf: item 7");



$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'100.100'}{itemnumber} );
# We have
# 100.100 150.100 200.100 210.100 >
#   [1]       2       3       4
# There is no previous link
is( $nearby->{prev_item}, undef, "Test first item on a shelf: no previous link" );
# Clicking on next, we want a link to 410.100
is( $nearby->{next_item}{itemcallnumber}, '410.100', "Test first item on a shelf: next link 1/2" );
is( $nearby->{next_item}{itemnumber}, $cn->{'410.100'}{itemnumber}, "Test first item on a shelf: next link 2/2" );

is( scalar( @{$nearby->{items}} ), 4, "Test first item on a shelf: There are 4 items displayed" );
is( $nearby->{items}[0]{itemcallnumber}, '100.100', "Test first item on a shelf: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '150.100', "Test first item on a shelf: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '200.100', "Test first item on a shelf: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '210.100', "Test first item on a shelf: item 4");


$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'150.100'}{itemnumber} );
# We have
# 100.100 150.100 200.100 210.100 300.000 >
#    1      [2]       3       4      5
# There is no previous link
is( $nearby->{prev_item}, undef, "Test second item on a shelf: no previous link" );
# Clicking on next, we want a link to 500.100
is( $nearby->{next_item}{itemcallnumber}, '500.100', "Test second item on a shelf: next link 1/2" );
is( $nearby->{next_item}{itemnumber}, $cn->{'500.100'}{itemnumber}, "Test second item on a shelf: next link 2/2" );

is( scalar( @{$nearby->{items}} ), 5, "Test second item on a shelf: got 5 items" );
is( $nearby->{items}[0]{itemcallnumber}, '100.100', "Test second item on a shelf: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '150.100', "Test second item on a shelf: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '200.100', "Test second item on a shelf: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '210.100', "Test second item on a shelf: item 4");
is( $nearby->{items}[4]{itemcallnumber}, '300.000', "Test second item on a shelf: item 5");


$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'710.100'}{itemnumber} );
# We have
# < 600.000 610.000 700.100 710.100 720.100 730.100 740.100 >
#      12      13      14     [15]     16      17      18
# Clicking on previous, we want a link to 410.100
is( $nearby->{prev_item}{itemcallnumber}, '410.100', "Test end shelf: previous link 1/2" );
is( $nearby->{prev_item}{itemnumber}, $cn->{'410.100'}{itemnumber}, "Test end shelf: previous link 2/2" );
# Clicking on next, we want a link to 730.100
is( $nearby->{next_item}{itemcallnumber}, '750.100', "Test end shelf: next link is a link to the last item 1/2" );
is( $nearby->{next_item}{itemnumber}, $cn->{'750.100'}{itemnumber}, "Test end shelf: next link is a link to the last item 2/2" );

is( $nearby->{items}[0]{itemcallnumber}, '600.000', "Test end shelf: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '610.000', "Test end shelf: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '700.100', "Test end shelf: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '710.100', "Test end shelf: item 4");
is( $nearby->{items}[4]{itemcallnumber}, '720.100', "Test end shelf: item 5");
is( $nearby->{items}[5]{itemcallnumber}, '730.100', "Test end shelf: item 6");
is( $nearby->{items}[6]{itemcallnumber}, '740.100', "Test end shelf: item 7");


$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'740.100'}{itemnumber} );
# We have
# < 710.100 720.100 730.100 740.100 750.100
#      15      16      17     [18]     19
# Clicking on previous, we want a link to
is( $nearby->{prev_item}{itemcallnumber}, '520.100', "Test end of the shelf: previous link 1/2" );
is( $nearby->{prev_item}{itemnumber}, $cn->{'520.100'}{itemnumber}, "Test end of the shelf: previous link 2/2" );
# No next link
is( $nearby->{next_item}, undef, "Test end of the shelf: no next link" );

is( scalar( @{$nearby->{items}} ), 5, "Test end of the shelf: got 5 items" );
is( $nearby->{items}[0]{itemcallnumber}, '710.100', "Test end of the shelf: item 1");
is( $nearby->{items}[1]{itemcallnumber}, '720.100', "Test end of the shelf: item 2");
is( $nearby->{items}[2]{itemcallnumber}, '730.100', "Test end of the shelf: item 3");
is( $nearby->{items}[3]{itemcallnumber}, '740.100', "Test end of the shelf: item 4");
is( $nearby->{items}[4]{itemcallnumber}, '750.100', "Test end of the shelf: item 5");

$nearby = C4::ShelfBrowser::GetNearbyItems( $cn->{'750.100'}{itemnumber} );
# We have
# < 720.100 730.100 740.100 750.100
#      16      17      18     [19]
# Clicking on previous, we want a link to
is( $nearby->{prev_item}{itemcallnumber}, '600.000', "Test last item of the shelf: previous link 1/2" );
is( $nearby->{prev_item}{itemnumber}, $cn->{'600.000'}{itemnumber}, "Test last item of the shelf: previous link 2/2" );
# No next link
is( $nearby->{next_item}, undef, "Test end of the shelf: no next link" );

is( scalar( @{$nearby->{items}} ), 4, "Test last item of the shelf: got 4 items" );
