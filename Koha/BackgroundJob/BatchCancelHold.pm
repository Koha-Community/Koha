package Koha::BackgroundJob::BatchCancelHold;

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

use Koha::Holds;
use Koha::Patrons;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::BatchCancelHold - Batch cancel holds

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: batch_hold_cancel

=cut

sub job_type {
    return 'batch_hold_cancel';
}

=head3 process

Process the modification.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    $self->start;

    my @hold_ids = @{ $args->{hold_ids} };

    my $report = {
        total_holds   => scalar @hold_ids,
        total_success => 0,
    };
    my @messages;
      HOLD_IDS: for my $hold_id ( sort { $a <=> $b } @hold_ids ) {
        next unless $hold_id;

        # Authorities
        my ( $hold, $patron, $biblio );
        $hold = Koha::Holds->find($hold_id);

        my $error = eval {
            $patron = $hold->patron;
            $biblio = $hold->biblio;
            $hold->cancel( { cancellation_reason => $args->{reason} } );
        };

        if ( $error and $error != $hold or $@ ) {
            push @messages,
              {
                type        => 'error',
                code        => 'hold_not_cancelled',
                patron_id   => defined $patron ? $patron->borrowernumber : '',
                biblio_id    => defined $biblio ? $biblio->biblionumber : '',
                hold_id      => $hold_id,
                error        => defined $hold
                ? ( $@ ? "$@" : 0 )
                : 'hold_not_found',
              };
        }
        else {
            push @messages,
              {
                type      => 'success',
                code      => 'hold_cancelled',
                patron_id => $patron->borrowernumber,
                biblio_id    => $biblio->biblionumber,
                hold_id      => $hold_id,
              };
            $report->{total_success}++;
        }
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

    # TODO Raise exception instead
    return unless exists $args->{hold_ids};

    my @hold_ids = @{ $args->{hold_ids} };

    $self->SUPER::enqueue(
        {
            job_size  => scalar @hold_ids,
            job_args  => { hold_ids => \@hold_ids, reason => $args->{reason} },
            job_queue => 'long_tasks',
        }
    );
}

=head3 additional_report

Pass the biblio's title and patron's name

=cut

sub additional_report {
    my ( $self, $args ) = @_;

    my $messages = $self->messages;
    for my $m ( @$messages ) {
        $m->{patron} = Koha::Patrons->find($m->{patron_id});
        $m->{biblio} = Koha::Biblios->find($m->{biblio_id});
    }
    return { report_messages => $messages };
}

1;
