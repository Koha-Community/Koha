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

use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;

use base 'Koha::BackgroundJob';

=head1 NAME

Koha::BackgroundJob::UpdateElasticIndex - Update Elastic index

This is a subclass of Koha::BackgroundJob.

While most background jobs provide a I<process> method, the ES indexing has its
own dedicated worker: misc/workers/es_indexer_daemon.pl

That worker handles all job processing.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: update_elastic_index

=cut

sub job_type {
    return 'update_elastic_index';
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
    # elastic_index queue will be handled by the es_indexer_daemon script

    $self->SUPER::enqueue({
        job_size => 1, # Each index is a single job, regardless of the amount of records included
        job_args => {record_server => $record_server, record_ids => \@record_ids},
        job_queue => 'elastic_index'
    });
}

1;
