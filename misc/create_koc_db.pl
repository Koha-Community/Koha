#!/usr/bin/perl -w

## FIXME: if there is an existing borrowers.db file it needs to be deleted before this script is ran.

use DBI;
use C4::Context;

use strict;

## Create DB Connections
my $dbh_mysql = C4::Context->dbh;
my $dbh_sqlite = DBI->connect("dbi:SQLite:dbname=borrowers.db","","");

## Create sqlite borrowers table to mirror the koha borrowers table structure
my $sth_mysql = $dbh_mysql->prepare("DESCRIBE borrowers");
$sth_mysql->execute();

my $sqlite_create_sql = "CREATE TABLE borrowers ( \n";

my $result = $sth_mysql->fetchrow_hashref();
my $field = $result->{'Field'};
my $type = $result->{'Type'};
$sqlite_create_sql .= " $field $type ";

while ( my $result = $sth_mysql->fetchrow_hashref() ) {
  $field = $result->{'Field'};
  $type = $result->{'Type'};
  $sqlite_create_sql .= " , \n $field $type ";
}
$sth_mysql->finish();

$sqlite_create_sql .= " , \n total_fines decimal(28,6) "; ## Extra field to store the total fines for a borrower in.
$sqlite_create_sql .= " ) ";

my $sth_sqlite = $dbh_sqlite->prepare( $sqlite_create_sql );
$sth_sqlite->execute();
$sth_sqlite->finish();

## Import the data from the koha.borrowers table into our sqlite table
$sth_mysql = $dbh_mysql->prepare("SELECT * FROM borrowers ORDER BY borrowernumber DESC");
my $fields_count = $sth_mysql->execute();

print "Number of Borrowers: $fields_count\n";

while ( my $borrower = $sth_mysql->fetchrow_hashref ) {
  my @keys;
  my @values;

  print "Working on Borrower # $borrower->{'borrowernumber'} \n";

  my $sql = "INSERT INTO borrowers ( ";
  
  my $firstLine = 1;
  foreach my $key (keys %$borrower) {
    if ( $firstLine ) {
      $sql .= '?';
      $firstLine = 0;
    } else {
      $sql .= ', ?';
    }
    push( @keys, $key );
  }
  
  $sql .= " ) VALUES ( ";
  
  $firstLine = 1;
  foreach my $key (keys %$borrower) {
    my $data = $borrower->{$key};
    
    if ( $firstLine ) {
      $sql .= '?';
      $firstLine = 0;
    } else {
      $sql .= ', ?';
    }
    push( @values, $data );
  }

  $sql .= " ) ";

print "\n$sql\n";

  $sth_sqlite = $dbh_sqlite->prepare( $sql );
  $sth_sqlite->execute( @keys, @values );
  $sth_sqlite->finish();
}

## Import the fines from koha.accountlines into the sqlite db
$sth_mysql = $dbh_mysql->prepare( "SELECT DISTINCT borrowernumber, SUM( amountoutstanding ) AS total_fines
                                    FROM accountlines
                                    GROUP BY borrowernumber" );
while ( my $result = $sth_mysql->fetchrow_hashref() ) {
  my $borrowernumber = $result->{'borrowernumber'};
  my $total_fines = $result->{'total_fines'};
  
  print "Fines for Borrower # $borrowernumber are \$ $total_fines \n";
  
  my $sql = "UPDATE borrowers SET total_fines = ? WHERE borrowernumber = ?";
  
  $sth_sqlite = $dbh_sqlite->prepare( $sql );
  $sth_sqlite->execute( $total_fines, $borrowernumber );
  $sth_sqlite->finish();
}

## Create sqlite issues table with minimal information needed from koha tables issues, items, biblio, biblioitems
my $fields = GetIssuesFields();

$sqlite_create_sql = "CREATE TABLE issues ( \n";

my $firstField = 1;
foreach my $key (keys %$fields) {
  my $field = $key;
  my $type = $fields->{$key};

  if ( $firstField ) {
    $sqlite_create_sql .= " $field, $type ";
    $firstField = 0;
  } else {
    $sqlite_create_sql .= ", \n $field, $type ";
  }
}
$sqlite_create_sql .= " ) ";

$sth_sqlite = $dbh_sqlite->preapre( $sqlite_create_sql );
$sth_sqlite->execute();
$sth_sqlite->finish();

## Import open issues from the koha database
$sth_mysql = $dbh_mysql->prepare( "SELECT * FROM issues, items, biblioitems, biblio
                                    WHERE issues.itemnumber = items.itemnumber
                                    AND items.biblionumber = biblioitems.biblionumber
                                    AND items.biblionumber = biblio.biblionumber
                                    AND returndate IS NULL
                                    ORDER By borrowernumber DESC" );

while ( my $result = $sth_mysql->fetchrow_hashref ) {
  my @keys;
  my @values;

  print "Adding issue for Borrower # $result->{'borrowernumber'} \n";

  my $sql = "INSERT INTO issues ( ";
  
  my $firstLine = 1;
  foreach my $key (keys %$result) {
    if ( $firstLine ) {
      $sql .= '?';
      $firstLine = 0;
    } else {
      $sql .= ', ?';
    }
    push( @keys, $key );
  }
  
  $sql .= " ) VALUES ( ";
  
  $firstLine = 1;
  foreach my $key (keys %$result) {
    my $data = $result->{$key};
    
    if ( $firstLine ) {
      $sql .= '?';
      $firstLine = 0;
    } else {
      $sql .= ', ?';
    }
    push( @values, $data );
  }

  $sql .= " ) ";

print "\n$sql\n";

  $sth_sqlite = $dbh_sqlite->prepare( $sql );
  $sth_sqlite->execute( @keys, @values );
  $sth_sqlite->finish();
}


## This sub returns a hashref where the keys are all the fields in the given tables, and the data is the field's type
sub GetIssuesFields {
  my $dbh = C4::Context->dbh;
  
  my @tables = ( 'issues', 'items', 'biblioitems', 'biblio' );
  my $fields;
  
  foreach my $table ( @tables ) {
    my $sth = $dbh->prepare( 'DESCRIBE ?' );
    $sth->execute( $table );
    
    while ( my $result = $sth->fetchrow_hashref ) {
      my $field = $result->{'Field'};
      my $type = $result->{'Type'};
      
      $fields->{$field} = $type;
    }
    
    $sth->finish()
  }
  
  return $fields;
}