#!/usr/bin/perl

# This script helps you synchronize database comments between DB and schema.

# This file is part of Koha.
#
# Copyright 2022 Rijksmuseum, Koha development team
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
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use C4::Context;
use Koha::Database::Commenter;

sub alert_dry_run { print "-- DRY RUN\n" if $_[0]->{dry_run}; }

my $cmd_args = {};
GetOptions(
  'clear'      => \$cmd_args->{clear},
  'commit|c'   => \$cmd_args->{commit},
  'database:s' => \$cmd_args->{database},
  'help|h'     => \$cmd_args->{help},
  'renumber'   => \$cmd_args->{renumber},
  'reset'      => \$cmd_args->{reset},
  'schema:s'   => \$cmd_args->{schema_file},
  'table:s'    => \$cmd_args->{table},
  'verbose|v'  => \$cmd_args->{verbose},
);
$cmd_args->{dry_run} = !$cmd_args->{commit};

my $commenter = Koha::Database::Commenter->new({
    database => delete $cmd_args->{database}, dbh => C4::Context->dbh, schema_file => delete $cmd_args->{schema_file},
});
my $messages = $cmd_args->{verbose} || $cmd_args->{dry_run} ? [] : undef;
if( $cmd_args->{help} ) {
    pod2usage( -verbose => 2 );
} elsif( ($cmd_args->{clear}||0) + ($cmd_args->{renumber}||0) + ($cmd_args->{reset}||0) > 1 ) {
    print "You cannot pass the clear, renumber and reset flags together\n";
} elsif( delete $cmd_args->{clear} ) {
    alert_dry_run( $cmd_args );
    $commenter->clear( $cmd_args, $messages );
} elsif( delete $cmd_args->{reset} ) {
    alert_dry_run( $cmd_args );
    $commenter->reset_to_schema( $cmd_args, $messages );
} elsif( delete $cmd_args->{renumber} ) {
    alert_dry_run( $cmd_args );
    $commenter->renumber( $cmd_args, $messages );
} else {
    pod2usage( -verbose => 1 );
}
print join("\n", @$messages), "\n" if $messages && @$messages;

__END__

=pod

=head1 NAME

misc/maintenance/sync_db_comments.pl

=head1 SYNOPSIS

    perl sync_db_comments.pl [-h] [-v] [-schema FILE ] [-database DB_NAME] [-table TABLE_NAME] [-commit] [-clear|-reset|-renumber]

=head1 DESCRIPTION

    Synchronize column comments in database with Koha schema. Allows you
    to clear comments too. Operates additionally on specific tables only.
    And provides a dry run mode that prints sql statements.

    Warning: According to good practice, make a backup of your database
    before running this script.

    Some examples:

    misc/maintance/sync_db_comments.pl -help
    Usage statement.

    misc/maintance/sync_db_comments.pl -clear -commit -verbose
    Clear all column comments in database.
    The verbose flag shows all issued ALTER TABLE statements.

    misc/maintance/sync_db_comments.pl -reset -commit -database mydb -table items -schema newstructure.sql
    Only resets comments in items table.
    Operates on specific database instead of the one from $KOHA_CONF.
    Reads the schema from the specified file instead of default one.

    misc/maintance/sync_db_comments.pl -renumber
    Renumbers all comments like Comment_1,2,..
    Added for testing purposes. Not meant to run on production.
    Omitting the commit flag allows you to see what would be done (dry run).

=head1 ADDITIONAL COMMENTS

    This script may prove helpful to track synchronization issues between
    Koha schema and actual database structure due to inconsistencies in
    database revisions. It reduces the noise from missing column comments
    when running script update_dbix_class_files.pl.

    The script is just a wrapper around the module Koha::Database::Commenter.
    A test script is provided in t/db_dependent/Koha/Database/Commenter.t.

    The flags -clear, -reset and -renumber are mutually exclusive.

    The renumber option has been helpful in verifying that the alter table
    operations work on the complete Koha database. It is not recommended to run
    it in production (obviously).

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Amsterdam, The Netherlands

=cut
