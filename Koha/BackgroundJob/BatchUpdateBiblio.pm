package Koha::BackgroundJob::BatchUpdateBiblio;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Biblios;
use Koha::Virtualshelves;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;

use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::MarcModificationTemplates;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchUpdateBiblio - Batch update bibliographic records

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: batch_biblio_record_modification

=cut

sub job_type {
    return 'batch_biblio_record_modification';
}

=head3 process

Process the modification.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    # FIXME If the job has already been started, but started again (worker has been restart for instance)
    # Then we will start from scratch and so double process the same records

    $self->start;

    my $mmtid      = $args->{mmtid};
    my @record_ids = @{ $args->{record_ids} };

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };
    my @messages;
RECORD_IDS: for my $biblionumber ( sort { $a <=> $b } @record_ids ) {

        last if $self->get_from_storage->status eq 'cancelled';

        next unless $biblionumber;

        # Modify the biblio
        my $error = eval {
            my $biblio = Koha::Biblios->find($biblionumber);
            my $record = $biblio->metadata->record;
            C4::MarcModificationTemplates::ModifyRecordWithTemplate( $mmtid, $record );
            my $frameworkcode = C4::Biblio::GetFrameworkCode($biblionumber);

            if ( marc_record_contains_item_data($record) ) {
                my ( $can_add_item, $add_item_error_message ) = can_add_item_from_marc_record($record);
                return $add_item_error_message unless $can_add_item;

                my $biblioitemnumber = $biblio->biblioitem->biblioitemnumber;
                C4::Items::AddItemFromMarc( $record, $biblionumber, { biblioitemnumber => $biblioitemnumber } );
            }

            C4::Biblio::ModBiblio(
                $record,
                $biblionumber,
                $frameworkcode,
                {
                    overlay_context   => $args->{overlay_context},
                    skip_record_index => 1,
                }
            );
        };
        if ( $error and $error != 1 or $@ ) {    # ModBiblio returns 1 if everything as gone well
            push @messages, {
                type         => 'error',
                code         => 'biblio_not_modified',
                biblionumber => $biblionumber,
                error        => ( $@ ? "$@" : $error ),
            };
        } else {
            push @messages, {
                type         => 'success',
                code         => 'biblio_modified',
                biblionumber => $biblionumber,
            };
            $report->{total_success}++;
        }

        $self->step;
    }

    my $indexer = Koha::SearchEngine::Indexer->new( { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
    $indexer->index_records( \@record_ids, "specialUpdate", "biblioserver" );

    my $data = $self->decoded_data;
    $data->{messages} = \@messages;
    $data->{report}   = $report;

    $self->finish($data);
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    # TODO Raise exception instead
    return unless exists $args->{mmtid};
    return unless exists $args->{record_ids};

    $self->SUPER::enqueue(
        {
            job_size  => scalar @{ $args->{record_ids} },
            job_args  => $args,
            job_queue => 'long_tasks',
        }
    );
}

=head3 additional_report

Pass the list of lists/virtual shelves the logged in user has write permissions.

It will enable the "add modified records to list" feature.

=cut

sub additional_report {
    my ($self) = @_;

    my $loggedinuser = C4::Context->userenv ? C4::Context->userenv->{'number'} : undef;
    return {
        lists => Koha::Virtualshelves->search(
            [
                { public => 0, owner => $loggedinuser },
                { public => 1 }
            ]
        ),
    };
}

=head3 marc_record_contains_item_data

Verify if MARC record contains item data

=cut

sub marc_record_contains_item_data {
    my ($record) = @_;

    my $itemfield   = C4::Context->preference('marcflavour') eq 'UNIMARC' ? '995' : '952';
    my @item_fields = $record->field($itemfield);
    return scalar @item_fields;
}

=head3 can_add_item_from_marc_record

Checks if adding an item from MARC can be done by checking mandatory fields

=cut

sub can_add_item_from_marc_record {
    my ($record) = @_;

    # Check that holdingbranch is set
    my $holdingbranch_mss = Koha::MarcSubfieldStructures->find(
        {
            frameworkcode => '',
            kohafield     => 'items.holdingbranch',
        }
    );
    my @holdingbranch_exists =
        grep { $_->subfield( $holdingbranch_mss->tagsubfield ) } $record->field( $holdingbranch_mss->tagfield );
    return ( 0, "No holdingbranch subfield found" ) unless ( scalar @holdingbranch_exists );

    # Check that homebranch is set
    my $homebranch_mss = Koha::MarcSubfieldStructures->find(
        {
            frameworkcode => '',
            kohafield     => 'items.homebranch',
        }
    );
    my @homebranch_exists =
        grep { $_->subfield( $homebranch_mss->tagsubfield ) } $record->field( $homebranch_mss->tagfield );
    return ( 0, "No homebranch subfield found" ) unless ( scalar @homebranch_exists );

    # Check that itemtype is set
    my $item_mss = Koha::MarcSubfieldStructures->find(
        {
            frameworkcode => '',
            kohafield     => C4::Context->preference('item-level_itypes') ? 'items.itype' : 'biblioitems.itemtype',
        }
    );
    my @itemtype_exists = grep { $_->subfield( $item_mss->tagsubfield ) } $record->field( $item_mss->tagfield );
    return ( 0, "No itemtype subfield found" ) unless ( scalar @itemtype_exists );

    return 1;
}

1;
