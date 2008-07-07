package KohaTest::Items;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Items;
sub testing_class { 'C4::Items' }

sub methods : Test( 1 ) {
    my $self    = shift;
    my @methods = qw(

      GetItem
      AddItemFromMarc
      AddItem
      AddItemBatchFromMarc
      ModItemFromMarc
      ModItem
      ModItemTransfer
      ModDateLastSeen
      DelItem
      CheckItemPreSave
      GetItemStatus
      GetItemLocation
      GetLostItems
      GetItemsForInventory
      GetItemsCount
      GetItemInfosOf
      GetItemsByBiblioitemnumber
      GetItemsInfo
      get_itemnumbers_of
      GetItemnumberFromBarcode
      get_item_authorised_values
      get_authorised_value_images
      GetMarcItem
      _set_derived_columns_for_add
      _set_derived_columns_for_mod
      _do_column_fixes_for_mod
      _get_single_item_column
      _calc_items_cn_sort
      _set_defaults_for_add
      _koha_new_item
      _koha_modify_item
      _koha_delete_item
      _marc_from_item_hash
      _add_item_field_to_biblio
      _replace_item_field_in_biblio
      _repack_item_errors
      _get_unlinked_item_subfields
      _get_unlinked_subfields_xml
      _parse_unlinked_item_subfields_from_xml
    );

    can_ok( $self->testing_class, @methods );
}

1;
