package KohaTest::ImportBatch::AddImportBatch;
use base qw( KohaTest::ImportBatch );

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
use C4::Biblio;


=head3 add_one

=cut

sub add_one : Test( 1 ) {
    my $self = shift;

    my $batch_id = AddImportBatch(
        'create_new',                           #overlay_action
        'staging',                              # import_status
        'batch',                                # batc_type
        'foo',                                  # file_name
        'inserted during automated testing',    # comments
    );
    ok( $batch_id, "successfully inserted batch: $batch_id" );
}

1;
