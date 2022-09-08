package Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;

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

use Try::Tiny;

use Koha::Biblios;
use Koha::Exceptions;

use C4::HoldsQueue
  qw(load_branches_to_pull_from TransportCostMatrix update_queue_for_biblio);

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue - Update the holds queue
for a specified list of biblios.

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Returns a string representing the job type. In this case I<update_holds_queue_for_biblios>.

=cut

sub job_type {
    return 'update_holds_queue_for_biblios';
}

=head3 process

Perform the expected action.

=cut

sub process {
    my ( $self, $args ) = @_;

    my $schema = Koha::Database->new->schema;

    $self->start;

    my @biblio_ids = @{ $args->{biblio_ids} };

    my $report = {
        total_biblios => scalar @biblio_ids,
        total_success => 0,
    };

    my $use_transport_cost_matrix = C4::Context->preference("UseTransportCostMatrix");
    my $transport_cost_matrix = $use_transport_cost_matrix ? TransportCostMatrix() : undef;
    my $branches_to_use = load_branches_to_pull_from($use_transport_cost_matrix);

    my @messages;

    foreach my $biblio_id (@biblio_ids) {
        try {

            $schema->storage->txn_begin;

            my $result = update_queue_for_biblio(
                {
                    biblio_id             => $biblio_id,
                    branches_to_use       => $branches_to_use,
                    delete                => 1,
                    transport_cost_matrix => $transport_cost_matrix
                }
            );
            push @messages,
              {
                type           => 'success',
                code           => 'holds_queue_updated',
                biblio_id      => $biblio_id,
              };
            $report->{total_success}++;

            $schema->storage->txn_commit;
        }
        catch {

            push @messages,
              {
                type      => 'error',
                code      => 'holds_queue_update_error',
                biblio_id => $biblio_id,
                error     => "$_",
              };

            $schema->storage->txn_rollback;
        };

        $self->step;
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
    my ( $self, $args ) = @_;

    Koha::Exceptions::MissingParameter->throw(
        "Missing biblio_ids parameter is mandatory")
      unless exists $args->{biblio_ids};

    my @biblio_ids = @{ $args->{biblio_ids} };

    $self->SUPER::enqueue(
        {
            job_size => scalar @biblio_ids,
            job_args => { biblio_ids => \@biblio_ids }
        }
    );
}

=head3 additional_report

Pass the biblio's title and patron's name

=cut

sub additional_report {
    my ( $self, $args ) = @_;

    my $messages = $self->messages;
    for my $m (@$messages) {
        $m->{biblio} = Koha::Biblios->find( $m->{biblio_id} );
    }
    return { report_messages => $messages };
}

1;
