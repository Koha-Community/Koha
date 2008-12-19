package KohaTest::ImportBatch::GetZ3950BatchId;
use base qw( KohaTest::ImportBatch );

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
use C4::Biblio;


=head3 batch_does_not_exist

=cut

sub batch_does_not_exist : Test( 5 ) {
    my $self = shift;

    my $file_name = 'testing batch';

    # lets make sure it doesn't exist first
    my $sth = C4::Context->dbh->prepare('SELECT import_batch_id FROM import_batches
                                         WHERE  batch_type = ?
                                         AND    file_name = ?');
    ok( $sth->execute( 'z3950', $file_name, ), 'execute' );
    my $rowref = $sth->fetchrow_arrayref();
    ok( !defined( $rowref ), 'this batch does not exist' );

    # now let GetZ3950BatchId create one
    my $new_batch_id = GetZ3950BatchId( $file_name );
    ok( $new_batch_id, "got a new batch ID: $new_batch_id" );

    # now search for the one that was just created
    my $second_batch_id = GetZ3950BatchId( $file_name );
    ok( $second_batch_id, "got a second batch ID: $second_batch_id" );
    is( $second_batch_id, $new_batch_id, 'we got the same batch both times.' );
}


1;
