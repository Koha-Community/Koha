package t::lib::Koha::BackgroundJob::BatchTest;

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

use Koha::BackgroundJobs;
use Koha::DateUtils qw( dt_from_string );

use base 'Koha::BackgroundJob';

sub job_type {
    return 'batch_test';
}

sub process {
    my ( $self, $args ) = @_;

    # FIXME: This should happen when $self->SUPER::process is called instead
    return
        unless $self->status ne 'cancelled';

    my $job_progress = 0;
    $self->started_on(dt_from_string)->progress($job_progress)->status('started')->store;

    my $report = {
        total_records => $self->size,
        total_success => 0,
    };
    my @messages;
    for my $i ( 0 .. $self->size - 1 ) {

        last if $self->get_from_storage->status eq 'cancelled';

        push @messages, {
            type => 'success',
            i    => $i,
        };
        $report->{total_success}++;
        $self->progress( ++$job_progress )->store;
    }

    my $job_data = $self->json->decode( $self->data );
    $job_data->{messages} = \@messages;
    $job_data->{report}   = $report;

    $self->ended_on(dt_from_string)->data( $self->json->encode($job_data) );
    $self->status('finished') if $self->status ne 'cancelled';
    $self->store;
}

sub enqueue {
    my ( $self, $args ) = @_;

    $self->SUPER::enqueue(
        {
            job_size => $args->{size},
            job_args => { a => $args->{a}, b => $args->{b} }
        }
    );
}

1;
