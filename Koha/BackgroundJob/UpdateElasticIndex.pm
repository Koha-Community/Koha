package Koha::BackgroundJob::UpdateElasticIndex;

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
use JSON qw( encode_json decode_json );

use Koha::BackgroundJobs;
use Koha::DateUtils qw( dt_from_string );
use C4::Biblio;
use C4::MarcModificationTemplates;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::UpdateElasticIndex - Update Elastic index

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: update_elastic_index

=cut

sub job_type {
    return 'update_elastic_index';
}

=head3 process

Process the modification.

=cut

sub process {
    my ( $self, $args ) = @_;

    my $job = Koha::BackgroundJobs->find( $args->{job_id} );

    if ( !exists $args->{job_id} || !$job || $job->status eq 'cancelled' ) {
        return;
    }

    # FIXME If the job has already been started, but started again (worker has been restart for instance)
    # Then we will start from scratch and so double process the same records

    my $job_progress = 0;
    $job->started_on(dt_from_string)
        ->progress($job_progress)
        ->status('started')
        ->store;

    my @record_ids = @{ $args->{record_ids} };
    my $record_server = $args->{record_server};

    my $report = {
        total_records => scalar @record_ids,
        total_success => 0,
    };

    my @messages;
    eval {
        my $es_index =
            $record_server eq "authorityserver"
          ? $Koha::SearchEngine::AUTHORITIES_INDEX
          : $Koha::SearchEngine::BIBLIOS_INDEX;
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $es_index });
        $indexer->update_index(\@record_ids);
    };
    if ( $@ ) {
        push @messages, {
            type => 'error',
            code => 'index_error',
            error => $@,

        }
    } else {
        # FIXME This is not correct if some record_ids have been skipped
        $report->{total_success} = scalar @record_ids;
    }

    my $job_data = decode_json $job->data;
    $job_data->{messages} = \@messages;
    $job_data->{report} = $report;

    $job->ended_on(dt_from_string)
        ->data(encode_json $job_data);
    $job->status('finished') if $job->status ne 'cancelled';
    $job->store;
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args) = @_;

    return unless exists $args->{record_server};
    return unless exists $args->{record_ids};

    my $record_server = $args->{record_server};
    my @record_ids = @{ $args->{record_ids} };

    $self->SUPER::enqueue({
        job_size => scalar @record_ids,
        job_args => {record_server => $record_server, record_ids => \@record_ids},
    });
}

1;
