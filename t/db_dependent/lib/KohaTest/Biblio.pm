package KohaTest::Biblio;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Biblio;
sub testing_class { 'C4::Biblio' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw(
                       AddBiblio
                       ModBiblio
                       ModBiblioframework
                       DelBiblio
                       LinkBibHeadingsToAuthorities
                       GetBiblioData
                       GetBiblioItemData
                       GetBiblioItemByBiblioNumber
                       GetBiblioFromItemNumber
                       GetBiblio
                       GetBiblioItemInfosOf
                       GetMarcStructure
                       GetUsedMarcStructure
                       GetMarcFromKohaField
                       GetMarcBiblio
                       GetXmlBiblio
                       GetAuthorisedValueDesc
                       GetMarcNotes
                       GetMarcSubjects
                       GetMarcAuthors
                       GetMarcUrls
                       GetMarcSeries
                       GetFrameworkCode
                       GetPublisherNameFromIsbn
                       TransformKohaToMarc
                       TransformKohaToMarcOneField
                       TransformHtmlToXml
                       TransformHtmlToMarc
                       TransformMarcToKoha
                       _get_inverted_marc_field_map
                       _disambiguate
                       get_koha_field_from_marc
                       TransformMarcToKohaOneField
                       PrepareItemrecordDisplay
                       ModZebra
                       GetNoZebraIndexes
                       _DelBiblioNoZebra
                       _AddBiblioNoZebra
                       _find_value
                       _koha_marc_update_bib_ids
                       _koha_marc_update_biblioitem_cn_sort
                       _koha_add_biblio
                       _koha_modify_biblio
                       _koha_modify_biblioitem_nonmarc
                       _koha_add_biblioitem
                       _koha_delete_biblio
                       _koha_delete_biblioitems
                       ModBiblioMarc
                       z3950_extended_services
                       set_service_options
                       get_biblio_authorised_values
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

