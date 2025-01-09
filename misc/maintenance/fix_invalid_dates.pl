#!/usr/bin/perl

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
use C4::Log      qw(cronlogaction);
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );
use Koha::Logger;
use Koha::DateUtils qw( dt_from_string );
use Koha::Script -cron;
use Data::Dumper;
use Koha::Database;

=head1 NAME

fix_invalid_dates.pl - Fix invalid dates

=head1 DESCRIPTION

This script fixes any date fields in the database that have '0000-00-00' values (for example: dateofbirth) by updating them to 'NULL'.

=cut

my $verbose = 0;
my $doit    = 0;

my $command_line_options = join( " ", @ARGV );

GetOptions(
    'v|verbose' => \$verbose,
    'c|confirm' => \$doit,
);

if ($doit) {
    cronlogaction( { action => 'Run', info => $command_line_options } );
} else {
    warn "Running in dry-run mode, provide --confirm to apply the changes\n";
}

my $schema = Koha::Database->new->schema;

# Loop over all the DBIx::Class classes
for my $class ( sort values %{ $schema->{class_mappings} } ) {

    # Retrieve the resultset so we can access the columns info
    my $rs      = $schema->resultset($class);
    my $columns = $rs->result_source->columns_info;

    # Loop over the columns
    while ( my ( $column, $info ) = each %$columns ) {

        # Next if data type is not date/datetime/timestamp
        my $data_type = $info->{data_type};
        next unless grep { $data_type =~ m{^$_$} } qw( timestamp datetime date );

        # Count the invalid dates
        my $invalid_dates = $rs->search( { $column => '0000-00-00' } )->count;

        next unless $invalid_dates;

        if ($verbose) {
            say sprintf "Column %s.%s contains %s invalid dates", $rs->result_source->name, $column, $invalid_dates;
        }

        if ($doit) {
            $rs->search( { $column => '0000-00-00' } )->update( { $column => undef } );
            say sprintf "Column %s.%s contains %s invalid dates that have been fixed", $rs->result_source->name,
                $column, $invalid_dates;
        }

    }
}
