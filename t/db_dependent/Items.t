#!/usr/bin/perl
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#

use Modern::Perl;

use MARC::Record;
use C4::Biblio;

use Test::More tests => 3;

BEGIN {
    use_ok('C4::Items');
}

my $dbh = C4::Context->dbh;

subtest 'General Add, Get and Del tests' => sub {

    plan tests => 6;

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    # Helper biblio.
    diag("Creating biblio instance for testing.");
    my ($bibnum, $bibitemnum) = get_biblio();

    # Add an item.
    my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);
    cmp_ok($item_bibnum, '==', $bibnum, "New item is linked to correct biblionumber.");
    cmp_ok($item_bibitemnum, '==', $bibitemnum, "New item is linked to correct biblioitemnumber.");

    # Get item.
    my $getitem = GetItem($itemnumber);
    cmp_ok($getitem->{'itemnumber'}, '==', $itemnumber, "Retrieved item has correct itemnumber.");
    cmp_ok($getitem->{'biblioitemnumber'}, '==', $item_bibitemnum, "Retrieved item has correct biblioitemnumber.");

    # Modify item; setting barcode.
    ModItem({ barcode => '987654321' }, $bibnum, $itemnumber);
    my $moditem = GetItem($itemnumber);
    cmp_ok($moditem->{'barcode'}, '==', '987654321', 'Modified item barcode successfully to: '.$moditem->{'barcode'} . '.');

    # Delete item.
    DelItem($dbh, $bibnum, $itemnumber);
    my $getdeleted = GetItem($itemnumber);
    is($getdeleted->{'itemnumber'}, undef, "Item deleted as expected.");

    $dbh->rollback;
};

subtest 'GetHiddenItemnumbers tests' => sub {

    plan tests => 9;

    # This sub is controlled by the OpacHiddenItems system preference.

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    # Create a new biblio
    my ($biblionumber, $biblioitemnumber) = get_biblio();

    # Add two items
    my ($item1_bibnum, $item1_bibitemnum, $item1_itemnumber) = AddItem(
            { homebranch => 'CPL',
              holdingbranch => 'CPL',
              withdrawn => 1 },
            $biblionumber
    );
    my ($item2_bibnum, $item2_bibitemnum, $item2_itemnumber) = AddItem(
            { homebranch => 'MPL',
              holdingbranch => 'MPL',
              withdrawn => 0 },
            $biblionumber
    );

    my $opachiddenitems;
    my @itemnumbers = ($item1_itemnumber,$item2_itemnumber);
    my @hidden;
    my @items;
    push @items, GetItem( $item1_itemnumber );
    push @items, GetItem( $item2_itemnumber );

    # Empty OpacHiddenItems
    C4::Context->set_preference('OpacHiddenItems','');
    ok( !defined( GetHiddenItemnumbers( @items ) ),
        "Hidden items list undef if OpacHiddenItems empty");

    # Blank spaces
    C4::Context->set_preference('OpacHiddenItems','  ');
    ok( scalar GetHiddenItemnumbers( @items ) == 0,
        "Hidden items list empty if OpacHiddenItems only contains blanks");

    # One variable / value
    $opachiddenitems = "
        withdrawn: [1]";
    C4::Context->set_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 1, "Only one hidden item");
    is( $hidden[0], $item1_itemnumber, "withdrawn=1 is hidden");

    # One variable, two values
    $opachiddenitems = "
        withdrawn: [1,0]";
    C4::Context->set_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and withdrawn=0 hidden");

    # Two variables, a value each
    $opachiddenitems = "
        withdrawn: [1]
        homebranch: [MPL]
    ";
    C4::Context->set_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and homebranch=MPL hidden");

    # Valid OpacHiddenItems, empty list
    @items = ();
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 0, "Empty items list, no item hidden");

    $dbh->rollback;
};

# Helper method to set up a Biblio.
sub get_biblio {
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
    my ($bibnum, $bibitemnum) = AddBiblio($bib, '');
    return ($bibnum, $bibitemnum);
}
