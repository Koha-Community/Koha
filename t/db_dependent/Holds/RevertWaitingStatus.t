#!/usr/bin/perl

use Modern::Perl;

use t::lib::Mocks;
use C4::Context;

use Test::More tests => 3;
use MARC::Record;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Reserves;

use Koha::Libraries;

use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM old_reserves");

my $library = $builder->build({
    source => 'Branch',
});

local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
*C4::Context::userenv = \&Mock_userenv;

sub Mock_userenv {
    my $userenv = { flags => 1, id => '1', branch => $library->{branchcode} };
    return $userenv;
}

my $borrowers_count = 3;

# Create a biblio instance
my ( $bibnum, $title, $bibitemnum ) = create_helper_biblio();

# Create an item
my $item_barcode = 'my_barcode';
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
    { homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode}, barcode => $item_barcode },
    $bibnum );

# Create some borrowers
my @borrowernumbers;
foreach my $i ( 1 .. $borrowers_count ) {
    my $borrowernumber = AddMember(
        firstname    => 'my firstname',
        surname      => 'my surname ' . $i,
        categorycode => 'S',
        branchcode   => $library->{branchcode},
    );
    push @borrowernumbers, $borrowernumber;
}

my $biblionumber = $bibnum;

my $branchcode = Koha::Libraries->search->next->branchcode;

# Create five item level holds
foreach my $borrowernumber (@borrowernumbers) {
    AddReserve(
        $branchcode,
        $borrowernumber,
        $biblionumber,
        my $bibitems   = q{},
        my $priority,
        my $resdate,
        my $expdate,
        my $notes = q{},
        $title,
        my $checkitem,
        my $found,
    );
}

ModReserveAffect( $itemnumber, $borrowernumbers[0] );
C4::Circulation::AddIssue( GetMember( borrowernumber => $borrowernumbers[1] ),
    $item_barcode, my $datedue, my $cancelreserve = 'revert' );

my $priorities = $dbh->selectall_arrayref(
    "SELECT priority FROM reserves ORDER BY priority ASC");
ok( scalar @$priorities == 2,   'Only 2 holds remain in the reserves table' );
ok( $priorities->[0]->[0] == 1, 'First hold has a priority of 1' );
ok( $priorities->[1]->[0] == 2, 'Second hold has a priority of 2' );

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $bib   = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
        MARC::Field->new( '245', ' ', ' ', a => $title ),
    );
    return ( $bibnum, $title, $bibitemnum ) = AddBiblio( $bib, '' );
}
