package C4::Reports;

# Copyright 2007 Liblime Ltd
#
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

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;
use C4::Output;
# use Smart::Comments;
# use Data::Dumper;

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT =
  qw(get_report_types get_report_areas get_columns build_query get_criteria
  save_report get_saved_reports execute_query get_saved_report create_compound run_compound
  get_column_type get_distinct_values save_dictionary get_from_dictionary
  delete_definition);

our %table_areas;
$table_areas{'1'} =
  [ 'borrowers', 'statistics','items', 'biblioitems' ];    # circulation
$table_areas{'2'} = [ 'items', 'biblioitems', 'biblio' ];   # catalogue
$table_areas{'3'} = [ 'borrowers', 'accountlines' ];        # patrons
$table_areas{'4'} = ['aqorders', 'biblio', 'items'];        # acquisitions

our %keys;
$keys{'1'} = [
    'statistics.borrowernumber=borrowers.borrowernumber',
    'items.itemnumber = statistics.itemnumber',
    'biblioitems.biblioitemnumber = items.biblioitemnumber'
];
$keys{'2'} = [
    'items.biblioitemnumber=biblioitems.biblioitemnumber',
    'biblioitems.biblionumber=biblio.biblionumber'
];
$keys{'3'} = ['borrowers.borrowernumber=accountlines.borrowernumber'];
$keys{'4'} = [
	'aqorders.biblionumber=biblio.biblionumber',
	'biblio.biblionumber=items.biblionumber'
];

# have to do someting here to know if its dropdown, free text, date etc

our %criteria;
$criteria{'1'} = [
    'statistics.type',   'borrowers.categorycode',
    'statistics.branch', 'biblioitems.itemtype',
    'biblioitems.publicationyear|date',
    'items.dateaccessioned|date'
];
$criteria{'2'} =
  [ 'biblioitems.itemtype', 'items.holdingbranch', 'items.homebranch' ,'items.itemlost'];
$criteria{'3'} = ['borrowers.branchcode'];
$criteria{'4'} = ['aqorders.datereceived|date'];


our %columns;
my $columns_def_file = "columns.def";
my $htdocs = C4::Context->config('intrahtdocs');                       
my $section='intranet';
my ($theme, $lang) = themelanguage($htdocs, $columns_def_file, $section);                                                                                 

my $columns_def_file="$htdocs/$theme/$lang/$columns_def_file";    
open (COLUMNS,$columns_def_file);
while (my $input = <COLUMNS>){
	my @row =split(/\t/,$input);
	$columns{$row[0]}=$row[1];
}

close COLUMNS;

=head1 NAME
   
C4::Reports - Module for generating reports 

=head1 SYNOPSIS

  use C4::Reports;

=head1 DESCRIPTION


=head1 METHODS

=over 2

=cut

=item get_report_types()

This will return a list of all the available report types

=cut

sub get_report_types {
    my $dbh = C4::Context->dbh();

    # FIXME these should be in the database perhaps
    my @reports = ( 'Tabular', 'Summary', 'Matrix' );
    my @reports2;
    for ( my $i = 0 ; $i < 3 ; $i++ ) {
        my %hashrep;
        $hashrep{id}   = $i + 1;
        $hashrep{name} = $reports[$i];
        push @reports2, \%hashrep;
    }
    return ( \@reports2 );

}

=item get_report_areas()

This will return a list of all the available report areas

=cut

sub get_report_areas {
    my $dbh = C4::Context->dbh();

    # FIXME these should be in the database
    my @reports = ( 'Circulation', 'Catalog', 'Patrons', 'Acquisitions' );
    my @reports2;
    for ( my $i = 0 ; $i < 4 ; $i++ ) {
        my %hashrep;
        $hashrep{id}   = $i + 1;
        $hashrep{name} = $reports[$i];
        push @reports2, \%hashrep;
    }
    return ( \@reports2 );

}

=item get_all_tables()

This will return a list of all tables in the database 

=cut

sub get_all_tables {
    my $dbh   = C4::Context->dbh();
    my $query = "SHOW TABLES";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my @tables;
    while ( my $data = $sth->fetchrow_arrayref() ) {
        push @tables, $data->[0];
    }
    $sth->finish();
    return ( \@tables );

}

=item get_columns($area)

This will return a list of all columns for a report area

=cut

sub get_columns {

    # this calls the internal fucntion _get_columns
    my ($area) = @_;
    my $tables = $table_areas{$area};
    my @allcolumns;
    foreach my $table (@$tables) {
        my @columns = _get_columns($table);
        push @allcolumns, @columns;
    }
    return ( \@allcolumns );
}

sub _get_columns {
    my ($tablename) = @_;
    my $dbh         = C4::Context->dbh();
    my $sth         = $dbh->prepare("show columns from $tablename");
    $sth->execute();
    my @columns;
	my %tablehash;
	$tablehash{'table'}=$tablename;
	push @columns, \%tablehash;
    while ( my $data = $sth->fetchrow_arrayref() ) {
        my %temphash;
        $temphash{'name'}        = "$tablename.$data->[0]";
        $temphash{'description'} = $columns{"$tablename.$data->[0]"};
        push @columns, \%temphash;
    }
    $sth->finish();
    return (@columns);
}

=item build_query($columns,$criteria,$orderby,$area)

This will build the sql needed to return the results asked for, 
$columns is expected to be of the format tablename.columnname.
This is what get_columns returns.

=cut

sub build_query {
    my ( $columns, $criteria, $orderby, $area, $totals ) = @_;
### $orderby
    my $keys   = $keys{$area};
    my $tables = $table_areas{$area};

    my $sql =
      _build_query( $tables, $columns, $criteria, $keys, $orderby, $totals );
    return ($sql);
}

sub _build_query {
    my ( $tables, $columns, $criteria, $keys, $orderby, $totals ) = @_;
### $orderby
    # $keys is an array of joining constraints
    my $dbh           = C4::Context->dbh();
    my $joinedtables  = join( ',', @$tables );
    my $joinedcolumns = join( ',', @$columns );
    my $joinedkeys    = join( ' AND ', @$keys );
    my $query =
      "SELECT $totals $joinedcolumns FROM $tables->[0] ";
	for (my $i=1;$i<@$tables;$i++){
		$query .= "LEFT JOIN $tables->[$i] on ($keys->[$i-1]) ";
	}

    if ($criteria) {
		$criteria =~ s/AND/WHERE/;
        $query .= " $criteria";
    }
    if ($totals) {
        my $groupby;
        my @totcolumns = split( ',', $totals );
        foreach my $total (@totcolumns) {
            if ( $total =~ /\((.*)\)/ ) {
                if ( $groupby eq '' ) {
                    $groupby = " GROUP BY $1";
                }
                else {
                    $groupby .= ",$1";
                }
            }
        }
        $query .= $groupby;
    }
    if ($orderby) {
        $query .= $orderby;
    }
    return ($query);
}

=item get_criteria($area);

Returns an arraref to hashrefs suitable for using in a tmpl_loop. With the criteria and available values.

=cut

sub get_criteria {
    my ($area) = @_;
    my $dbh    = C4::Context->dbh();
    my $crit   = $criteria{$area};
    my @criteria_array;
    foreach my $localcrit (@$crit) {
        my ( $value, $type )   = split( /\|/, $localcrit );
        my ( $table, $column ) = split( /\./, $value );
        if ( $type eq 'date' ) {
			my %temp;
            $temp{'name'}   = $value;
            $temp{'date'}   = 1;
			$temp{'description'} = $columns{$value};
            push @criteria_array, \%temp;
        }
        else {

            my $query =
              "SELECT distinct($column) as availablevalues FROM $table";
            my $sth = $dbh->prepare($query);
            $sth->execute();
            my @values;
            while ( my $row = $sth->fetchrow_hashref() ) {
                push @values, $row;
                ### $row;
            }
            $sth->finish();
            my %temp;
            $temp{'name'}   = $value;
			$temp{'description'} = $columns{$value};
            $temp{'values'} = \@values;
            push @criteria_array, \%temp;
        }
    }
    return ( \@criteria_array );
}

sub execute_query {
    my ( $sql, $type, $format ) = @_;
    my $dbh = C4::Context->dbh();

    # take this line out when in production
    $sql .= " LIMIT 10";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
	my $colnames=$sth->{'NAME'};
	my @results;
	my $row = join ('</th><th>',@$colnames);
	$row = "<tr><th>$row</th></tr>";
	my %temphash;
	$temphash{'row'} = $row;
	push @results, \%temphash;
    
    my $string;
    while ( my @data = $sth->fetchrow_array() ) {

            # tabular
            my %temphash;
            my $row = join( '</td><td>', @data );
            $row = "<tr><td>$row</td></tr>";
            $temphash{'row'} = $row;
            if ( $format eq 'text' ) {
                $string .= "\n" . $row;
            }
			if ($format eq 'tab' ){
				$row = join("\t",@data);
				$string .="\n" . $row;
			}
			if ($format eq 'csv' ){
				$row = join(",",@data);
				$string .="\n" . $row;
			}

            push @results, \%temphash;
#        }
    }
    $sth->finish();
    if ( $format eq 'text' || $format eq 'tab' || $format eq 'csv') {
        return $string;
    }
    else {
        return ( \@results );
    }
}

=item save_report($sql,$name,$type,$notes)

Given some sql and a name this will saved it so that it can resued

=cut

sub save_report {
    my ( $sql, $name, $type, $notes ) = @_;
    my $dbh = C4::Context->dbh();
    my $query =
"INSERT INTO saved_sql (borrowernumber,date_created,last_modified,savedsql,report_name,type,notes)  VALUES (?,now(),now(),?,?,?,?)";
    my $sth = $dbh->prepare($query);
    $sth->execute( 0, $sql, $name, $type, $notes );
    $sth->finish();

}

sub get_saved_reports {
    my $dbh   = C4::Context->dbh();
    my $query = "SELECT * FROM saved_sql ORDER by date_created";
    my $sth   = $dbh->prepare($query);
    $sth->execute();
    my @reports;
    while ( my $data = $sth->fetchrow_hashref() ) {
        push @reports, $data;
    }
    $sth->finish();
    return ( \@reports );
}

sub get_saved_report {
    my ($id)  = @_;
    my $dbh   = C4::Context->dbh();
    my $query = " SELECT * FROM saved_sql WHERE id = ?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($id);
    my $data = $sth->fetchrow_hashref();
    $sth->finish();
    return ( $data->{'savedsql'}, $data->{'type'} );
}

=item create_compound($masterID,$subreportID)

This will take 2 reports and create a compound report using both of them

=cut

sub create_compound {
	my ($masterID,$subreportID) = @_;
	my $dbh = C4::Context->dbh();
	# get the reports
	my ($mastersql,$mastertype) = get_saved_report($masterID);
	my ($subsql,$subtype) = get_saved_report($subreportID);
	
	# now we have to do some checking to see how these two will fit together
	# or if they will
	my ($mastertables,$subtables);
	if ($mastersql =~ / from (.*) where /i){ 
		$mastertables = $1;
	}
	if ($subsql =~ / from (.*) where /i){
		$subtables = $1;
	}
	return ($mastertables,$subtables);
}

=item get_column_type($column)

This takes a column name of the format table.column and will return what type it is
(free text, set values, date)

=cut

sub get_column_type {
	my ($tablecolumn) = @_;
	my ($table,$column) = split(/\./,$tablecolumn);
	my $dbh = C4::Context->dbh();
	my $catalog;
	my $schema;

	# mysql doesnt support a column selection, set column to %
	my $tempcolumn='%';
	my $sth = $dbh->column_info( $catalog, $schema, $table, $tempcolumn ) || die $dbh->errstr;
	while (my $info = $sth->fetchrow_hashref()){
		if ($info->{'COLUMN_NAME'} eq $column){
			#column we want
			if ($info->{'TYPE_NAME'} eq 'CHAR'){
				$info->{'TYPE_NAME'} = 'distinct';
			}
			return $info->{'TYPE_NAME'};		
		}
	}
	$sth->finish();
}

=item get_distinct_values($column)

Given a column name, return an arrary ref of hashrefs suitable for use as a tmpl_loop 
with the distinct values of the column

=cut

sub get_distinct_values {
	my ($tablecolumn) = @_;
	my ($table,$column) = split(/\./,$tablecolumn);
	my $dbh = C4::Context->dbh();
	my $query =
	  "SELECT distinct($column) as availablevalues FROM $table";
	my $sth = $dbh->prepare($query);
	$sth->execute();
	my @values;
	while ( my $row = $sth->fetchrow_hashref() ) {
		push @values, $row;
	}
	$sth->finish();
	return \@values;
}	

sub save_dictionary {
	my ($name,$description,$sql,$area) = @_;
	my $dbh = C4::Context->dbh();
	my $query = "INSERT INTO reports_dictionary (name,description,saved_sql,area,date_created,date_modified)
  VALUES (?,?,?,?,now(),now())";
    my $sth = $dbh->prepare($query);
    $sth->execute($name,$description,$sql,$area) || return 0;
    $sth->finish();
    return 1;
}

sub get_from_dictionary {
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM reports_dictionary";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	my @loop;
	while (my $data = $sth->fetchrow_hashref()){
		push @loop,$data;
		
		}
	$sth->finish();
	return (\@loop);
}

sub delete_definition {
	my ($id) = @_;
	my $dbh = C4::Context->dbh();
	my $query = "DELETE FROM reports_dictionary WHERE id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	$sth->finish();
	}
=head1 AUTHOR

Chris Cormack <crc@liblime.com>

=cut

1;
