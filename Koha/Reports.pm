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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Carp;

use Koha::Database;

use Koha::Report;

use base qw(Koha::Objects);

=head1 NAME

Koha::Reports - Koha Report Object set class

=head1 API

=head2 Class Methods

=cut

=head3 validate_sql

Validate SQL query string so it only contains a select,
not any of the harmful queries.

=cut

sub validate_sql {
    my ($self, $sql) = @_;

    $sql //= '';
    my @errors = ();

    if ($sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i) {
        push @errors, { sqlerr => $1 };
    } elsif ($sql !~ /^\s*SELECT\b\s*/i) {
        push @errors, { queryerr => 'Missing SELECT' };
    }

    return \@errors;
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
