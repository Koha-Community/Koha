package KohaTest::Items::GetItemsForInventory;
use base qw( KohaTest::Items );

use strict;
use warnings;

use Test::More;

use C4::Items;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head2 startup_90_add_item_get_callnumber

=cut

sub startup_90_add_item_get_callnumber : Test( startup => 13 ) {
    my $self = shift;

    $self->add_biblios( add_items => 1 );

    ok( $self->{'biblios'}, 'An item has been aded' )
      or diag( Data::Dumper->Dump( [ $self->{'biblios'} ], ['biblios'] ) );

    my @biblioitems = C4::Biblio::GetBiblioItemByBiblioNumber( $self->{'biblios'}[0] );
    ok( $biblioitems[0]->{'biblioitemnumber'}, '...and it has a biblioitemnumber' )
      or diag( Data::Dumper->Dump( [ \@biblioitems ], ['biblioitems'] ) );

    my $items_info = GetItemsByBiblioitemnumber( $biblioitems[0]->{'biblioitemnumber'} );
    isa_ok( $items_info, 'ARRAY', '...and we can search with that biblioitemnumber' )
      or diag( Data::Dumper->Dump( [$items_info], ['items_info'] ) );
    cmp_ok( scalar @$items_info, '>', 0, '...and we can find at least one item with that biblioitemnumber' );

    my $item_info = $items_info->[0];
    ok( $item_info->{'itemcallnumber'}, '...and the item we found has a call number: ' . $item_info->{'itemcallnumber'} )
      or diag( Data::Dumper->Dump( [$item_info], ['item_info'] ) );

    $self->{'callnumber'} = $item_info->{'itemcallnumber'};
}


=head2 TEST METHODS

standard test methods

=head3 missing_parameters

the minlocation and maxlocation parameters are required. If they are
not provided, this method should somehow complain, such as returning
undef or emitina warning or something.

=cut

sub missing_parameters : Test( 1 ) {
    my $self = shift;
    local $TODO = 'GetItemsForInventory should fail when missing required parameters';

    my $items = C4::Items::GetItemsForInventory();
    ok( not $items, 'GetItemsForInventory fails when parameters are missing' )
      or diag( Data::Dumper->Dump( [ $items ], [ 'items' ] ) );
}

=head3 basic_usage


=cut

sub basic_usage : Test( 4 ) {
    my $self = shift;

    ok( $self->{'callnumber'}, 'we have a call number to search for: ' . $self->{'callnumber'} );
    my $items = C4::Items::GetItemsForInventory( $self->{'callnumber'}, $self->{'callnumber'} );
    isa_ok( $items, 'ARRAY', 'We were able to call GetItemsForInventory with our call number' );
    is( scalar @$items, 1, '...and we found only one item' );
    my $our_item = $items->[0];
    is( $our_item->{'itemnumber'},     $self->{'biblios'}[0],                 '...and the item we found has the right itemnumber' );

    diag( Data::Dumper->Dump( [$items], ['items'] ) );
}

=head3 date_last_seen


=cut

sub date_last_seen : Test( 6 ) {
    my $self = shift;

    ok( $self->{'callnumber'}, 'we have a call number to search for: ' . $self->{'callnumber'} );

    my $items = C4::Items::GetItemsForInventory(
        $self->{'callnumber'},    # minlocation
        $self->{'callnumber'},    # maxlocation
        undef,                    # location
        undef,                    # itemtype
        C4::Dates->new( $self->tomorrow(), 'iso' )->output,    # datelastseen
    );

    isa_ok( $items, 'ARRAY', 'We were able to call GetItemsForInventory with our call number' );
    is( scalar @$items, 1, '...and we found only one item' );
    my $our_item = $items->[0];
    is( $our_item->{'itemnumber'}, $self->{'biblios'}[0], '...and the item we found has the right itemnumber' );

    # give a datelastseen of yesterday, and we should not get our item.
    $items = C4::Items::GetItemsForInventory(
        $self->{'callnumber'},    # minlocation
        $self->{'callnumber'},    # maxlocation
        undef,                    # location
        undef,                    # itemtype
        C4::Dates->new( $self->yesterday(), 'iso' )->output,    # datelastseen
    );

    isa_ok( $items, 'ARRAY', 'We were able to call GetItemsForInventory with our call number' );
    is( scalar @$items, 0, '...and we found no items' );

}


1;
