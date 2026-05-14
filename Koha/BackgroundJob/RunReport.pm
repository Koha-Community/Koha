package Koha::BackgroundJob::RunReport;

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
use JSON qw( to_json );
use Try::Tiny;

use base 'Koha::BackgroundJob';

use C4::Reports::Guided qw( execute_query store_results );
use Koha::Reports;

=head1 NAME

Koha::BackgroundJob::RunReport - Run a saved report as a background job

This is a subclass of Koha::BackgroundJob.

=head1 API

=head2 Class methods

=head3 job_type

Define the job type of this job: run_report

=cut

sub job_type {
    return 'run_report';
}

=head3 process

Run the saved report.

=cut

sub process {
    my ( $self, $args ) = @_;

    if ( $self->status eq 'cancelled' ) {
        return;
    }

    $self->start;

    my $report_id   = $args->{report_id};
    my @sql_params  = @{ $args->{sql_params}  || [] };
    my @param_names = @{ $args->{param_names} || [] };

    my $data = $self->decoded_data;

    try {
        my $report = Koha::Reports->find($report_id);
        unless ($report) {
            $data->{messages} = [ { type => 'error', code => 'report_not_found' } ];
            $data->{report}   = { report_id => $report_id };
            $self->status('failed');
            $self->finish($data);
            return;
        }

        my ( $sql, $header_types ) =
            $report->prep_report( \@param_names, \@sql_params, { run_type => 'background' } );

        my ( $sth, $errors ) = execute_query(
            {
                sql       => $sql,
                report_id => $report_id,
            }
        );

        if ( !$sth || $errors ) {
            my $error_msg;
            if ( ref $errors eq 'HASH' ) {
                $error_msg = $errors->{sqlerr} || $errors->{queryerr} || $errors->{passworderr} || 'Unknown error';
            } elsif ( ref $errors ) {
                $error_msg = to_json($errors);
            } else {
                $error_msg = defined $errors ? "$errors" : 'Unknown error';
            }
            $data->{messages} = [ { type => 'error', code => 'execute_error', error => $error_msg } ];
            $data->{report}   = { report_id => $report_id };
            $self->status('failed');
            $self->finish($data);
            return;
        }

        my @headers = @{ $sth->{NAME} };
        my @rows;
        while ( my $row = $sth->fetchrow_arrayref ) {
            push @rows, [@$row];
        }

        my $json            = to_json( { headers => \@headers, rows => \@rows } );
        my $saved_report_id = store_results( $report_id, $json );

        $self->step;

        $data->{report} = {
            report_id       => $report_id,
            saved_report_id => $saved_report_id,
            row_count       => scalar @rows,
        };

        $self->finish($data);
    } catch {
        $data->{messages} = [ { type => 'error', code => 'internal_error', error => "$_" } ];
        $data->{report}   = { report_id => $report_id };
        $self->status('failed');
        $self->finish($data);
    };
}

=head3 enqueue

Enqueue the new job

=cut

sub enqueue {
    my ( $self, $args ) = @_;

    my $job_id = $self->SUPER::enqueue(
        {
            job_size => 1,
            job_args => {
                report_id   => $args->{report_id},
                sql_params  => $args->{sql_params}  || [],
                param_names => $args->{param_names} || [],
            },
            job_queue => 'long_tasks',
        }
    );

    $self->report_id( $args->{report_id} )->store;

    return $job_id;
}

1;
