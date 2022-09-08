package Koha::BackgroundJob::BatchDeleteBiblio;

use Modern::Perl;

use C4::Biblio;

use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchDeleteBiblio - Batch delete bibliographic records

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: batch_biblio_record_deletion

=cut

sub job_type {
    return 'batch_biblio_record_deletion';
}

=head3 process

Process the job.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    # FIXME If the job has already been started, but started again (worker has been restart for instance)
    # Then we will start from scratch and so double delete the same records

    $self->start;

    my $mmtid = $args->{mmtid};
    my @record_ids = @{ $args->{record_ids} };

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };
    my @messages;
    my $schema = Koha::Database->new->schema;
    RECORD_IDS: for my $record_id ( sort { $a <=> $b } @record_ids ) {

        last if $self->get_from_storage->status eq 'cancelled';

        next unless $record_id;

        $schema->storage->txn_begin;

        my $biblionumber = $record_id;
        # First, checking if issues exist.
        # If yes, nothing to do
        my $biblio = Koha::Biblios->find( $biblionumber );

        # TODO Replace with $biblio->get_issues->count
        if ( C4::Biblio::CountItemsIssued( $biblionumber ) ) {
            push @messages, {
                type => 'warning',
                code => 'item_issued',
                biblionumber => $biblionumber,
            };
            $schema->storage->txn_rollback;

            $self->step;
            next;
        }

        # Cancel reserves
        my $holds = $biblio->holds;
        while ( my $hold = $holds->next ) {
            eval{
                $hold->cancel({ skip_holds_queue => 1 });
            };
            if ( $@ ) {
                push @messages, {
                    type => 'error',
                    code => 'reserve_not_cancelled',
                    biblionumber => $biblionumber,
                    reserve_id => $hold->reserve_id,
                    error => "$@",
                };
                $schema->storage->txn_rollback;

                $self->step;
                next RECORD_IDS;
            }
        }

        # Delete items
        my $items = Koha::Items->search({ biblionumber => $biblionumber });
        while ( my $item = $items->next ) {
            my $deleted = $item->safe_delete({ skip_record_index => 1, skip_holds_queue => 1 });
            unless ( $deleted ) {
                push @messages, {
                    type => 'error',
                    code => 'item_not_deleted',
                    biblionumber => $biblionumber,
                    itemnumber => $item->itemnumber,
                    error => @{$deleted->messages}[0]->message,
                };
                $schema->storage->txn_rollback;

                $self->step;
                next RECORD_IDS;
            }
        }

        # Finally, delete the biblio
        my $error = eval {
            C4::Biblio::DelBiblio( $biblionumber, { skip_record_index => 1, skip_holds_queue => 1 } );
        };
        if ( $error or $@ ) {
            push @messages, {
                type => 'error',
                code => 'biblio_not_deleted',
                biblionumber => $biblionumber,
                error => ($@ ? $@ : $error),
            };
            $schema->storage->txn_rollback;

            $self->step;
            next;
        }

        push @messages, {
            type => 'success',
            code => 'biblio_deleted',
            biblionumber => $biblionumber,
        };
        $report->{total_success}++;
        $schema->storage->txn_commit;

        $self->step;
    }

    my @deleted_biblionumbers =
      map { $_->{code} eq 'biblio_deleted' ? $_->{biblionumber} : () }
          @messages;

    if ( @deleted_biblionumbers ) {
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        $indexer->index_records( \@deleted_biblionumbers, "recordDelete", "biblioserver" );

        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
            {
                biblio_ids => \@deleted_biblionumbers
            }
        ) if C4::Context->preference('RealTimeHoldsQueue');
    }

    my $data = $self->decoded_data;
    $data->{messages} = \@messages;
    $data->{report} = $report;

    $self->finish( $data );
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args) = @_;

    # TODO Raise exception instead
    return unless exists $args->{record_ids};

    my @record_ids = @{ $args->{record_ids} };

    $self->SUPER::enqueue({
        job_size  => scalar @record_ids,
        job_args  => {record_ids => \@record_ids,},
        job_queue => 'long_tasks',
    });
}

1;
