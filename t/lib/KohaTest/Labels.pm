package KohaTest::Labels;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Labels;
sub testing_class { 'C4::Labels' }

sub methods : Test( 1 ) {
    my $self    = shift;
    my @methods = qw(

      get_label_options
      get_layouts
      get_layout
      get_active_layout
      delete_layout
      get_printingtypes
      build_text_dropbox
      get_text_fields
      add_batch
      get_highest_batch
      get_batches
      delete_batch
      get_barcode_types
      GetUnitsValue
      GetTextWrapCols
      GetActiveLabelTemplate
      GetSingleLabelTemplate
      SetActiveTemplate
      set_active_layout
      DeleteTemplate
      SaveTemplate
      CreateTemplate
      GetAllLabelTemplates
      add_layout
      save_layout
      GetAllPrinterProfiles
      GetSinglePrinterProfile
      SaveProfile
      CreateProfile
      DeleteProfile
      GetAssociatedProfile
      SetAssociatedProfile
      GetLabelItems
      GetItemFields
      GetBarcodeData
      _descKohaTables
      GetPatronCardItems
      deduplicate_batch
      DrawSpineText
      PrintText
      DrawPatronCardText
      DrawBarcode
      build_circ_barcode
      draw_boundaries
      drawbox
    );

    can_ok( $self->testing_class, @methods );
}

1;
