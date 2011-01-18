package KohaTest::ImportBatch::getImportBatch;
use base qw( KohaTest::ImportBatch );

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
use C4::Biblio;


sub something : Test( 2 ) {
    my $self = shift;

    my $batch_id = $self->add_import_batch();
    ok( $batch_id, 'we have a batch_id' );

    my $import_record_id = 0;

    my $marc_record = MARC::Record->new();
    
    my @import_item_ids = C4::ImportBatch::AddItemsToImportBiblio( $batch_id, $import_record_id, $marc_record );
    is( scalar( @import_item_ids ), 0, 'none inserted' );

}

1;
