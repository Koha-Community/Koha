package KohaTest::ImportBatch::GetImportRecordMarc;
use base qw( KohaTest::ImportBatch );

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
use C4::Biblio;


=head3 record_does_not_exist

=cut

sub record_does_not_exist : Test( 1 ) {
    my $self = shift;

    my $id = '999999999999';
    my $marc = GetImportRecordMarc( $id );
    ok( ! defined( $marc ), 'this marc is undefined' );

}

sub record_does_exist : Test( 4 ) {
    my $self = shift;

    # we need an import_batch, so let GetZ3950BatchId create one:
    my $new_batch_id = GetZ3950BatchId('foo');
    ok( $new_batch_id, "got a new batch ID: $new_batch_id" );

    my $sth = C4::Context->dbh->prepare(
        "INSERT INTO import_records (import_batch_id, marc, marcxml)
                                    VALUES (?, ?, ?)"
    );
    my $execute = $sth->execute(
        $new_batch_id,    # batch_id
        'marc',           # marc
        'marcxml',        # marcxml
    );
    ok( $execute, 'succesfully executed' );
    my $import_record_id = C4::Context->dbh->{'mysql_insertid'};
    ok( $import_record_id, 'we got an import_record_id' );

    my $marc = GetImportRecordMarc($import_record_id);
    ok( defined($marc), 'this marc is defined' );
}

1;
