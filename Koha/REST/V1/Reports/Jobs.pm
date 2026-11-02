package Koha::REST::V1::Reports::Jobs;

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

use Mojo::Base 'Mojolicious::Controller';

use JSON qw( decode_json );
use Try::Tiny;

use C4::Context;
use Koha::BackgroundJobs;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use Koha::Report;
use Koha::Reports;
use Koha::Reports::BackgroundJobs;

=head1 API

=head2 Methods

=head3 list

List run_report background jobs. Optional C<after> and C<before> ISO
8601 query parameters bound the search on C<enqueued_on>.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $after  = $c->param('after');
        my $before = $c->param('before');
        $c->req->params->remove('after');
        $c->req->params->remove('before');

        my $rs = Koha::Reports::BackgroundJobs->search( { type => 'run_report' } );
        if ( $after || $before ) {
            my $dtf = Koha::Database->new->schema->storage->datetime_parser;
            my %bounds;
            $bounds{'>='} = $dtf->format_datetime( dt_from_string( $after,  'iso' ) ) if $after;
            $bounds{'<='} = $dtf->format_datetime( dt_from_string( $before, 'iso' ) ) if $before;
            $rs           = $rs->search( { enqueued_on => \%bounds } );
        }

        # Only list jobs for reports the logged in user is allowed to see. This is done
        # in the query, before paging, so the pagination headers match what is returned.
        my $patron     = $c->stash('koha.user');
        my $limit_pref = C4::Context->preference('LimitReportsBy') // 'none';
        if ( $limit_pref ne 'none' && !Koha::Report->can_manage_limits($patron) ) {
            my $branchcode = C4::Context::mybranch();
            my $allowed_reports =
                !$branchcode
                ? Koha::Reports->search( { 'reports_branches.branchcode' => undef }, { join => 'reports_branches' } )
                : $limit_pref eq 'library_group'
                ? Koha::Reports->search_with_library_group_limits( {}, {}, $branchcode, 'ft_reports' )
                : Koha::Reports->search_with_library_limits( {}, {}, $branchcode );
            $rs = $rs->search(
                {
                    -or => [

                        # The report has been deleted
                        { report_id => undef },
                        { report_id => { -in => $allowed_reports->_resultset->get_column('me.id')->as_query } },
                    ]
                }
            );
        }

        my $paged = $c->objects->search_rs($rs);
        $c->add_pagination_headers;

        my @jobs;
        while ( my $job = $paged->next ) {
            push @jobs, $job;
        }

        my %report_ids      = map { $_->report_id      => 1 } grep { $_->report_id } @jobs;
        my %borrowernumbers = map { $_->borrowernumber => 1 } grep { $_->borrowernumber } @jobs;

        my %reports_by_id;
        if (%report_ids) {
            my $rs = Koha::Reports->search( { id => { -in => [ keys %report_ids ] } } );
            while ( my $r = $rs->next ) { $reports_by_id{ $r->id } = $r; }
        }
        my %patrons_by_id;
        if (%borrowernumbers) {
            my $rs = Koha::Patrons->search( { borrowernumber => { -in => [ keys %borrowernumbers ] } } );
            while ( my $p = $rs->next ) { $patrons_by_id{ $p->borrowernumber } = $p; }
        }

        my @rendered = map { _render_job( $_, \%reports_by_id, \%patrons_by_id ) } @jobs;

        return $c->render( status => 200, openapi => \@rendered );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_running

List report SQL threads currently executing in MariaDB, regardless
of whether they were started in the foreground or by a background
worker. Sourced from information_schema.processlist via
Koha::Reports->_active_report_runs.

=cut

sub list_running {
    my $c = shift->openapi->valid_input or return;

    return try {
        my @threads = Koha::Reports->_active_report_runs;

        # threads needs to be limited to the ones the logged in user can actually see
        # get the patron and the LimitReportsBy sys pref value
        my $patron     = $c->stash('koha.user');
        my $limit_pref = C4::Context->preference('LimitReportsBy') // 'none';

        #we can skip this and just give the user all reports IF the LimitReportsBy pref is off OR the user can manage report limits
        if ( $limit_pref ne 'none' && !Koha::Report->can_manage_limits($patron) ) {
            my $branchcode = C4::Context::mybranch();
            my $allowed_reports;
            if ( !$branchcode ) {

                # No loggedinlibrary, only reports without library limits are allowed
                $allowed_reports = Koha::Reports->search(
                    { 'reports_branches.branchcode' => undef },
                    { join                          => 'reports_branches' }
                );
            } elsif ( $limit_pref eq 'library_group' ) {

                #get all allowed reports in the library group
                $allowed_reports =
                    Koha::Reports->search_with_library_group_limits( {}, {}, $branchcode, 'ft_reports' );
            } else {

                #only get reports allowed for this branch
                $allowed_reports = Koha::Reports->search_with_library_limits( {}, {}, $branchcode );
            }

            #map each of the report_ids the user is allowed to see
            my %allowed_ids = map { $_ => 1 } $allowed_reports->get_column('me.id');
            @threads = grep { $allowed_ids{ $_->{report_id} } } @threads;
        }

        my %report_ids = map { $_->{report_id} => 1 } grep { $_->{report_id} } @threads;
        my %user_ids   = map { $_->{user_id}   => 1 } grep { $_->{user_id} } @threads;

        my %reports_by_id;
        if (%report_ids) {
            my $rs = Koha::Reports->search( { id => { -in => [ keys %report_ids ] } } );
            while ( my $r = $rs->next ) { $reports_by_id{ $r->id } = $r; }
        }
        my %patrons_by_id;
        if (%user_ids) {
            my $rs = Koha::Patrons->search( { borrowernumber => { -in => [ keys %user_ids ] } } );
            while ( my $p = $rs->next ) { $patrons_by_id{ $p->borrowernumber } = $p; }
        }

        my @rendered;
        for my $t (@threads) {
            my $report = $t->{report_id} ? $reports_by_id{ $t->{report_id} } : undef;
            my $owner  = $t->{user_id}   ? $patrons_by_id{ $t->{user_id} }   : undef;

            push @rendered, {
                process_id  => $t->{process_id},
                seconds     => $t->{seconds},
                run_type    => $t->{run_type},
                report_id   => $t->{report_id},
                report_name => $report ? $report->report_name : undef,
                patron_id   => $t->{user_id},
                patron_name => $owner ? join( ' ', grep { $_ } $owner->firstname, $owner->surname ) : undef,
            };
        }

        return $c->render( status => 200, openapi => \@rendered );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 cancel

Cancel a queued run_report background job. Only the librarian who
enqueued the job, or a superlibrarian, may cancel it. Only jobs whose
status is C<new> can be cancelled.

=cut

sub cancel {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $patron   = $c->stash('koha.user');
        my $is_super = $patron && $patron->flags && ( $patron->flags == 1 || ( $patron->flags & 1 ) );

        my $job = Koha::BackgroundJobs->find( $c->param('job_id') );
        return $c->render_resource_not_found('Job')
            unless $job && $job->type eq 'run_report';

        unless ( $is_super || ( $patron && $job->borrowernumber == $patron->borrowernumber ) ) {
            return $c->render(
                status  => 403,
                openapi => { error => 'Cannot cancel this job' },
            );
        }

        unless ( $job->status eq 'new' ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Job is not in a cancellable state',
                    error_code => 'not_cancellable',
                },
            );
        }

        $job->cancel;
        return $c->rendered(204);
    } catch {
        $c->unhandled_exception($_);
    };
}

=head2 Internal methods

=head3 _render_job

    my $job_data = _render_job( $job, \%reports_by_id, \%patrons_by_id );

Returns the API representation (see the report_job definition) of a run_report
background job. The report and patron names are looked up in the given hashrefs,
which are keyed by report id and borrowernumber. The saved results id, row count
and first error message come from the job's data.

=cut

sub _render_job {
    my ( $job, $reports_by_id, $patrons_by_id ) = @_;

    my $data = eval { decode_json( $job->data // '{}' ) } || {};

    my $report    = $job->report_id      ? $reports_by_id->{ $job->report_id }      : undef;
    my $owner     = $job->borrowernumber ? $patrons_by_id->{ $job->borrowernumber } : undef;
    my $saved_id  = $data->{report} && $data->{report}{saved_report_id};
    my $row_count = $data->{report} && $data->{report}{row_count};

    my $first_error =
          ( ref $data->{messages} eq 'ARRAY' )
        ? ( grep { ( $_->{type} // '' ) eq 'error' } @{ $data->{messages} } )[0]
        : undef;

    return {
        job_id          => $job->id,
        type            => $job->type,
        status          => $job->status,
        enqueued_date   => $job->enqueued_on,
        started_date    => $job->started_on,
        ended_date      => $job->ended_on,
        patron_id       => $job->borrowernumber,
        patron_name     => $owner ? join( ' ', grep { $_ } $owner->firstname, $owner->surname ) : undef,
        report_id       => $job->report_id,
        report_name     => $report ? $report->report_name : undef,
        saved_report_id => $saved_id,
        row_count       => $row_count,
        error_code      => $first_error ? $first_error->{code}  : undef,
        error_message   => $first_error ? $first_error->{error} : undef,
    };
}

1;
