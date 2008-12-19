package KohaTest::ImportBatch::getImportBatch;
use base qw( KohaTest::ImportBatch );

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
use C4::Biblio;


=head3 add_one_and_find_it

=cut

sub add_one_and_find_it : Test( 7 ) {
    my $self = shift;

    my $batch = {
        overlay_action => 'create_new',
        import_status  => 'staging',
        batch_type     => 'batch',
        file_name      => 'foo',
        comments       => 'inserted during automated testing',
    };
    my $batch_id = AddImportBatch(
      $batch->{'overlay_action'},
      $batch->{'import_status'},
      $batch->{'batch_type'},
      $batch->{'file_name'},
      $batch->{'comments'},
    );
    ok( $batch_id, "successfully inserted batch: $batch_id" );

    my $retrieved = GetImportBatch( $batch_id );

    foreach my $key ( keys %$batch ) {
        is( $retrieved->{$key}, $batch->{$key}, "both objects agree on $key" );
    }
    is( $retrieved->{'import_batch_id'}, $batch_id, 'batch_id' );
}

1;
