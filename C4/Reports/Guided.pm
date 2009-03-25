package C4::Reports::Guided;

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
use CGI;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;
use C4::Output;
use XML::Simple;
use XML::Dumper;
use C4::Debug;
# use Smart::Comments;
# use Data::Dumper;

BEGIN {
	# set the version for version checking
	$VERSION = 0.12;
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw(
		get_report_types get_report_areas get_columns build_query get_criteria
		save_report get_saved_reports execute_query get_saved_report create_compound run_compound
		get_column_type get_distinct_values save_dictionary get_from_dictionary
		delete_definition delete_report format_results get_sql
	);
}

our %table_areas;
$table_areas{'1'} =
  [ 'borrowers', 'statistics','items', 'biblioitems' ];    # circulation
$table_areas{'2'} = [ 'items', 'biblioitems', 'biblio' ];   # catalogue
$table_areas{'3'} = [ 'borrowers' ];        # patrons
$table_areas{'4'} = ['aqorders', 'biblio', 'items'];        # acquisitions
$table_areas{'5'} = [ 'borrowers', 'accountlines' ];        # accounts
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
$keys{'3'} = [ ];
$keys{'4'} = [
	'aqorders.biblionumber=biblio.biblionumber',
	'biblio.biblionumber=items.biblionumber'
];
$keys{'5'} = ['borrowers.borrowernumber=accountlines.borrowernumber'];

# have to do someting here to know if its dropdown, free text, date etc

our %criteria;
$criteria{'1'} = [
    'statistics.type',   'borrowers.categorycode',
    'statistics.branch',
    'biblioitems.publicationyear|date',
    'items.dateaccessioned|date'
];
$criteria{'2'} =
  [ 'items.holdingbranch', 'items.homebranch' ,'items.itemlost', 'items.location', 'items.ccode'];
$criteria{'3'} = ['borrowers.branchcode'];
$criteria{'4'} = ['aqorders.datereceived|date'];
$criteria{'5'} = ['borrowers.branchcode'];

if (C4::Context->preference('item-level_itypes')) {
    unshift @{ $criteria{'1'} }, 'items.itype';
    unshift @{ $criteria{'2'} }, 'items.itype';
} else {
    unshift @{ $criteria{'1'} }, 'biblioitems.itemtype';
    unshift @{ $criteria{'2'} }, 'biblioitems.itemtype';
}

=head1 NAME
   
C4::Reports::Guided - Module for generating guided reports 

=head1 SYNOPSIS

  use C4::Reports::Guided;

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
    my @reports = ( 'Circulation', 'Catalog', 'Patrons', 'Acquisitions', 'Accounts');
    my @reports2;
    for ( my $i = 0 ; $i < 5 ; $i++ ) {
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
    my ($area,$cgi) = @_;
    my $tables = $table_areas{$area};
    my @allcolumns;
    my $first = 1;
    foreach my $table (@$tables) {
        my @columns = _get_columns($table,$cgi, $first);
        $first = 0;
        push @allcolumns, @columns;
    }
    return ( \@allcolumns );
}

sub _get_columns {
    my ($tablename,$cgi, $first) = @_;
    my $dbh         = C4::Context->dbh();
    my $sth         = $dbh->prepare("show columns from $tablename");
    $sth->execute();
    my @columns;
	my $column_defs = _get_column_defs($cgi);
	my %tablehash;
	$tablehash{'table'}=$tablename;
    $tablehash{'__first__'} = $first;
	push @columns, \%tablehash;
    while ( my $data = $sth->fetchrow_arrayref() ) {
        my %temphash;
        $temphash{'name'}        = "$tablename.$data->[0]";
        $temphash{'description'} = $column_defs->{"$tablename.$data->[0]"};
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
    my ( $columns, $criteria, $orderby, $area, $totals, $definition ) = @_;
### $orderby
    my $keys   = $keys{$area};
    my $tables = $table_areas{$area};

    my $sql =
      _build_query( $tables, $columns, $criteria, $keys, $orderby, $totals, $definition );
    return ($sql);
}

sub _build_query {
    my ( $tables, $columns, $criteria, $keys, $orderby, $totals, $definition) = @_;
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
	if ($definition){
		my @definitions = split(',',$definition);
		my $deftext;
		foreach my $def (@definitions){
			my $defin=get_from_dictionary('',$def);
			$deftext .=" ".$defin->[0]->{'saved_sql'};
		}
		if ($query =~ /WHERE/i){
			$query .= $deftext;
		}
		else {
			$deftext  =~ s/AND/WHERE/;
			$query .= $deftext;			
		}
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

=item get_criteria($area,$cgi);

Returns an arraref to hashrefs suitable for using in a tmpl_loop. With the criteria and available values.

=cut

sub get_criteria {
    my ($area,$cgi) = @_;
    my $dbh    = C4::Context->dbh();
    my $crit   = $criteria{$area};
	my $column_defs = _get_column_defs($cgi);
    my @criteria_array;
    foreach my $localcrit (@$crit) {
        my ( $value, $type )   = split( /\|/, $localcrit );
        my ( $table, $column ) = split( /\./, $value );
        if ( $type eq 'date' ) {
			my %temp;
            $temp{'name'}   = $value;
            $temp{'date'}   = 1;
			$temp{'description'} = $column_defs->{$value};
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
			$temp{'description'} = $column_defs->{$value};
            $temp{'values'} = \@values;
            push @criteria_array, \%temp;
        }
    }
    return ( \@criteria_array );
}

=item execute_query

=over

($results, $total, $error) = execute_query($sql, $type, $offset, $limit, $format, $id)

=back

    When passed C<$sql>, this function returns an array ref containing a result set
    suitably formatted for display in html or for output as a flat file when passed in
    C<$format> and C<$id>. It also returns the C<$total> records available for the
    supplied query. If passed any query other than a SELECT, or if there is a db error,
    C<$errors> an array ref is returned containing the error after this manner:

    C<$error->{'sqlerr'}> contains the offending SQL keyword.
    C<$error->{'queryerr'}> contains the native db engine error returned for the query.
    
    Valid values for C<$format> are 'text,' 'tab,' 'csv,' or 'url. C<$sql>, C<$type>,
    C<$offset>, and C<$limit> are required parameters. If a valid C<$format> is passed
    in, C<$offset> and C<$limit> are ignored for obvious reasons. A LIMIT specified by
    the user in a user-supplied SQL query WILL apply in any case.

=cut

# FIXME: This needs to be generalized to reports in general

sub execute_query ($$$$;$$) {
    my ( $sql, $type, $offset, $limit, $format, $id ) = @_;
    my @params;
    my $total = 0;
    my ($useroffset, $userlimit);
    my @errors = ();
    my $error = {};
    my $sqlerr = 0;
    if ($sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i) {
        $sqlerr = 1;
        $error->{'sqlerr'} = $1;
        push @errors, $error;
    } elsif ($sql !~ /^(SELECT)/i) {
        $sqlerr = 1;
        $error->{'queryerr'} = 'Missing SELECT';
        push @errors, $error;
    }
    if ($sqlerr == 0) {
        my $dbh = C4::Context->dbh();
        unless ($format eq 'text' || $format eq 'tab' || $format eq 'csv' || $format eq 'url'){
            # Grab offset/limit from user supplied LIMIT and drop the LIMIT so we can control pagination
            if ($sql =~ /LIMIT/i) {
                $sql =~ s/LIMIT\W?(\d+)?\,?\W+?(\d+)//ig;
                $debug and warn "User has supplied LIMIT\n";
                $useroffset = $1;
                $userlimit = $2;
                $debug and warn "User supplied offset = $useroffset, limit = $userlimit\n";
                $offset += $useroffset if $useroffset;
                # keep track of where we are if there is a user supplied LIMIT
                if ( $offset + $limit > $userlimit ) {
                    $limit = $userlimit - $offset;
                }
            }
            my $countsql = $sql;
            $sql .= " LIMIT ?, ?";
            $debug and warn "Passing query with params offset = $offset, limit = $limit\n";
            @params = ($offset, $limit);
            # Modify the query passed in to create a count query... (I think this covers all cases -crn)
            $countsql =~ s/\bSELECT\W+(?:\w+\W+){1,}?FROM\b|\bSELECT\W\*\WFROM\b/SELECT count(*) FROM /ig;
            $debug and warn "original query: $sql\n";
            $debug and warn "count query: $countsql\n";
            my $sth1 = $dbh->prepare($countsql);
            $sth1->execute();
            $total = $sth1->fetchrow();
            $debug and warn "total records for this query: $total\n";
            $total = $userlimit if defined($userlimit) and $userlimit < $total;     # we will never exceed a user defined LIMIT and...
            $userlimit = $total if defined($userlimit) and $userlimit > $total;     # we will never exceed the total number of records available to satisfy the query
        }
        my $sth = $dbh->prepare($sql);
        $sth->execute(@params);
        my $colnames=$sth->{'NAME'};
        my @results;
        my $row;
        my %temphash;
        $row = join ('</th><th>',@$colnames);
        $row = "<tr><th>$row</th></tr>";
        $temphash{'row'} = $row;
        push @results, \%temphash;
        my $string;
        if ($format eq 'tab') {
            $string = join("\t",@$colnames);
        }
        elsif ($format eq 'csv') {
            $string = join(",",@$colnames);
        }
        my @xmlarray;
        while ( my @data = $sth->fetchrow_array() ) {
            # if the field is a date field, it needs formatting
            foreach my $data (@data) {
                next unless $data =~ C4::Dates->regexp("iso");
                my $date = C4::Dates->new($data, "iso");
                $data = $date->output();
            }
            # tabular
            my %temphash;
            my $row = join( '</td><td>', @data );
            $row = "<tr><td>$row</td></tr>";
            $temphash{'row'} = $row;
            if ($format eq 'text') {
                $string .= "\n" . $row;
            }
            elsif ($format eq 'tab'){
                $row = join("\t",@data);
                $string .="\n" . $row;
            }
            elsif ($format eq 'csv'){
                $row = join(",",@data);
                $string .="\n" . $row;
            }
            elsif ($format eq 'url'){
                my $temphash;
                @$temphash{@$colnames}=@data;
                push @xmlarray,$temphash;
            }
            push @results, \%temphash;
        }
        if (defined($sth->errstr)) {
            $error->{'queryerr'} = $sth->errstr;
            push @errors, $error;
            warn "Database returned: $sth->errstr";
        }
        if ( $format eq 'text' || $format eq 'tab' || $format eq 'csv' ) {
            return $string, $total, \@errors;
        }
        elsif ($format eq 'url') {
            my $url = "/cgi-bin/koha/reports/guided_reports.pl?phase=retrieve%20results&id=$id";
            my $dump = new XML::Dumper;
            my $xml = $dump->pl2xml( \@xmlarray );
            store_results($id,$xml);
            return $url, $total, \@errors;
        }
        else {
            return \@results, $total, \@errors;
        }
    } else {
        return undef, undef, \@errors;
    }
}

=item save_report($sql,$name,$type,$notes)

Given some sql and a name this will saved it so that it can resued

=cut

sub save_report {
    my ( $sql, $name, $type, $notes ) = @_;
    my $dbh = C4::Context->dbh();
    $sql =~ s/(\s*\;\s*)$//; # removes trailing whitespace and /;/
    my $query =
"INSERT INTO saved_sql (borrowernumber,date_created,last_modified,savedsql,report_name,type,notes)  VALUES (?,now(),now(),?,?,?,?)";
    my $sth = $dbh->prepare($query);
    $sth->execute( 0, $sql, $name, $type, $notes );
    $sth->finish();

}

sub store_results {
	my ($id,$xml)=@_;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM saved_reports WHERE report_id=?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	if (my $data=$sth->fetchrow_hashref()){
		my $query2 = "UPDATE saved_reports SET report=?,date_run=now() WHERE report_id=?";
		my $sth2 = $dbh->prepare($query2);
	    $sth2->execute($xml,$id);
		$sth2->finish();
	}
	else {
		my $query2 = "INSERT INTO saved_reports (report_id,report,date_run) VALUES (?,?,now())";
		my $sth2 = $dbh->prepare($query2);
		$sth2->execute($id,$xml);
		$sth2->finish();
	}
	$sth->finish();
}

sub format_results {
	my ($id) = @_;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM saved_reports WHERE report_id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	my $data = $sth->fetchrow_hashref();
	my $dump = new XML::Dumper;
	my $perl = $dump->xml2pl( $data->{'report'} );
	foreach my $row (@$perl) {
		my $htmlrow="<tr>";
		foreach my $key (keys %$row){
			$htmlrow .= "<td>$row->{$key}</td>";
		}
		$htmlrow .= "</tr>";
		$row->{'row'} = $htmlrow;
	}
	$sth->finish;
	$query = "SELECT * FROM saved_sql WHERE id = ?";
	$sth = $dbh->prepare($query);
	$sth->execute($id);
	$data = $sth->fetchrow_hashref();
    $sth->finish();
	return ($perl,$data->{'report_name'},$data->{'notes'});	
}	

sub delete_report {
	my ( $id ) = @_;
	my $dbh = C4::Context->dbh();
	my $query = "DELETE FROM saved_sql WHERE id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	$sth->finish();
}	

sub get_saved_reports {
    my $dbh   = C4::Context->dbh();
    my $query = "SELECT *,saved_sql.id AS id FROM saved_sql 
    LEFT JOIN saved_reports ON saved_reports.report_id = saved_sql.id
    ORDER by date_created";
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
    return ( $data->{'savedsql'}, $data->{'type'}, $data->{'report_name'}, $data->{'notes'} );
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
			if ($info->{'TYPE_NAME'} eq 'CHAR' || $info->{'TYPE_NAME'} eq 'VARCHAR'){
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
	my ($area,$id) = @_;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM reports_dictionary";
	if ($area){
		$query.= " WHERE area = ?";
	}
	elsif ($id){
		$query.= " WHERE id = ?"
	}
	my $sth = $dbh->prepare($query);
	if ($id){
		$sth->execute($id);
	}
	elsif ($area) {
		$sth->execute($area);
	}
	else {
		$sth->execute();
	}
	my @loop;
	my @reports = ( 'Circulation', 'Catalog', 'Patrons', 'Acquisitions', 'Accounts');
	while (my $data = $sth->fetchrow_hashref()){
		$data->{'areaname'}=$reports[$data->{'area'}-1];
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

sub get_sql {
	my ($id) = @_;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM saved_sql WHERE id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	my $data=$sth->fetchrow_hashref();
	$sth->finish();	
	return $data->{'savedsql'};
}

sub _get_column_defs {
	my ($cgi) = @_;
	my %columns;
	my $columns_def_file = "columns.def";
	my $htdocs = C4::Context->config('intrahtdocs');                       
	my $section='intranet';
	my ($theme, $lang) = themelanguage($htdocs, $columns_def_file, $section,$cgi);

	my $full_path_to_columns_def_file="$htdocs/$theme/$lang/$columns_def_file";    
	open (COLUMNS,$full_path_to_columns_def_file);
	while (my $input = <COLUMNS>){
		my @row =split(/\t/,$input);
		$columns{$row[0]}=$row[1];
	}

	close COLUMNS;
	return \%columns;
}
1;
__END__

=back

=head1 AUTHOR

Chris Cormack <crc@liblime.com>

=cut
