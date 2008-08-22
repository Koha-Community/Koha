package KohaTest::Koha;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Koha;
sub testing_class { 'C4::Koha' }

sub methods : Test( 1 ) {
    my $self    = shift;
    my @methods = qw( slashifyDate
      DisplayISBN
      subfield_is_koha_internal_p
      GetItemTypes
      get_itemtypeinfos_of
      GetCcodes
      getauthtypes
      getauthtype
      getframeworks
      getframeworkinfo
      getitemtypeinfo
      getitemtypeimagedir
      getitemtypeimagesrc
      getitemtypeimagelocation
      _getImagesFromDirectory
      _getSubdirectoryNames
      getImageSets
      GetPrinters
      GetPrinter
      getnbpages
      getallthemes
      getFacets
      get_infos_of
      get_notforloan_label_of
      displayServers
      displaySecondaryServers
      GetAuthValCode
      GetAuthorisedValues
      GetAuthorisedValueCategories
      GetKohaAuthorisedValues
      GetManagedTagSubfields
      display_marc_indicators
    );

    can_ok( $self->testing_class, @methods );
}

1;
