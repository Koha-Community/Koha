#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 39;
use Test::Mojo;

use DateTime;

use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::Reserves;

use Koha::Database;
use Koha::Patron;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
my $branchcode = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

my $borrower = Koha::Patron->new;
$borrower->categorycode( $categorycode );
$borrower->branchcode( $branchcode );
$borrower->surname("Test Surname");
$borrower->store;
my $borrowernumber = $borrower->borrowernumber;

my $borrower2 = Koha::Patron->new;
$borrower2->categorycode( $categorycode );
$borrower2->branchcode( $branchcode );
$borrower2->surname("Test Surname 2");
$borrower2->store;
my $borrowernumber2 = $borrower2->borrowernumber;

my $biblionumber = create_biblio('RESTful Web APIs');
my $itemnumber = create_item($biblionumber, 'TEST000001');

$dbh->do('DELETE FROM reserves');

my $reserve_id = C4::Reserves::AddReserve($branchcode, $borrowernumber,
    $biblionumber, undef, 1, undef, undef, undef, '', $itemnumber);

# Add another reserve to be able to change first reserve's rank
C4::Reserves::AddReserve($branchcode, $borrowernumber2,
    $biblionumber, undef, 2, undef, undef, undef, '', $itemnumber);

$t->get_ok('/api/v1/holds')
    ->status_is(200)
    ->json_has('/0')
    ->json_has('/1')
    ->json_hasnt('/2');

$t->get_ok('/api/v1/holds?priority=2')
    ->status_is(200)
    ->json_is('/0/borrowernumber', $borrowernumber2)
    ->json_hasnt('/1');

my $suspend_until = DateTime->now->add(days => 10)->ymd;
my $put_data = {
    priority => 2,
    suspend_until => $suspend_until,
};
$t->put_ok("/api/v1/holds/$reserve_id" => json => $put_data)
  ->status_is(200)
  ->json_is('/reserve_id', $reserve_id)
  ->json_is('/suspend_until', $suspend_until . ' 00:00:00')
  ->json_is('/priority', 2);

$t->delete_ok("/api/v1/holds/$reserve_id")
  ->status_is(200);

$t->put_ok("/api/v1/holds/$reserve_id" => json => $put_data)
  ->status_is(404)
  ->json_has('/error');

$t->delete_ok("/api/v1/holds/$reserve_id")
  ->status_is(404)
  ->json_has('/error');


$t->get_ok("/api/v1/holds?borrowernumber=$borrowernumber")
  ->status_is(200)
  ->json_is([]);

my $inexisting_borrowernumber = $borrowernumber2 + 1;
$t->get_ok("/api/v1/holds?borrowernumber=$inexisting_borrowernumber")
  ->status_is(200)
  ->json_is([]);

$dbh->do('DELETE FROM issuingrules');
$dbh->do(q{
    INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
    VALUES (?, ?, ?, ?)
}, {}, '*', '*', '*', 1);

my $expirationdate = DateTime->now->add(days => 10)->ymd;
my $post_data = {
    borrowernumber => int($borrowernumber),
    biblionumber => int($biblionumber),
    itemnumber => int($itemnumber),
    branchcode => $branchcode,
    expirationdate => $expirationdate,
};
$t->post_ok("/api/v1/holds" => json => $post_data)
  ->status_is(201)
  ->json_has('/reserve_id');

$reserve_id = $t->tx->res->json->{reserve_id};

$t->get_ok("/api/v1/holds?borrowernumber=$borrowernumber")
  ->status_is(200)
  ->json_is('/0/reserve_id', $reserve_id)
  ->json_is('/0/expirationdate', $expirationdate)
  ->json_is('/0/branchcode', $branchcode);

$t->post_ok("/api/v1/holds" => json => $post_data)
  ->status_is(403)
  ->json_like('/error', qr/tooManyReserves/);


$dbh->rollback;

sub create_biblio {
    my ($title) = @_;

    my $record = new MARC::Record;
    $record->append_fields(
        new MARC::Field('200', ' ', ' ', a => $title),
    );

    my ($biblionumber) = C4::Biblio::AddBiblio($record, '');

    return $biblionumber;
}

sub create_item {
    my ($biblionumber, $barcode) = @_;

    my $item = {
        barcode => $barcode,
    };

    my $itemnumber = C4::Items::AddItem($item, $biblionumber);

    return $itemnumber;
}
