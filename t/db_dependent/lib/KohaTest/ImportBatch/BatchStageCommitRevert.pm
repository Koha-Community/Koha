package KohaTest::ImportBatch::BatchStageCommitRevert;
use base qw( KohaTest::ImportBatch );

use strict;
use warnings;

use Test::More;

use C4::ImportBatch;
use C4::Matcher;
use C4::Biblio;

# define test records for various batches
sub startup_60_make_test_records : Test( startup ) {
    my $self = shift;
    $self->{'batches'} = {
        'batch1' => { 
                        marc => _make_marc_batch([
                            ['isbn001', 'title 1', ['batch-item-1'] ],
                            ['isbn002', 'title 2', [] ],
                            ['isbn003', 'title 3', ['batch-item-2','batch-item-3'] ],
                            ['isbn004', 'title 4', [ 'batch-item-4' ] ],
                            ['isbn005', 'title 5', [ 'batch-item-5', 'batch-item-6', 'batch-item-7' ] ],
                        ]),
                        args => {
                            parse_items => 1,
                            overlay_action => 'create_new',
                            nomatch_action => 'create_new',
                            item_action => 'always_add',
                        },
                        results => {
                            num_bibs  => 5,
                            num_items => 7,
                            num_invalid => 0,
                            num_matches => 0,
                            num_added => 5,
                            num_updated => 0,
                            num_items_added => 7,
                            num_items_errored => 0,
                            num_ignored => 0,
                        },
                    },
        'batch2' => {
                        marc => _make_marc_batch([
                            ['isbn001', 'overlay title 1', ['batch-item-8'] ],
                            ['isbn002', 'overlay title 2', ['batch-item-9'] ],
                            ['isbn006', 'title 6', ['batch-item-10'] ],
                        ]),
                        args => {
                            parse_items => 1,
                            overlay_action => 'replace',
                            nomatch_action => 'create_new',
                            item_action => 'always_add',
                        },
                        results => {
                            num_bibs  => 3,
                            num_items => 3,
                            num_invalid => 0,
                            num_matches => 2,
                            num_added => 1,
                            num_updated => 2,
                            num_items_added => 3,
                            num_items_errored => 0,
                            num_ignored => 0,
                        },
                    },
        'batch3' => {
                        marc => _make_marc_batch([ 
                            ['isbn007', 'title 7', ['batch-item-11'] ],
                            ['isbn006', 'overlay title 6', ['batch-item-12'] ],
                        ]),
                        args => {
                            parse_items => 1,
                            overlay_action => 'ignore',
                            nomatch_action => 'ignore',
                            item_action => 'always_add',
                        },
                        results => {
                            num_bibs  => 2,
                            num_items => 2,
                            num_invalid => 0,
                            num_matches => 1,
                            num_added => 0,
                            num_updated => 0,
                            num_items_added => 1,
                            num_items_errored => 0,
                            num_ignored => 2,
                        },
                    },
        'batch4' => {
                        marc => _make_marc_batch([ 
                            ['isbn008', 'title 8', ['batch-item-13'] ], # not loading this item
                        ]),
                        args => {
                            parse_items => 0,
                            overlay_action => undef,
                            nomatch_action => 'create_new',
                            item_action => 'ignore',
                        },
                        results => {
                            num_bibs  => 1,
                            num_items => 0,
                            num_invalid => 0,
                            num_matches => 0,
                            num_added => 1,
                            num_updated => 0,
                            num_items_added => 0,
                            num_items_errored => 0,
                            num_ignored => 0,
                        },
                    },
        'batch5' => {
                        marc => _make_marc_batch([ 
                            ['isbn009', 'title 9', ['batch-item-1'] ], # trigger dup barcode error
                            'junkjunkjunkjunk', # trigger invalid bib
                        ]),
                        args => {
                            parse_items => 1,
                            overlay_action => undef,
                            nomatch_action => undef,
                            item_action => undef,
                        },
                        results => {
                            num_bibs  => 1,
                            num_items => 1,
                            num_invalid => 1,
                            num_matches => 0,
                            num_added => 1,
                            num_updated => 0,
                            num_items_added => 0,
                            num_items_errored => 1,
                            num_ignored => 0,
                        },
                    },
        'batch6' => {
                        marc => _make_marc_batch([ 
                            ['isbn001', 'match title 1', ['batch-item-14', 'batch-item-15'] ],
                            ['isbn010', 'title 10', ['batch-item-16', 'batch-item-17'] ],
                        ]),
                        args => {
                            parse_items => 1,
                            overlay_action => 'ignore',
                            nomatch_action => 'create_new',
                            item_action => 'always_add',
                        },
                        results => {
                            num_bibs  => 2,
                            num_items => 4,
                            num_invalid => 0,
                            num_matches => 1,
                            num_added => 1,
                            num_updated => 0,
                            num_items_added => 4,
                            num_items_errored => 0,
                            num_ignored => 1,
                        },
                    },
    };
    
}

sub _make_marc_batch {
    my $defs = shift;
    my @marc = ();
    foreach my $rec (@$defs) {
        if (ref($rec) eq 'ARRAY') {
            my $isbn = $rec->[0];
            my $title = $rec->[1];
            my $items = $rec->[2];
            my $bib = MARC::Record->new();
            $bib->leader('     nam a22     7a 4500');
            $bib->append_fields(MARC::Field->new('020', ' ', ' ', a => $isbn),
                                MARC::Field->new('245', ' ', ' ', a => $title));
            foreach my $barcode (@$items) {
                my ($itemtag, $toss, $barcodesf, $branchsf);
                ($itemtag, $toss)   = GetMarcFromKohaField('items.itemnumber', '');
                ($toss, $barcodesf) = GetMarcFromKohaField('items.barcode', '');
                ($toss, $branchsf)  = GetMarcFromKohaField('items.homebranch', '');
                $bib->append_fields(MARC::Field->new($itemtag, ' ', ' ', $barcodesf => $barcode, $branchsf => 'CPL')); 
                        # FIXME: define branch in KohaTest
            }
            push @marc, $bib->as_usmarc();
        } else {
            push @marc, $rec;
        }
    }
    return join('', @marc);
}

sub stage_commit_batches : Test( 75 ) {
    my $self = shift;

    my $matcher = C4::Matcher->fetch($self->{'matcher_id'});
    ok(ref($matcher) eq 'C4::Matcher', "retrieved matcher");

    for my $batch_key (sort keys %{ $self->{'batches'} }) {
        my $batch = $self->{'batches'}->{$batch_key};
        my $args = $batch->{'args'};
        my $results = $batch->{'results'};
        my ($batch_id, $num_bibs, $num_items, @invalid) =
            BatchStageMarcRecords('MARC21', $batch->{marc}, "$batch_key.mrc", "$batch_key comments", 
                                  '', $args->{'parse_items'}, 0);
        like($batch_id, qr/^\d+$/, "staged $batch_key");
        cmp_ok($num_bibs, "==", $results->{'num_bibs'}, "$batch_key: correct number of bibs");
        cmp_ok($num_items, "==", $results->{'num_items'}, "$batch_key: correct number of items");
        cmp_ok(scalar(@invalid), "==", $results->{'num_invalid'}, "$batch_key: correct number of invalid bibs");

        my $num_matches = BatchFindBibDuplicates($batch_id, $matcher, 10);
        cmp_ok($num_matches, "==", $results->{'num_matches'}, "$batch_key: correct number of bib matches");

        if (defined $args->{'overlay_action'}) {
            if ($args->{'overlay_action'} eq 'create_new') {
                cmp_ok(GetImportBatchOverlayAction($batch_id), "eq", 'create_new', "$batch_key: verify default overlay action");
            } else {
                SetImportBatchOverlayAction($batch_id, $args->{'overlay_action'});
                cmp_ok(GetImportBatchOverlayAction($batch_id), "eq", $args->{'overlay_action'}, 
                                                   "$batch_key: changed overlay action");
            }
        }
        if (defined $args->{'nomatch_action'}) {
            if ($args->{'nomatch_action'} eq 'create_new') {
                cmp_ok(GetImportBatchNoMatchAction($batch_id), "eq", 'create_new', "$batch_key: verify default nomatch action");
            } else {
                SetImportBatchNoMatchAction($batch_id, $args->{'nomatch_action'});
                cmp_ok(GetImportBatchNoMatchAction($batch_id), "eq", $args->{'nomatch_action'}, 
                                                   "$batch_key: changed nomatch action");
            }
        }
        if (defined $args->{'item_action'}) {
            if ($args->{'item_action'} eq 'create_new') {
                cmp_ok(GetImportBatchItemAction($batch_id), "eq", 'always_add', "$batch_key: verify default item action");
            } else {
                SetImportBatchItemAction($batch_id, $args->{'item_action'});
                cmp_ok(GetImportBatchItemAction($batch_id), "eq", $args->{'item_action'}, 
                                                   "$batch_key: changed item action");
            }
        }

        my ($num_added, $num_updated, $num_items_added, 
            $num_items_errored, $num_ignored) = BatchCommitBibRecords($batch_id);
        cmp_ok($num_added,         "==", $results->{'num_added'},         "$batch_key: added correct number of bibs");
        cmp_ok($num_updated,       "==", $results->{'num_updated'},       "$batch_key: updated correct number of bibs");
        cmp_ok($num_items_added,   "==", $results->{'num_items_added'},   "$batch_key: added correct number of items");
        cmp_ok($num_items_errored, "==", $results->{'num_items_errored'}, "$batch_key: correct number of item add errors");
        cmp_ok($num_ignored,       "==", $results->{'num_ignored'},       "$batch_key: ignored correct number of bibs");

        $self->reindex_marc();
    }
     
}

1;
