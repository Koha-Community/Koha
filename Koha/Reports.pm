package Koha::Reports;

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
use Koha::Database;
use Koha::Exceptions;

use Koha::Report;

use base qw(Koha::Objects Koha::Objects::Limit::Library Koha::Objects::Limit::LibraryGroup);

=head1 NAME

Koha::Reports - Koha Report Object set class

=head1 API

=head2 Class Methods

=cut

=head3 _processlist_rows

Used internally to query the database process list.
Returns an arrayref of hashrefs, one per row.

=cut

sub _processlist_rows {
    my ( $class, $sql, @binds ) = @_;
    return Koha::Database->new->schema->storage->dbh->selectall_arrayref( $sql, { Slice => {} }, @binds );
}

=head3 check_limits

Counts running and queued reports against the C<koha-conf.xml> limits.
Counts include processlist threads plus queued C<run_report> background
jobs. C<run_type> ('foreground' or 'background') is required. Returns:

    {
        any_exceeded => 0|1,
        errors       => [
            { duplicate_running_reports_per_user_limit_exceeded    => $count },
            { total_running_reports_per_user_limit_exceeded        => $count },
            { total_running_reports_per_instance_limit_exceeded    => $count },
        ],
    }

Error hashrefs appear only for limits that are set and reached.

For each cap, a run-type-specific override key (eg.
C<foreground_total_running_reports_per_instance_limit>) replaces the
combined key when set. The override caps only same-run-type threads,
so a foreground cap counts only foreground processlist threads and a
background cap counts background threads plus queued
C<run_report> jobs.

    my $limits = Koha::Reports->check_limits({
        report_id      => $report->id,
        borrowernumber => $patron->borrowernumber,
        run_type       => 'foreground',
    });
    return if $limits->{any_exceeded};

=cut

sub check_limits {
    my ( $class, $params ) = @_;

    my $report_id      = $params->{report_id};
    my $borrowernumber = $params->{borrowernumber};
    my $run_type       = $params->{run_type} // Koha::Exceptions::MissingParameter->throw( parameter => 'run_type' );

    Koha::Exceptions::BadParameter->throw( parameter => 'run_type' )
        unless $run_type =~ /^(foreground|background)$/;

    my @threads = $class->_active_report_runs;
    my $result  = { any_exceeded => 0, errors => [] };

    my $check = sub {
        my ( $key, $thread_filter, $queue_filter ) = @_;

        my $override = C4::Context->config("${run_type}_${key}");
        my $limit    = $override || C4::Context->config($key);
        return unless $limit;

        my @scoped = grep { $thread_filter->($_) } @threads;
        @scoped = grep { ( $_->{run_type} // '' ) eq $run_type } @scoped if $override;

        my $count = scalar @scoped;
        $count += $class->_queued_count($queue_filter)
            if !$override || $run_type eq 'background';

        if ( $count >= $limit ) {
            $result->{any_exceeded} = 1;
            push @{ $result->{errors} }, { "${key}_exceeded" => $count };
        }
    };

    if ( $borrowernumber && $report_id ) {
        $check->(
            'duplicate_running_reports_per_user_limit',
            sub { $_[0]->{report_id} == $report_id && ( $_[0]->{user_id} // 0 ) == $borrowernumber },
            { report_id => $report_id, user_id => $borrowernumber },
        );
    }
    if ($borrowernumber) {
        $check->(
            'total_running_reports_per_user_limit',
            sub { ( $_[0]->{user_id} // 0 ) == $borrowernumber },
            { user_id => $borrowernumber },
        );
    }
    $check->(
        'total_running_reports_per_instance_limit',
        sub { 1 },
        undef,
    );

    return $result;
}

=head3 _active_report_runs

Returns one hashref per running report thread from
C<information_schema.processlist>, each with C<report_id>, C<user_id>,
C<run_type>, C<process_id> (the processlist row id) and C<seconds>
(how long the thread has been running). Scoped to the current MySQL
user. Dies on processlist read failure.

=cut

sub _active_report_runs {
    my ($class) = @_;

    my $sql = q{
        SELECT id, time, info
          FROM information_schema.processlist
         WHERE user = SUBSTRING_INDEX(CURRENT_USER(), '@', 1)
           AND command != 'Sleep'
           AND info LIKE ?
    };

    my $rows = $class->_processlist_rows( $sql, '%saved_sql.id:%' );

    my @threads;
    for my $row ( @{ $rows || [] } ) {
        my $info        = $row->{info} // '';
        my ($report_id) = $info =~ /saved_sql\.id:\s*(\d+)/;
        my ($user_id)   = $info =~ /user_id:\s*(\d+)/;
        my ($run_type)  = $info =~ /run_type:\s*(foreground|background)/;
        next unless defined $report_id;
        push @threads,
            {
            report_id  => $report_id,
            user_id    => $user_id,
            run_type   => $run_type,
            process_id => $row->{id},
            seconds    => $row->{time},
            };
    }
    return @threads;
}

=head3 _queued_count

Returns the count of queued C<run_report> background jobs. Optional
C<user_id> filters by C<background_jobs.borrowernumber>; optional
C<report_id> filters by C<background_jobs.report_id>.

=cut

sub _queued_count {
    my ( $class, $params ) = @_;
    $params //= {};

    my $where = { type => 'run_report', status => 'new' };
    $where->{borrowernumber} = $params->{user_id}   if $params->{user_id};
    $where->{report_id}      = $params->{report_id} if $params->{report_id};

    return Koha::BackgroundJobs->search($where)->count;
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'SavedSql';
}

=head3 object_class

Returns name of corresponding Koha Object Class

=cut

sub object_class {
    return 'Koha::Report';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
