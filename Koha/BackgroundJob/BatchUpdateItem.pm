package Koha::BackgroundJob::BatchUpdateItem;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use List::MoreUtils qw( uniq );
use Try::Tiny;

use MARC::Record;
use MARC::Field;

use C4::Biblio;
use C4::Items;

use Koha::DateUtils qw( dt_from_string );
use Koha::SearchEngine::Indexer;
use Koha::Items;
use Koha::UI::Table::Builder::Items;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchUpdateItem - Background job derived class to process item modification in batch

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: batch_item_record_modification

=cut

sub job_type {
    return 'batch_item_record_modification';
}

=head3 process

    Koha::BackgroundJobs->find($id)->process(
        {
            record_ids => \@itemnumbers,
            new_values => {
                itemnotes => $new_item_notes,
                k         => $k,
            },
            regex_mod => {
                itemnotes_nonpublic => {
                    search => 'foo',
                    replace => 'bar',
                    modifiers => 'gi',
                },
            },
            exclude_from_local_holds_priority => 1|0
        }
    );

Process the modification.

new_values allows to set a new value for given fields.
The key can be one of the item's column name, or one subfieldcode of a MARC subfields not linked with a Koha field.

regex_mod allows to modify existing subfield's values using a regular expression.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    # FIXME If the job has already been started, but started again (worker has been restart for instance)
    # Then we will start from scratch and so double process the same records

    $self->start;

    my @record_ids = @{ $args->{record_ids} };
    my $regex_mod  = $args->{regex_mod};
    my $new_values = $args->{new_values};
    my $exclude_from_local_holds_priority =
      $args->{exclude_from_local_holds_priority};
    my $mark_items_returned =
      $args->{mark_items_returned};

    my $report = {
        total_records            => scalar @record_ids,
        modified_fields          => 0,
    };

    try {
        my ($results) = Koha::Items->search( { itemnumber => \@record_ids } )->batch_update(
            {   regex_mod                         => $regex_mod,
                new_values                        => $new_values,
                exclude_from_local_holds_priority => $exclude_from_local_holds_priority,
                mark_items_returned               => $mark_items_returned,
                callback                          => sub { $self->step; },
            }
        );
        $report->{modified_itemnumbers} = $results->{modified_itemnumbers};
        $report->{modified_fields}      = $results->{modified_fields};
    }
    catch {
        warn $_;
        die "Something terrible has happened!"
          if ( $_ =~ /Rollback failed/ );    # Rollback failed
    };

    my $data = $self->decoded_data;
    $data->{report} = $report;

    $self->finish( $data );
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    # TODO Raise exception instead
    return unless exists $args->{record_ids};

    my @record_ids = @{ $args->{record_ids} };

    $self->SUPER::enqueue(
        {
            job_size  => scalar @record_ids,
            job_args  => {%$args},
            job_queue => 'long_tasks',
        }
    );
}

=head3 additional_report

Sent the infos to generate the table containing the details of the modified items.

=cut

sub additional_report {
    my ( $self, $args ) = @_;

    return unless $self->report->{modified_itemnumbers};

    my $itemnumbers = $self->report->{modified_itemnumbers};
    if ( scalar(@$itemnumbers) > C4::Context->preference('MaxItemsToDisplayForBatchMod') ) {
        return { too_many_items_display => 1 };
    } else {
        my $items_table =
          Koha::UI::Table::Builder::Items->new( { itemnumbers => $itemnumbers } )
          ->build_table;

        return {
            items            => $items_table->{items},
            item_header_loop => $items_table->{headers},
        };
    }
}

1;
