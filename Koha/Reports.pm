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

use Koha::Database;
use Koha::Logger;

use Koha::Report;

use base qw(Koha::Objects Koha::Objects::Limit::Library);

=head1 NAME

Koha::Reports - Koha Report Object set class

=head1 API

=head2 Class Methods

=cut

=head3 running

Returns a Koha::Reports resultset of reports currently being executed,
optionally filtered by the patron that started them and/or by report id.

    my $running = Koha::Reports->running(
        {
            user_id   => $patron->borrowernumber,
            report_id => $report->id,
        }
    );

    if ( $running->count ) { ... }

Both C<user_id> (a borrowernumber) and C<report_id> are optional. The lookup
relies on the SQL comment embedded by L<Koha::Report/prep_report> being
visible in C<information_schema.processlist>.

The query is always scoped to the current connection's MySQL user via
C<user = SUBSTRING_INDEX(CURRENT_USER(), '@', 1)>. Without C<PROCESS>
privilege MariaDB/MySQL already restricts C<information_schema.processlist>
to the caller's own threads, but if a site has granted broader privileges
this filter ensures we never count threads belonging to other database
users (eg. another Koha instance sharing the server, or an unrelated
application using the same MariaDB).

If the database user lacks the privileges needed to query
C<information_schema.processlist>, the failure is logged via C<warn> and
an empty resultset is returned so that callers degrade gracefully rather
than aborting the operation they were guarding.

=cut

sub running {
    my ( $class, $params ) = @_;

    my $user_id   = $params->{user_id};
    my $report_id = $params->{report_id};

    my @where = (
        q{user = SUBSTRING_INDEX(CURRENT_USER(), '@', 1)},
        'command != ?',
        'info LIKE ?',
    );
    my @binds = ( 'Sleep', '%saved_sql.id:%' );

    if ($user_id) {
        push @where, 'info LIKE ?';
        push @binds, sprintf( '%%{ user_id: %d }%%', $user_id );
    }
    if ($report_id) {
        push @where, 'info LIKE ?';
        push @binds, sprintf( '%%{ saved_sql.id: %d }%%', $report_id );
    }

    my $sql = 'SELECT info FROM information_schema.processlist WHERE ' . join( ' AND ', @where );

    my $rows;
    eval { $rows = $class->_processlist_rows( $sql, @binds ); };
    if ($@) {
        Koha::Logger->get->warn("Koha::Reports->running: unable to query information_schema.processlist: $@");
        $rows = [];
    }

    my %report_ids;
    for my $row (@$rows) {
        $report_ids{$1} = 1 if $row->{info} =~ /saved_sql\.id:\s*(\d+)/;
    }

    return $class->search( { id => { -in => [ keys %report_ids ] } } );
}

=head3 _processlist_rows

Used internally to query the database process list.
Returns an arrayref of hashrefs, one per row.

=cut

sub _processlist_rows {
    my ( $class, $sql, @binds ) = @_;
    return Koha::Database->new->schema->storage->dbh->selectall_arrayref( $sql, { Slice => {} }, @binds );
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
