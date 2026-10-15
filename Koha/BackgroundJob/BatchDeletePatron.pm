package Koha::BackgroundJob::BatchDeletePatron;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::BackgroundJob::BatchDeletePatron - Background job derived class to process patron deletion in batch

=cut

use Modern::Perl;

use Try::Tiny;

use Koha::Database;
use Koha::Patrons;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchDeletePatron - Background job for batch deleting patrons

=head1 API

=head2 Class methods

=head3 job_type

Return the job type 'batch_patron_deletion'.

=cut

sub job_type {
    return 'batch_patron_deletion';
}

=head3 process

    Koha::BackgroundJobs->find($id)->process(
        {
            record_ids      => \@borrowernumbers,
            move_to_deleted => 0|1,
        }
    );

Process all the patrons that have been passed for deletion.

=cut

sub process {
    my ( $self, $args ) = @_;

    return if $self->status eq 'cancelled';

    $self->start;

    my @record_ids      = @{ $args->{record_ids} };
    my $move_to_deleted = $args->{move_to_deleted};

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };
    my @messages;
    my ( @deleted_borrowernumbers, @not_deleted_borrowernumbers );

    my $schema = Koha::Database->new->schema;

    for my $borrowernumber (@record_ids) {

        last if $self->get_from_storage->status eq 'cancelled';

        my $patron = Koha::Patrons->find($borrowernumber) || next;

        my $cardnumber = $patron->cardnumber;

        try {
            $schema->txn_do(
                sub {
                    $patron->move_to_deleted if $move_to_deleted;
                    $patron->delete;
                }
            );

            push @deleted_borrowernumbers, $borrowernumber;
            $report->{total_success}++;
        } catch {
            push @not_deleted_borrowernumbers, $borrowernumber;
            push @messages, {
                type           => 'error',
                code           => 'patron_not_deleted',
                borrowernumber => $borrowernumber,
                cardnumber     => $cardnumber,
                reason         => ref($_) ? $_->message : $_,
            };
        };

        $self->step;
    }

    $report->{deleted_borrowernumbers}     = \@deleted_borrowernumbers;
    $report->{not_deleted_borrowernumbers} = \@not_deleted_borrowernumbers;

    my $data = $self->decoded_data;
    $data->{messages} = \@messages;
    $data->{report}   = $report;

    $self->finish($data);
}

=head3 enqueue

Enqueue the job.

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    # TODO Raise exception instead
    return
        unless exists $args->{record_ids}
        && @{ $args->{record_ids} };

    my @record_ids      = @{ $args->{record_ids} };
    my $move_to_deleted = $args->{move_to_deleted} || 0;

    $self->SUPER::enqueue(
        {
            job_size => scalar @record_ids,
            job_args => {
                record_ids      => \@record_ids,
                move_to_deleted => $move_to_deleted,
            },
            job_queue => 'long_tasks',
        }
    );
}

1;
