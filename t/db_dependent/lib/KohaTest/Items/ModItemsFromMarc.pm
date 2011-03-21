package KohaTest::Items::ModItemsFromMarc;
use base qw( KohaTest::Items );

use strict;
use warnings;

use Test::More;

use C4::Context;
use C4::Biblio;
use C4::Items;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head2 startup_90_add_item_get_callnumber

=cut

sub startup_90_add_item_get_callnumber : Test( startup => 13 ) {
    my $self = shift;

    $self->add_biblios( count => 1, add_items => 1 );

    ok( $self->{'items'}, 'An item has been aded' )
      or diag( Data::Dumper->Dump( [ $self->{'items'} ], ['items'] ) );

    my @biblioitems = C4::Biblio::GetBiblioItemByBiblioNumber( $self->{'items'}[0]{'biblionumber'} );
    ok( $biblioitems[0]->{'biblioitemnumber'}, '...and it has a biblioitemnumber' )
      or diag( Data::Dumper->Dump( [ \@biblioitems ], ['biblioitems'] ) );

    my $items_info = GetItemsByBiblioitemnumber( $biblioitems[0]->{'biblioitemnumber'} );
    isa_ok( $items_info, 'ARRAY', '...and we can search with that biblioitemnumber' )
      or diag( Data::Dumper->Dump( [$items_info], ['items_info'] ) );
    cmp_ok( scalar @$items_info, '>', 0, '...and we can find at least one item with that biblioitemnumber' );

    my $item_info = $items_info->[0];
    ok( $item_info->{'itemcallnumber'}, '...and the item we found has a call number: ' . $item_info->{'itemcallnumber'} )
      or diag( Data::Dumper->Dump( [$item_info], ['item_info'] ) );

    $self->{itemnumber} = $item_info->{itemnumber};
}


=head2 TEST METHODS

standard test methods

=head3 bug2466

Regression test for bug 2466 (when clearing an item field
via the cataloging or serials item editor, corresponding
column is not cleared).

=cut

sub bug2466 : Test( 8 ) {
    my $self = shift;

    my $item = C4::Items::GetItem($self->{itemnumber});
    isa_ok($item, 'HASH', "item $self->{itemnumber} exists");
   
    my $item_marc = C4::Items::GetMarcItem($item->{biblionumber}, $self->{itemnumber});
    isa_ok($item_marc, 'MARC::Record', "retrieved item MARC");

    cmp_ok($item->{itemcallnumber}, 'ne', '', "item call number is not blank");

    my ($callnum_tag, $callnum_subfield) = C4::Biblio::GetMarcFromKohaField('items.itemcallnumber', '');
    cmp_ok($callnum_tag, '>', 0, "found tag for itemcallnumber");

    my $item_field = $item_marc->field($callnum_tag);
    ok(defined($item_field), "retrieved MARC field for item");

    $item_field->delete_subfield(code => $callnum_subfield);

    my $dbh = C4::Context->dbh;
    my $item_from_marc = C4::Biblio::TransformMarcToKoha($dbh, $item_marc, '', 'items');
    ok(not(exists($item_from_marc->{itemcallnumber})), "itemcallnumber subfield removed");

    C4::Items::ModItemFromMarc($item_marc, $item->{biblionumber}, $self->{itemnumber});

    my $modified_item = C4::Items::GetItem($self->{itemnumber});
    isa_ok($modified_item, 'HASH', "retrieved modified item");

    ok(not(defined($modified_item->{itemcallnumber})), "itemcallnumber is now undef");
}

1;
