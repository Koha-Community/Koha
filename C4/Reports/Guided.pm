package C4::Reports::Guided;

# Copyright 2007 Liblime Ltd
#
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

use strict;
#use warnings; FIXME - Bug 2505 this module needs a lot of repair to run clean under warnings
use CGI;
use Carp;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
use C4::Context;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Templates qw/themelanguage/;
use C4::Koha;
use C4::Output;
use XML::Simple;
use XML::Dumper;
use C4::Debug;
# use Smart::Comments;
# use Data::Dumper;

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      get_report_types get_report_areas get_report_groups get_columns build_query get_criteria
      save_report get_saved_reports execute_query get_saved_report create_compound run_compound
      get_column_type get_distinct_values save_dictionary get_from_dictionary
      delete_definition delete_report format_results get_sql
      nb_rows update_sql build_authorised_value_list
      GetReservedAuthorisedValues
      GetParametersFromSQL
      IsAuthorisedValueValid
      ValidateSQLParameters
    );
}

=head1 NAME

C4::Reports::Guided - Module for generating guided reports 

=head1 SYNOPSIS

  use C4::Reports::Guided;

=head1 DESCRIPTION

=cut

=head1 METHODS

=head2 get_report_areas

This will return a list of all the available report areas

=cut

sub get_area_name_sql_snippet {
    my @REPORT_AREA = (
        [CIRC => "Circulation"],
        [CAT  => "Catalogue"],
        [PAT  => "Patrons"],
        [ACQ  => "Acquisition"],
        [ACC  => "Accounts"],
    );

    return "CASE report_area " .
    join (" ", map "WHEN '$_->[0]' THEN '$_->[1]'", @REPORT_AREA) .
    " END AS areaname";
}

sub get_report_areas {

    my $report_areas = [ 'CIRC', 'CAT', 'PAT', 'ACQ', 'ACC' ];

    return $report_areas;
}

sub get_table_areas {
    return (
    CIRC => [ 'borrowers', 'statistics', 'items', 'biblioitems' ],
    CAT  => [ 'items', 'biblioitems', 'biblio' ],
    PAT  => ['borrowers'],
    ACQ  => [ 'aqorders', 'biblio', 'items' ],
    ACC  => [ 'borrowers', 'accountlines' ],
    );
}

=head2 get_report_types

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

=head2 get_report_groups

This will return a list of all the available report areas with groups

=cut

sub get_report_groups {
    my $dbh = C4::Context->dbh();

    my $groups = GetAuthorisedValues('REPORT_GROUP');
    my $subgroups = GetAuthorisedValues('REPORT_SUBGROUP');

    my %groups_with_subgroups = map { $_->{authorised_value} => {
                        name => $_->{lib},
                        groups => {}
                    } } @$groups;
    foreach (@$subgroups) {
        my $sg = $_->{authorised_value};
        my $g = $_->{lib_opac}
          or warn( qq{REPORT_SUBGROUP "$sg" without REPORT_GROUP (lib_opac)} ),
             next;
        my $g_sg = $groups_with_subgroups{$g}
          or warn( qq{REPORT_SUBGROUP "$sg" with invalid REPORT_GROUP "$g"} ),
             next;
        $g_sg->{subgroups}{$sg} = $_->{lib};
    }
    return \%groups_with_subgroups
}

=head2 get_all_tables

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

=head2 get_columns($area)

This will return a list of all columns for a report area

=cut

sub get_columns {

    # this calls the internal fucntion _get_columns
    my ( $area, $cgi ) = @_;
    my %table_areas = get_table_areas;
    my $tables = $table_areas{$area}
      or die qq{Unsuported report area "$area"};

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

=head2 build_query($columns,$criteria,$orderby,$area)

This will build the sql needed to return the results asked for, 
$columns is expected to be of the format tablename.columnname.
This is what get_columns returns.

=cut

sub build_query {
    my ( $columns, $criteria, $orderby, $area, $totals, $definition ) = @_;

    my %keys = (
        CIRC => [ 'statistics.borrowernumber=borrowers.borrowernumber',
                  'items.itemnumber = statistics.itemnumber',
                  'biblioitems.biblioitemnumber = items.biblioitemnumber' ],
        CAT  => [ 'items.biblioitemnumber=biblioitems.biblioitemnumber',
                  'biblioitems.biblionumber=biblio.biblionumber' ],
        PAT  => [],
        ACQ  => [ 'aqorders.biblionumber=biblio.biblionumber',
                  'biblio.biblionumber=items.biblionumber' ],
        ACC  => ['borrowers.borrowernumber=accountlines.borrowernumber'],
    );


### $orderby
    my $keys   = $keys{$area};
    my %table_areas = get_table_areas;
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

=head2 get_criteria($area,$cgi);

Returns an arraref to hashrefs suitable for using in a tmpl_loop. With the criteria and available values.

=cut

sub get_criteria {
    my ($area,$cgi) = @_;
    my $dbh    = C4::Context->dbh();

    # have to do someting here to know if its dropdown, free text, date etc
    my %criteria = (
        CIRC => [ 'statistics.type', 'borrowers.categorycode', 'statistics.branch',
                  'biblioitems.publicationyear|date', 'items.dateaccessioned|date' ],
        CAT  => [ 'items.itemnumber|textrange', 'items.biblionumber|textrange',
                  'items.barcode|textrange', 'biblio.frameworkcode',
                  'items.holdingbranch', 'items.homebranch',
                  'biblio.datecreated|daterange', 'biblio.timestamp|daterange',
                  'items.onloan|daterange', 'items.ccode',
                  'items.itemcallnumber|textrange', 'items.itype', 'items.itemlost',
                  'items.location' ],
        PAT  => [ 'borrowers.branchcode', 'borrowers.categorycode' ],
        ACQ  => ['aqorders.datereceived|date'],
        ACC  => [ 'borrowers.branchcode', 'borrowers.categorycode' ],
    );

    # Adds itemtypes to criteria, according to the syspref
    if ( C4::Context->preference('item-level_itypes') ) {
        unshift @{ $criteria{'CIRC'} }, 'items.itype';
        unshift @{ $criteria{'CAT'} }, 'items.itype';
    } else {
        unshift @{ $criteria{'CIRC'} }, 'biblioitems.itemtype';
        unshift @{ $criteria{'CAT'} }, 'biblioitems.itemtype';
    }


    my $crit   = $criteria{$area};
    my $column_defs = _get_column_defs($cgi);
    my @criteria_array;
    foreach my $localcrit (@$crit) {
        my ( $value, $type )   = split( /\|/, $localcrit );
        my ( $table, $column ) = split( /\./, $value );
        if ($type eq 'textrange') {
            my %temp;
            $temp{'name'}        = $value;
            $temp{'from'}        = "from_" . $value;
            $temp{'to'}          = "to_" . $value;
            $temp{'textrange'}   = 1;
            $temp{'description'} = $column_defs->{$value};
            push @criteria_array, \%temp;
        }
        elsif ($type eq 'date') {
            my %temp;
            $temp{'name'}        = $value;
            $temp{'date'}        = 1;
            $temp{'description'} = $column_defs->{$value};
            push @criteria_array, \%temp;
        }
        elsif ($type eq 'daterange') {
            my %temp;
            $temp{'name'}        = $value;
            $temp{'from'}        = "from_" . $value;
            $temp{'to'}          = "to_" . $value;
            $temp{'daterange'}   = 1;
            $temp{'description'} = $column_defs->{$value};
            push @criteria_array, \%temp;
        }
        else {
            my $query =
            "SELECT distinct($column) as availablevalues FROM $table";
            my $sth = $dbh->prepare($query);
            $sth->execute();
            my @values;
            # push the runtime choosing option
            my $list;
            $list='branches' if $column eq 'branchcode' or $column eq 'holdingbranch' or $column eq 'homebranch';
            $list='categorycode' if $column eq 'categorycode';
            $list='itemtype' if $column eq 'itype';
            $list='ccode' if $column eq 'ccode';
            # TODO : improve to let the librarian choose the description at runtime
            push @values, { availablevalues => "<<$column".($list?"|$list":'').">>" };
            while ( my $row = $sth->fetchrow_hashref() ) {
                push @values, $row;
                if ($row->{'availablevalues'} eq '') { $row->{'default'} = 1 };
            }
            $sth->finish();

            my %temp;
            $temp{'name'}        = $value;
            $temp{'description'} = $column_defs->{$value};
            $temp{'values'}      = \@values;

            push @criteria_array, \%temp;
        }

    }
    return ( \@criteria_array );
}

sub nb_rows {
    my $sql = shift or return;
    my $sth = C4::Context->dbh->prepare($sql);
    $sth->execute();
    my $rows = $sth->fetchall_arrayref();
    return scalar (@$rows);
}

=head2 execute_query

  ($sth, $error) = execute_query($sql, $offset, $limit[, \@sql_params])


This function returns a DBI statement handler from which the caller can
fetch the results of the SQL passed via C<$sql>.

If passed any query other than a SELECT, or if there is a DB error,
C<$errors> is returned, and is a hashref containing the error after this
manner:

C<$error->{'sqlerr'}> contains the offending SQL keyword.
C<$error->{'queryerr'}> contains the native db engine error returned
for the query.

C<$offset>, and C<$limit> are required parameters.

C<\@sql_params> is an optional list of parameter values to paste in.
The caller is reponsible for making sure that C<$sql> has placeholders
and that the number placeholders matches the number of parameters.

=cut

# returns $sql, $offset, $limit
# $sql returned will be transformed to:
#  ~ remove any LIMIT clause
#  ~ repace SELECT clause w/ SELECT count(*)

sub select_2_select_count {
    # Modify the query passed in to create a count query... (I think this covers all cases -crn)
    my ($sql) = strip_limit(shift) or return;
    $sql =~ s/\bSELECT\W+(?:\w+\W+){1,}?FROM\b|\bSELECT\W\*\WFROM\b/SELECT count(*) FROM /ig;
    return $sql;
}

# This removes the LIMIT from the query so that a custom one can be specified.
# Usage:
#   ($new_sql, $offset, $limit) = strip_limit($sql);
#
# Where:
#   $sql is the query to modify
#   $new_sql is the resulting query
#   $offset is the offset value, if the LIMIT was the two-argument form,
#       0 if it wasn't otherwise given.
#   $limit is the limit value
#
# Notes:
#   * This makes an effort to not break subqueries that have their own
#     LIMIT specified. It does that by only removing a LIMIT if it comes after
#     a WHERE clause (which isn't perfect, but at least should make more cases
#     work - subqueries with a limit in the WHERE will still break.)
#   * If your query doesn't have a WHERE clause then all LIMITs will be
#     removed. This may break some subqueries, but is hopefully rare enough
#     to not be a big issue.
sub strip_limit {
    my ($sql) = @_;

    return unless $sql;
    return ($sql, 0, undef) unless $sql =~ /\bLIMIT\b/i;

    # Two options: if there's no WHERE clause in the SQL, we simply capture
    # any LIMIT that's there. If there is a WHERE, we make sure that we only
    # capture a LIMIT after the last one. This prevents stomping on subqueries.
    if ($sql !~ /\bWHERE\b/i) {
        (my $res = $sql) =~ s/\bLIMIT\b\s*(\d+)(\s*\,\s*(\d+))?\s*/ /ig;
        return ($res, (defined $2 ? $1 : 0), (defined $3 ? $3 : $1));
    } else {
        my $res = $sql;
        $res =~ m/.*\bWHERE\b/gsi;
        $res =~ s/\G(.*)\bLIMIT\b\s*(\d+)(\s*\,\s*(\d+))?\s*/$1 /is;
        return ($res, (defined $3 ? $2 : 0), (defined $4 ? $4 : $2));
    }
}

sub execute_query {

    my ( $sql, $offset, $limit, $sql_params ) = @_;

    $sql_params = [] unless defined $sql_params;

    # check parameters
    unless ($sql) {
        carp "execute_query() called without SQL argument";
        return;
    }
    $offset = 0    unless $offset;
    $limit  = 999999 unless $limit;
    $debug and print STDERR "execute_query($sql, $offset, $limit)\n";
    if ($sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i) {
        return (undef, {  sqlerr => $1} );
    } elsif ($sql !~ /^\s*SELECT\b\s*/i) {
        return (undef, { queryerr => 'Missing SELECT'} );
    }

    my ($useroffset, $userlimit);

    # Grab offset/limit from user supplied LIMIT and drop the LIMIT so we can control pagination
    ($sql, $useroffset, $userlimit) = strip_limit($sql);
    $debug and warn sprintf "User has supplied (OFFSET,) LIMIT = %s, %s",
        $useroffset,
        (defined($userlimit ) ? $userlimit  : 'UNDEF');
    $offset += $useroffset;
    if (defined($userlimit)) {
        if ($offset + $limit > $userlimit ) {
            $limit = $userlimit - $offset;
        } elsif ( ! $offset && $limit < $userlimit ) {
            $limit = $userlimit;
        }
    }
    $sql .= " LIMIT ?, ?";

    my $sth = C4::Context->dbh->prepare($sql);
    $sth->execute(@$sql_params, $offset, $limit);
    return ( $sth, { queryerr => $sth->errstr } ) if ($sth->err);
    return ( $sth );
    # my @xmlarray = ... ;
    # my $url = "/cgi-bin/koha/reports/guided_reports.pl?phase=retrieve%20results&id=$id";
    # my $xml = XML::Dumper->new()->pl2xml( \@xmlarray );
    # store_results($id,$xml);
}

=head2 save_report($sql,$name,$type,$notes)

Given some sql and a name this will saved it so that it can reused
Returns id of the newly created report

=cut

sub save_report {
    my ($fields) = @_;
    my $borrowernumber = $fields->{borrowernumber};
    my $sql = $fields->{sql};
    my $name = $fields->{name};
    my $type = $fields->{type};
    my $notes = $fields->{notes};
    my $area = $fields->{area};
    my $group = $fields->{group};
    my $subgroup = $fields->{subgroup};
    my $cache_expiry = $fields->{cache_expiry} || 300;
    my $public = $fields->{public};

    my $dbh = C4::Context->dbh();
    $sql =~ s/(\s*\;\s*)$//;    # removes trailing whitespace and /;/
    my $query = "INSERT INTO saved_sql (borrowernumber,date_created,last_modified,savedsql,report_name,report_area,report_group,report_subgroup,type,notes,cache_expiry,public)  VALUES (?,now(),now(),?,?,?,?,?,?,?,?,?)";
    $dbh->do($query, undef, $borrowernumber, $sql, $name, $area, $group, $subgroup, $type, $notes, $cache_expiry, $public);

    my $id = $dbh->selectrow_array("SELECT max(id) FROM saved_sql WHERE borrowernumber=? AND report_name=?", undef,
                                   $borrowernumber, $name);
    return $id;
}

sub update_sql {
    my $id         = shift || croak "No Id given";
    my $fields     = shift;
    my $sql = $fields->{sql};
    my $name = $fields->{name};
    my $notes = $fields->{notes};
    my $group = $fields->{group};
    my $subgroup = $fields->{subgroup};
    my $cache_expiry = $fields->{cache_expiry};
    my $public = $fields->{public};

    if( $cache_expiry >= 2592000 ){
      die "Please specify a cache expiry less than 30 days\n";
    }

    my $dbh        = C4::Context->dbh();
    $sql =~ s/(\s*\;\s*)$//;    # removes trailing whitespace and /;/
    my $query = "UPDATE saved_sql SET savedsql = ?, last_modified = now(), report_name = ?, report_group = ?, report_subgroup = ?, notes = ?, cache_expiry = ?, public = ? WHERE id = ? ";
    $dbh->do($query, undef, $sql, $name, $group, $subgroup, $notes, $cache_expiry, $public, $id );
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
	}
	else {
		my $query2 = "INSERT INTO saved_reports (report_id,report,date_run) VALUES (?,?,now())";
		my $sth2 = $dbh->prepare($query2);
		$sth2->execute($id,$xml);
	}
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
	return ($perl,$data->{'report_name'},$data->{'notes'});	
}	

sub delete_report {
    my (@ids) = @_;
    return unless @ids;
    my $dbh = C4::Context->dbh;
    my $query = 'DELETE FROM saved_sql WHERE id IN (' . join( ',', ('?') x @ids ) . ')';
    my $sth = $dbh->prepare($query);
    return $sth->execute(@ids);
}

sub get_saved_reports_base_query {

    my $area_name_sql_snippet = get_area_name_sql_snippet;
    return <<EOQ;
SELECT s.*, r.report, r.date_run, $area_name_sql_snippet, av_g.lib AS groupname, av_sg.lib AS subgroupname,
b.firstname AS borrowerfirstname, b.surname AS borrowersurname
FROM saved_sql s
LEFT JOIN saved_reports r ON r.report_id = s.id
LEFT OUTER JOIN authorised_values av_g ON (av_g.category = 'REPORT_GROUP' AND av_g.authorised_value = s.report_group)
LEFT OUTER JOIN authorised_values av_sg ON (av_sg.category = 'REPORT_SUBGROUP' AND av_sg.lib_opac = s.report_group AND av_sg.authorised_value = s.report_subgroup)
LEFT OUTER JOIN borrowers b USING (borrowernumber)
EOQ
}

sub get_saved_reports {
# $filter is either { date => $d, author => $a, keyword => $kw, }
# or $keyword. Optional.
    my ($filter) = @_;
    $filter = { keyword => $filter } if $filter && !ref( $filter );
    my ($group, $subgroup) = @_;

    my $dbh   = C4::Context->dbh();
    my $query = get_saved_reports_base_query;
    my (@cond,@args);
    if ($filter) {
        if (my $date = $filter->{date}) {
            $date = format_date_in_iso($date);
            push @cond, "DATE(date_run) = ? OR
                         DATE(date_created) = ? OR
                         DATE(last_modified) = ? OR
                         DATE(last_run) = ?";
            push @args, $date, $date, $date, $date;
        }
        if (my $author = $filter->{author}) {
            $author = "%$author%";
            push @cond, "surname LIKE ? OR
                         firstname LIKE ?";
            push @args, $author, $author;
        }
        if (my $keyword = $filter->{keyword}) {
            $keyword = "%$keyword%";
            push @cond, "report LIKE ? OR
                         report_name LIKE ? OR
                         notes LIKE ? OR
                         savedsql LIKE ?";
            push @args, $keyword, $keyword, $keyword, $keyword;
        }
        if ($filter->{group}) {
            push @cond, "report_group = ?";
            push @args, $filter->{group};
        }
        if ($filter->{subgroup}) {
            push @cond, "report_subgroup = ?";
            push @args, $filter->{subgroup};
        }
    }
    $query .= " WHERE ".join( " AND ", map "($_)", @cond ) if @cond;
    $query .= " ORDER by date_created";
    
    my $result = $dbh->selectall_arrayref($query, {Slice => {}}, @args);

    return $result;
}

sub get_saved_report {
    my $dbh   = C4::Context->dbh();
    my $query;
    my $report_arg;
    if ($#_ == 0 && ref $_[0] ne 'HASH') {
        ($report_arg) = @_;
        $query = " SELECT * FROM saved_sql WHERE id = ?";
    } elsif (ref $_[0] eq 'HASH') {
        my ($selector) = @_;
        if ($selector->{name}) {
            $query = " SELECT * FROM saved_sql WHERE report_name = ?";
            $report_arg = $selector->{name};
        } elsif ($selector->{id} || $selector->{id} eq '0') {
            $query = " SELECT * FROM saved_sql WHERE id = ?";
            $report_arg = $selector->{id};
        } else {
            return;
        }
    } else {
        return;
    }
    return $dbh->selectrow_hashref($query, undef, $report_arg);
}

=head2 create_compound($masterID,$subreportID)

This will take 2 reports and create a compound report using both of them

=cut

sub create_compound {
    my ( $masterID, $subreportID ) = @_;
    my $dbh = C4::Context->dbh();

    # get the reports
    my $master = get_saved_report($masterID);
    my $mastersql = $master->{savedsql};
    my $mastertype = $master->{type};
    my $sub = get_saved_report($subreportID);
    my $subsql = $master->{savedsql};
    my $subtype = $master->{type};

    # now we have to do some checking to see how these two will fit together
    # or if they will
    my ( $mastertables, $subtables );
    if ( $mastersql =~ / from (.*) where /i ) {
        $mastertables = $1;
    }
    if ( $subsql =~ / from (.*) where /i ) {
        $subtables = $1;
    }
    return ( $mastertables, $subtables );
}

=head2 get_column_type($column)

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
}

=head2 get_distinct_values($column)

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
    return $sth->fetchall_arrayref({});
}	

sub save_dictionary {
    my ( $name, $description, $sql, $area ) = @_;
    my $dbh   = C4::Context->dbh();
    my $query = "INSERT INTO reports_dictionary (name,description,saved_sql,report_area,date_created,date_modified)
  VALUES (?,?,?,?,now(),now())";
    my $sth = $dbh->prepare($query);
    $sth->execute($name,$description,$sql,$area) || return 0;
    return 1;
}

sub get_from_dictionary {
    my ( $area, $id ) = @_;
    my $dbh   = C4::Context->dbh();
    my $area_name_sql_snippet = get_area_name_sql_snippet;
    my $query = <<EOQ;
SELECT d.*, $area_name_sql_snippet
FROM reports_dictionary d
EOQ

    if ($area) {
        $query .= " WHERE report_area = ?";
    } elsif ($id) {
        $query .= " WHERE id = ?";
    }
    my $sth = $dbh->prepare($query);
    if ($id) {
        $sth->execute($id);
    } elsif ($area) {
        $sth->execute($area);
    } else {
        $sth->execute();
    }
    my @loop;
    while ( my $data = $sth->fetchrow_hashref() ) {
        push @loop, $data;
    }
    return ( \@loop );
}

sub delete_definition {
	my ($id) = @_ or return;
	my $dbh = C4::Context->dbh();
	my $query = "DELETE FROM reports_dictionary WHERE id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
}

sub get_sql {
	my ($id) = @_ or return;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM saved_sql WHERE id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	my $data=$sth->fetchrow_hashref();
	return $data->{'savedsql'};
}

sub _get_column_defs {
    my ($cgi) = @_;
    my %columns;
    my $columns_def_file = "columns.def";
    my $htdocs = C4::Context->config('intrahtdocs');
    my $section = 'intranet';

    # We need the theme and the lang
    # Since columns.def is not in the modules directory, we cannot sent it for the $tmpl var
    my ($theme, $lang, $availablethemes) = C4::Templates::themelanguage($htdocs, 'about.tt', $section, $cgi);

    my $full_path_to_columns_def_file="$htdocs/$theme/$lang/$columns_def_file";
    open (my $fh, $full_path_to_columns_def_file);
    while ( my $input = <$fh> ){
        chomp $input;
        if ( $input =~ m|<field name="(.*)">(.*)</field>| ) {
            my ( $field, $translation ) = ( $1, $2 );
            $columns{$field} = $translation;
        }
    }
    close $fh;
    return \%columns;
}

=head2 build_authorised_value_list($authorised_value)

Returns an arrayref - hashref pair. The hashref consists of
various code => name lists depending on the $authorised_value.
The arrayref is the hashref keys, in appropriate order

=cut

sub build_authorised_value_list {
    my ( $authorised_value ) = @_;

    my $dbh = C4::Context->dbh;
    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...
    if ( $authorised_value eq "branches" ) {
        my $branches = GetBranchesLoop();
        foreach my $thisbranch (@$branches) {
            push @authorised_values, $thisbranch->{value};
            $authorised_lib{ $thisbranch->{value} } = $thisbranch->{branchname};
        }
    } elsif ( $authorised_value eq "itemtypes" ) {
        my $sth = $dbh->prepare("SELECT itemtype,description FROM itemtypes ORDER BY description");
        $sth->execute;
        while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
            push @authorised_values, $itemtype;
            $authorised_lib{$itemtype} = $description;
        }
    } elsif ( $authorised_value eq "cn_source" ) {
        my $class_sources  = GetClassSources();
        my $default_source = C4::Context->preference("DefaultClassificationSource");
        foreach my $class_source ( sort keys %$class_sources ) {
            next
              unless $class_sources->{$class_source}->{'used'}
                  or ( $class_source eq $default_source );
            push @authorised_values, $class_source;
            $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
        }
    } elsif ( $authorised_value eq "categorycode" ) {
        my $sth = $dbh->prepare("SELECT categorycode, description FROM categories ORDER BY description");
        $sth->execute;
        while ( my ( $categorycode, $description ) = $sth->fetchrow_array ) {
            push @authorised_values, $categorycode;
            $authorised_lib{$categorycode} = $description;
        }

        #---- "true" authorised value
    } else {
        my $authorised_values_sth = $dbh->prepare("SELECT authorised_value,lib FROM authorised_values WHERE category=? ORDER BY lib");

        $authorised_values_sth->execute($authorised_value);

        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
            push @authorised_values, $value;
            $authorised_lib{$value} = $lib;

            # For item location, we show the code and the libelle
            $authorised_lib{$value} = $lib;
        }
    }

    return (\@authorised_values, \%authorised_lib);
}

=head2 GetReservedAuthorisedValues

    my %reserved_authorised_values = GetReservedAuthorisedValues();

Returns a hash containig all reserved words

=cut

sub GetReservedAuthorisedValues {
    my %reserved_authorised_values =
            map { $_ => 1 } ( 'date',
                              'branches',
                              'itemtypes',
                              'cn_source',
                              'categorycode',
                              'biblio_framework' );

   return \%reserved_authorised_values;
}


=head2 IsAuthorisedValueValid

    my $is_valid_ath_value = IsAuthorisedValueValid($authorised_value)

Returns 1 if $authorised_value is on the reserved authorised values list or
in the authorised value categories defined in

=cut

sub IsAuthorisedValueValid {

    my $authorised_value = shift;
    my $reserved_authorised_values = GetReservedAuthorisedValues();

    if ( exists $reserved_authorised_values->{$authorised_value} ||
         C4::Koha::IsAuthorisedValueCategory($authorised_value)   ) {
        return 1;
    }

    return 0;
}

=head2 GetParametersFromSQL

    my @sql_parameters = GetParametersFromSQL($sql)

Returns an arrayref of hashes containing the keys name and authval

=cut

sub GetParametersFromSQL {

    my $sql = shift ;
    my @split = split(/<<|>>/,$sql);
    my @sql_parameters = ();

    for ( my $i = 0; $i < ($#split/2) ; $i++ ) {
        my ($name,$authval) = split(/\|/,$split[$i*2+1]);
        push @sql_parameters, { 'name' => $name, 'authval' => $authval };
    }

    return \@sql_parameters;
}

=head2 ValidateSQLParameters

    my @problematic_parameters = ValidateSQLParameters($sql)

Returns an arrayref of hashes containing the keys name and authval of
those SQL parameters that do not correspond to valid authorised names

=cut

sub ValidateSQLParameters {

    my $sql = shift;
    my @problematic_parameters = ();
    my $sql_parameters = GetParametersFromSQL($sql);

    foreach my $sql_parameter (@$sql_parameters) {
        if ( defined $sql_parameter->{'authval'} ) {
            push @problematic_parameters, $sql_parameter unless
                IsAuthorisedValueValid($sql_parameter->{'authval'});
        }
    }

    return \@problematic_parameters;
}

1;
__END__

=head1 AUTHOR

Chris Cormack <crc@liblime.com>

=cut
