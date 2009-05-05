#!/usr/bin/perl -w

# 2008 Kyle Hall <kyle.m.hall@gmail.com>

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

=head1 NAME

create_koc_db.pl - create a database file for the offline circulation tool

=head1 SYNOPSIS

create_koc_db.pl

 Options:
   -help                          brief help message
   -man                           full documentation

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--file>

the filename that we should use for the database file that we produce. Defaults to "borrowers.db"

=item B<--force>

Forcefully overwrite any existing db file. Defaults to false, so
program will terminate prematurely if the file already exists.

=back

=head1 DESCRIPTION

This script generates a sqlite database file full of patron and
holdings data that can be used by an offline circulation tool.

=head1 USAGE EXAMPLES

This program could be run from cron to occasionally refresh the
offline circulation database. For instance:

C<0 0 * * * create_koc_db.pl>

=head1 SEE ALSO

This program was originally created to interact with Kyle Hall's
offline circulation tool, which is available from
L<http://kylehall.info/index.php/projects/koha-tools/koha-offline-circulation/>,
but any similar tool could use the database that is produced.

=cut

use strict;
use warnings;

$|++;

use DBI;
use Getopt::Long;
use Pod::Usage;
use C4::Context;
use English qw(-no_match_vars);

my $verbose  = 0;
my $help     = 0;
my $man      = 0;
my $filename = 'borrowers.db';
my $force    = 0;

GetOptions(
    'verbose' => \$verbose,
    'help'    => \$help,
    'man'     => \$man,
    'file=s'  => \$filename,
    'force'   => \$force,
) or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

my %wanted_borrowers_columns = map { $_ => 1 } qw/borrowernumber cardnumber surname  firstname address city phone dateofbirth/; 
my %wanted_issues_columns    = map { $_ => 1 } qw/borrowernumber date_due itemcallnumber title itemtype/;

prepare_file_for_writing($filename)
  or die "file: '$filename' already exists. Use --force to overwrite\n";

verify_dbd_sqlite();

## Create DB Connections
my $dbh_mysql = C4::Context->dbh;
my $dbh_sqlite = DBI->connect( "dbi:SQLite2:dbname=$filename", "", "" );
$dbh_sqlite->{AutoCommit} = 0;

create_borrowers_table();
populate_borrowers_table();

create_issues_table();
populate_issues_table();

=head1 INTERNAL METHODS

=head2 verify_dbd_sqlite

Since DBD::SQLite is a new prerequisite and an optional one, let's
make sure we have a new enough version of it.

=cut

sub verify_dbd_sqlite {

    eval { require DBD::SQLite2; };
    if ( $EVAL_ERROR ) {
        my $msg = <<'END_MESSAGE';
DBD::SQLite2 is required to generate offline circultion database files, but not found.
Please install the DBD::SQLite2 perl module. It is availalbe from
http://search.cpan.org/dist/DBD-SQLite2/ or through the CPAN module.
END_MESSAGE
        die $msg;
    }
}

=head2 prepare_file_for_writing

pass in the filename that we're considering using for the SQLite db.

returns true if we can use it.

returns false if we can't. For example, if it alredy exists and we
don't have --force or don't have permissions to unlink it.

=cut

sub prepare_file_for_writing {
    my $filename = shift;
    if ( -e $filename ) {

        # this file exists. remove it if --force.
        if ($force) {
            return unlink $filename;
        } else {
            return;
        }
    }
    return $filename;
}

=head2 create_borrowers_table

Create sqlite borrowers table to mirror the koha borrowers table structure

=cut

sub create_borrowers_table {

    my %borrowers_info = get_columns_and_types_of_table( 'borrowers' );
    my $sqlite_create_sql = "CREATE TABLE borrowers ( \n";
  
    $sqlite_create_sql .= join(',', map{ $_ . ' ' . $borrowers_info{$_} } 
                                    grep { exists($wanted_borrowers_columns{$_}) } keys %borrowers_info);
    
    $sqlite_create_sql .= " , \n total_fines decimal(28,6) ";    ## Extra field to store the total fines for a borrower in.
    $sqlite_create_sql .= " ) ";

    my $return = $dbh_sqlite->do($sqlite_create_sql);
    unless ( $return ) {
        warn 'unable to create borrowers table: ' . $dbh_sqlite->errstr();
    }
    return $return;

}

=head2 populate_borrowers_table

Import the data from the koha.borrowers table into our sqlite table

=cut

sub populate_borrowers_table {

    my @borrower_fields = grep { exists($wanted_borrowers_columns{$_}) } get_columns_of_table( 'borrowers' );
    push @borrower_fields, 'total_fines';
    
    my $sql = "INSERT INTO borrowers ( ";
    $sql .= join( ',', @borrower_fields );
    $sql .= " ) VALUES ( ";
    $sql .= join( ',', map { '?' } @borrower_fields );
    $sql .= " ) ";
    my $sth_sqlite = $dbh_sqlite->prepare($sql);

    my $sth_mysql    = $dbh_mysql->prepare(<<'END_SQL');
SELECT borrowernumber,
       cardnumber,
       surname,
       firstname,
       address,
       city,
       phone,
       dateofbirth,
       sum( accountlines.amountoutstanding ) as total_fines
FROM borrowers
LEFT JOIN accountlines USING (borrowernumber)
GROUP BY borrowernumber;
END_SQL

    my $fields_count = $sth_mysql->execute();
    warn "preparing to insert $fields_count borrowers\n" if $verbose;

    my $count;
    while ( my $borrower = $sth_mysql->fetchrow_hashref ) {
        $count++;
        if ( $verbose ) {
            print '.' unless ( $count % 10 );
            print "$count\n" unless ( $count % 1000 );
        }
        $sth_sqlite->execute( @$borrower{ @borrower_fields } );
        $sth_sqlite->finish();
        $dbh_sqlite->commit() if ( 0 == $count % 1000 );
    }
    $dbh_sqlite->commit();
    print "inserted $count borrowers\n" if $verbose;
    # add_fines_to_borrowers_table();
}

=head2 add_fines_to_borrowers_table

Import the fines from koha.accountlines into the sqlite db

=cut

sub add_fines_to_borrowers_table {

    print "preparing to update borrowers\n" if $verbose;
    my $sth_mysql = $dbh_mysql->prepare(
        "SELECT DISTINCT borrowernumber, SUM( amountoutstanding ) AS total_fines
                                    FROM accountlines
                                    GROUP BY borrowernumber"
    );
    $sth_mysql->execute();
    my $count;
    while ( my $result = $sth_mysql->fetchrow_hashref() ) {
        $count++;
        if ( $verbose ) {
            print '.' unless ( $count % 10 );
            print "$count\n" unless ( $count % 1000 );
        }

        my $borrowernumber = $result->{'borrowernumber'};
        my $total_fines    = $result->{'total_fines'};

        # warn "Fines for Borrower # $borrowernumber are \$ $total_fines \n" if $verbose;
        my $sql = "UPDATE borrowers SET total_fines = ? WHERE borrowernumber = ?";

        my $sth_sqlite = $dbh_sqlite->prepare($sql);
        $sth_sqlite->execute( $total_fines, $borrowernumber );
        $sth_sqlite->finish();
    }
    print "updated $count borrowers\n" if ( $verbose && $count );
}

=head2 create_issue_table

Create sqlite issues table with minimal information needed from koha tables issues, items, biblio, biblioitems

=cut

sub create_issues_table {

    my $fields = get_columns_for_issues_table();

    my $sqlite_create_sql = "CREATE TABLE issues ( \n";

    my $firstField = 1;
    foreach my $key ( keys %$fields ) {
        my $field = $key;
        my $type  = $fields->{$key};

        if ($firstField) {
            $sqlite_create_sql .= " $field $type ";
            $firstField = 0;
        } else {
            $sqlite_create_sql .= ", \n $field $type ";
        }
    }
    $sqlite_create_sql .= " ) ";

    my $sth_sqlite = $dbh_sqlite->prepare($sqlite_create_sql);
    $sth_sqlite->execute();
    $sth_sqlite->finish();

}

=head2 populate_issues_table

Import open issues from the koha database

=cut

sub populate_issues_table {

    print "preparing to populate ISSUES table\n" if $verbose;
    my $sth_mysql = $dbh_mysql->prepare(
        "SELECT issues.borrowernumber,
                issues.date_due,
                items.itemcallnumber,
                biblio.title,
                biblioitems.itemtype
         FROM   issues, items, biblioitems, biblio
         WHERE issues.itemnumber = items.itemnumber
         AND items.biblionumber = biblioitems.biblionumber
         AND items.biblionumber = biblio.biblionumber
         AND returndate IS NULL"
    );
    $sth_mysql->execute();

    my $column_names = $sth_mysql->{'NAME'};
    my $sql_sqlite = "INSERT INTO issues ( ";
    $sql_sqlite .= join( ',', @$column_names );
    $sql_sqlite .= " ) VALUES ( ";
    $sql_sqlite .= join( ',', map { '?' } @$column_names );
    $sql_sqlite .= " ) ";

    warn "$sql_sqlite\n" if $verbose;
    my $sth_sqlite = $dbh_sqlite->prepare($sql_sqlite);

    my $count;
    while ( my $result = $sth_mysql->fetchrow_hashref ) {

        $count++;
        if ( $verbose ) {
            print '.' unless ( $count % 10 );
            print "$count\n" unless ( $count % 1000 );
        }

        $sth_sqlite->execute( @$result{ @$column_names } );
        $sth_sqlite->finish();
        $dbh_sqlite->commit() if ( 0 == $count % 1000 );
    }
    $dbh_sqlite->commit();
    print "inserted $count issues\n" if ( $verbose && $count );
}

=head2 get_columns_of_table

pass in the name of a database table.

returns list of column names in that table.

=cut

sub get_columns_of_table {
    my $table_name = shift;

    my %column_info = get_columns_and_types_of_table( $table_name );
    my @columns = keys %column_info;
    return @columns;

}

=head2 get_columns_and_types_of_table

pass in the name of a database table

returns a hash of column names to their types.

=cut

sub get_columns_and_types_of_table {
    my $table_name = shift;

    my $column_info = $dbh_mysql->selectall_arrayref( "SHOW COLUMNS FROM $table_name" );
    my %columns = map{ $_->[0] => $_->[1] } @$column_info;
    return %columns;

}

=head2 get_columns_for_issues_table

This sub returns a hashref where the keys are all the fields in the given tables, and the data is the field's type

=cut

sub get_columns_for_issues_table {
  
  my @tables = ( 'issues', 'items', 'biblioitems', 'biblio' );

  my %fields;
  
  foreach my $table ( @tables ) {
      my %table_info = get_columns_and_types_of_table( $table );
      %fields = ( %fields, %table_info );
  }
  return { map { $_ => $fields{$_} } grep { exists($wanted_issues_columns{$_}) } keys %fields };
}

1;
__END__

