package Koha::Installer;

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

use C4::Context;

=head1 NAME

Koha::Installer - Class that provides installation related methods

=head1 API

=head2 Class Methods

=cut

=head3 check_db_row_format

=cut

sub check_db_row_format {
    my ($class) = @_;
    my %result = ();
    my $database = C4::Context->config('database');
    if ($database){
        my $dbh = C4::Context->dbh;
        my $sql = q#
            SELECT count(table_name)
            FROM information_schema.tables
            WHERE
                table_schema = ?
                AND row_format != "Dynamic"
        #;
        my $sth = $dbh->prepare($sql);
        $sth->execute($database);
        my $row = $sth->fetchrow_arrayref;
        my $count = $row->[0];
        if ($count){
            $result{count} = $count;
        }
    }
    return \%result;
}

1;
