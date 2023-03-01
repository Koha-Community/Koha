package Koha::BackgroundJob::ErmSushiHarvester;

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

use Koha::DateUtils qw( dt_from_string );
use Koha::ERM::UsageDataProviders;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::ErmSushiHarvester - Background job derived class to process the ERM Usage Statistics SUSHI Harvester
=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: erm_sushi_harvester

=cut

sub job_type {
    return 'erm_sushi_harvester';
}

=head3 process

Koha::BackgroundJob->find($id)->process(
    {
        ud_provider_id => $self->erm_usage_data_provider_id
    }
);

Process the harvesting.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    $self->{us_report_info} = {
        skipped_mus => 0,
        skipped_yus => 0,
        added_mus   => 0,
        added_yus   => 0
    };

# FIXME If the job has already been started, but started again (worker has been restart for instance)
# Then we will start from scratch and so double process the same records

    $self->start;

    my $ud_provider =
      Koha::ERM::UsageDataProviders->find( $args->{ud_provider_id} );

    $ud_provider->harvest(
        $args->{report_type},
        {
            report_info_callback => sub { $self->report_info(@_); },
            step_callback        => sub { $self->step; },
            set_size_callback    => sub { $self->set_job_size(@_); },
            add_message_callback => sub { $self->add_message(@_); },
        }
    );

    # Prepare job report
    my $report = {
        report_type      => $ud_provider->{report_type},
        total_records    => $ud_provider->{total_records},
        us_report_info   => $self->{us_report_info},
        ud_provider_id   => $ud_provider->erm_usage_data_provider_id,
        ud_provider_name => $ud_provider->name,
    };

    my $data = $self->decoded_data;
    $data->{report}   = $report;
    $data->{messages} = \@{ $self->{messages} };

    $self->finish($data);
}

=head3 report_info

Setter for report_info

=cut

sub report_info {
    my ( $self, $info ) = @_;

    $self->{us_report_info}{$info}++;
}

=head3 set_job_size

Setter for job_size

=cut

sub set_job_size {
    my ( $self, $size ) = @_;

    $self->size($size)->store();
}

=head3 add_message

    $job->add_message(
        {
            type => 'success', # success, warning or error
            code => 'object_added', # object_added or object_already_exists
            title => $row->{Title},
        }
    );

Add a new job message

=cut

sub add_message {
    my ( $self, $message ) = @_;

    push @{ $self->{messages} }, $message;

}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    $self->SUPER::enqueue(
        {
            job_size  => 1,
            job_args  => {%$args},
            job_queue => 'long_tasks',
        }
    );
}

1;
