package Koha::BackgroundJob::PseudonymizeStatistic;

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

use Koha::PseudonymizedTransactions;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::PseudonymizeStatistic - Pseudonymize statistics background job

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: pseudonymize_statistic

=cut

sub job_type {
    return 'pseudonymize_statistic';
}

=head3 process

Process the modification.

=cut

sub process {
    my ( $self, $args ) = @_;
    $self->start;
    my $statistic   = $args->{statistic};
    my $stat_object = Koha::Statistic->new($statistic);
    Koha::PseudonymizedTransaction->create_from_statistic($stat_object);
    $self->finish( { data => "" } );    # We want to clear the job data to avoid storing patron information

}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    my $statistic = $args->{statistic};
    Koha::Exceptions::MissingParameter->throw("Missing statistic parameter is mandatory")
        unless $statistic;

    $self->SUPER::enqueue(
        {
            job_size  => 1,                             # Only handling one at time
            job_args  => { statistic => $statistic },
            job_queue => 'default',
        }
    );
}

1;
