package KohaTest::ImportBatch;
use base qw(KohaTest);

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
sub testing_class { 'C4::ImportBatch' };


sub routines : Test( 1 ) {
    my $self = shift;
    my @routines = qw(
                        GetZ3950BatchId
                        GetImportRecordMarc
                        AddImportBatch
                        GetImportBatch
                        AddBiblioToBatch
                        ModBiblioInBatch
                        BatchStageMarcRecords
                        AddItemsToImportBiblio
                        BatchFindBibDuplicates
                        BatchCommitBibRecords
                        BatchCommitItems
                        BatchRevertBibRecords
                        BatchRevertItems
                        CleanBatch
                        GetAllImportBatches
                        GetImportBatchRangeDesc
                        GetItemNumbersFromImportBatch
                        GetNumberOfNonZ3950ImportBatches
                        GetImportBibliosRange
                        GetBestRecordMatch
                        GetImportBatchStatus
                        SetImportBatchStatus
                        GetImportBatchOverlayAction
                        SetImportBatchOverlayAction
                        GetImportBatchNoMatchAction
                        SetImportBatchNoMatchAction
                        GetImportBatchItemAction
                        SetImportBatchItemAction
                        GetImportBatchItemAction
                        SetImportBatchItemAction
                        GetImportBatchMatcher
                        SetImportBatchMatcher
                        GetImportRecordOverlayStatus
                        SetImportRecordOverlayStatus
                        GetImportRecordStatus
                        SetImportRecordStatus
                        GetImportRecordMatches
                        SetImportRecordMatches
                        _create_import_record
                        _update_import_record_marc
                        _add_biblio_fields
                        _update_biblio_fields
                        _parse_biblio_fields
                        _update_batch_record_counts
                        _get_commit_action
                        _get_revert_action
                );
    
    can_ok($self->testing_class, @routines);
}

sub startup_50_add_matcher : Test( startup => 1 ) {
    my $self = shift;
    # create test MARC21 ISBN matcher
    my $matcher = C4::Matcher->new('biblio');
    $matcher->threshold(1000);
    $matcher->code('TESTISBN');
    $matcher->description('test MARC21 ISBN matcher');
    $matcher->add_simple_matchpoint('isbn', 1000, '020', 'a', -1, 0, '');
    my $matcher_id = $matcher->store();
    like($matcher_id, qr/^\d+$/, "store new matcher and get back ID");

    $self->{'matcher_id'} = $matcher_id;
}

sub shutdown_50_remove_matcher : Test( shutdown => 6) {
    my $self = shift;
    my @matchers = C4::Matcher::GetMatcherList();
    cmp_ok(scalar(@matchers), ">=", 1, "at least one matcher present");
    my $matcher_id;
    my $testisbn_count = 0;
    # look for TESTISBN
    foreach my $matcher (@matchers) {
        if ($matcher->{'code'} eq 'TESTISBN') {
            $testisbn_count++;
            $matcher_id = $matcher->{'matcher_id'};
        }
    }
    ok($testisbn_count == 1, "only one TESTISBN matcher");
    like($matcher_id, qr/^\d+$/, "matcher ID is valid");
    my $matcher = C4::Matcher->fetch($matcher_id);
    ok(defined($matcher), "got back a matcher");
    ok($matcher_id == $matcher->{'id'}, "got back the correct matcher");
    C4::Matcher->delete($matcher_id);
    my $matcher2 = C4::Matcher->fetch($matcher_id);
    ok(not(defined($matcher2)), "matcher removed");

    delete $self->{'matcher_id'};
}

=head2 UTILITY METHODS

=cut

sub add_import_batch {
    my $self       = shift;
    my $test_batch = shift
      || {
        overlay_action => 'create_new',
        import_status  => 'staging',
        batch_type     => 'batch',
        file_name      => 'foo',
        comments       => 'inserted during automated testing',
      };
    my $batch_id = AddImportBatch( $test_batch->{'overlay_action'},
                                   $test_batch->{'import_status'},
                                   $test_batch->{'batch_type'},
                                   $test_batch->{'file_name'},
                                   $test_batch->{'comments'}, );
    return $batch_id;
}


1;
