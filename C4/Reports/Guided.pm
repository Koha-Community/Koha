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

use Modern::Perl;
use CGI qw ( -utf8 );
use Carp qw( carp croak );
use JSON qw( from_json );

use C4::Context;
use C4::Koha qw( GetAuthorisedValues );
use C4::Log qw( logaction );
use C4::Output;
use C4::Templates qw/themelanguage/;
use Koha::AuthorisedValues;
use Koha::Database::Columns;
use Koha::DateUtils qw( dt_from_string );
use Koha::Logger;
use Koha::Notice::Templates;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::Reports;
use Koha::SharedContent;
use Koha::TemplateUtils qw( process_tt );

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT_OK = qw(
      get_report_types get_report_areas get_report_groups get_columns build_query get_criteria
      save_report get_saved_reports execute_query
      get_column_type get_distinct_values save_dictionary get_from_dictionary
      delete_definition delete_report store_results format_results get_sql get_results
      nb_rows update_sql
      strip_limit
      convert_sql
      GetReservedAuthorisedValues
      GetParametersFromSQL
      IsAuthorisedValueValid
      ValidateSQLParameters
      nb_rows update_sql
      EmailReport
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
        [SER  => "Serials"],
    );

    return "CASE report_area " .
    join (" ", map "WHEN '$_->[0]' THEN '$_->[1]'", @REPORT_AREA) .
    " END AS areaname";
}

sub get_report_areas {

    my $report_areas = [ 'CIRC', 'CAT', 'PAT', 'ACQ', 'ACC', 'SER' ];

    return $report_areas;
}

sub get_table_areas {
    return (
    CIRC => [ 'borrowers', 'statistics', 'items', 'biblioitems' ],
    CAT  => [ 'items', 'biblioitems', 'biblio' ],
    PAT  => ['borrowers'],
    ACQ  => [ 'aqorders', 'biblio', 'items' ],
    ACC  => [ 'borrowers', 'accountlines' ],
    SER  => [ 'serial', 'serialitems', 'subscription', 'subscriptionhistory', 'subscriptionroutinglist', 'biblioitems', 'biblio', 'aqbooksellers' ],
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

    # this calls the internal function _get_columns
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
    my $columns = Koha::Database::Columns->columns;
	my %tablehash;
	$tablehash{'table'}=$tablename;
    $tablehash{'__first__'} = $first;
	push @columns, \%tablehash;
    while ( my $data = $sth->fetchrow_arrayref() ) {
        my %temphash;
        $temphash{'name'}        = "$tablename.$data->[0]";
        $temphash{'description'} = $columns->{$tablename}->{$data->[0]};
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
        SER  => [ 'serial.serialid=serialitems.serialid', 'serial.subscriptionid=subscription.subscriptionid', 'serial.subscriptionid=subscriptionhistory.subscriptionid', 'serial.subscriptionid=subscriptionroutinglist.subscriptionid', 'biblioitems.biblionumber=serial.biblionumber', 'biblio.biblionumber=biblioitems.biblionumber', 'subscription.aqbooksellerid=aqbooksellers.id'],
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
        SER  => ['subscription.startdate|date', 'subscription.enddate|date', 'subscription.periodicity', 'subscription.callnumber', 'subscription.location', 'subscription.branchcode'],
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
    my $columns = Koha::Database::Columns->columns;
    my @criteria_array;
    foreach my $localcrit (@$crit) {
        my ( $value, $type )   = split( /\|/, $localcrit );
        my ( $table, $column ) = split( /\./, $value );
        my $description = $columns->{$table}->{$column};
        if ($type eq 'textrange') {
            my %temp;
            $temp{'name'}        = $value;
            $temp{'from'}        = "from_" . $value;
            $temp{'to'}          = "to_" . $value;
            $temp{'textrange'}   = 1;
            $temp{'description'} = $description;
            push @criteria_array, \%temp;
        }
        elsif ($type eq 'date') {
            my %temp;
            $temp{'name'}        = $value;
            $temp{'date'}        = 1;
            $temp{'description'} = $description;
            push @criteria_array, \%temp;
        }
        elsif ($type eq 'daterange') {
            my %temp;
            $temp{'name'}        = $value;
            $temp{'from'}        = "from_" . $value;
            $temp{'to'}          = "to_" . $value;
            $temp{'daterange'}   = 1;
            $temp{'description'} = $description;
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
            $list='itemtypes' if $column eq 'itype';
            $list='ccode' if $column eq 'ccode';
            # TODO : improve to let the librarian choose the description at runtime
            push @values, {
                availablevalues => "<<$column" . ( $list ? "|$list" : '' ) . ">>",
                display_value   => "<<$column" . ( $list ? "|$list" : '' ) . ">>",
            };
            while ( my $row = $sth->fetchrow_hashref() ) {
                if ($row->{'availablevalues'} eq '') { $row->{'default'} = 1 }
                else { $row->{display_value} = _get_display_value( $row->{'availablevalues'}, $column ); }
                push @values, $row;
            }
            $sth->finish();

            push @criteria_array, {
                name        => $value,
                description => $description,
                values      => \@values,
            };
        }
    }
    return ( \@criteria_array );
}

sub nb_rows {
    my $sql = shift or return;

    my $derived_name = 'xxx';
    # make sure the derived table name is not already used
    while ( $sql =~ m/$derived_name/ ) {
        $derived_name .= 'x';
    }


    my $dbh = C4::Context->dbh;
    my $sth;
    my $n = 0;

    my $RaiseError = $dbh->{RaiseError};
    my $PrintError = $dbh->{PrintError};
    $dbh->{RaiseError} = 1;
    $dbh->{PrintError} = 0;
    eval {
        $sth = $dbh->prepare(qq{
            SELECT COUNT(*) FROM
            ( $sql ) $derived_name
        });

        $sth->execute();
    };
    $dbh->{RaiseError} = $RaiseError;
    $dbh->{PrintError} = $PrintError;
    if ($@) { # To catch "Duplicate column name" caused by the derived table, or any other syntax error
        eval {
            $sth = $dbh->prepare($sql);
            $sth->execute;
        };
        warn $@ if $@;
        # Loop through the complete results, fetching 1,000 rows at a time.  This
        # lowers memory requirements but increases execution time.
        while (my $rows = $sth->fetchall_arrayref(undef, 1000)) {
            $n += @$rows;
        }
        return $n;
    }

    my $results = $sth->fetch;
    return $results ? $results->[0] : 0;
}

=head2 select_2_select_count

 returns $sql, $offset, $limit
 $sql returned will be transformed to:
  ~ remove any LIMIT clause
  ~ replace SELECT clause w/ SELECT count(*)

=cut

sub select_2_select_count {
    # Modify the query passed in to create a count query... (I think this covers all cases -crn)
    my ($sql) = strip_limit(shift) or return;
    $sql =~ s/\bSELECT\W+(?:\w+\W+){1,}?FROM\b|\bSELECT\W\*\WFROM\b/SELECT count(*) FROM /ig;
    return $sql;
}

=head2 strip_limit
This removes the LIMIT from the query so that a custom one can be specified.
Usage:
   ($new_sql, $offset, $limit) = strip_limit($sql);

Where:
  $sql is the query to modify
  $new_sql is the resulting query
  $offset is the offset value, if the LIMIT was the two-argument form,
      0 if it wasn't otherwise given.
  $limit is the limit value

Notes:
  * This makes an effort to not break subqueries that have their own
    LIMIT specified. It does that by only removing a LIMIT if it comes after
    a WHERE clause (which isn't perfect, but at least should make more cases
    work - subqueries with a limit in the WHERE will still break.)
  * If your query doesn't have a WHERE clause then all LIMITs will be
    removed. This may break some subqueries, but is hopefully rare enough
    to not be a big issue.

=cut

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

=head2 execute_query

  ($sth, $error) = execute_query({
      sql => $sql,
      offset => $offset,
      limit => $limit
      sql_params => \@sql_params],
      report_id => $report_id
  })


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
The caller is responsible for making sure that C<$sql> has placeholders
and that the number placeholders matches the number of parameters.

=cut

sub execute_query {

    my $params     = shift;
    my $sql        = $params->{sql};
    my $offset     = $params->{offset} || 0;
    my $limit      = $params->{limit}  || C4::Context->config('report_results_limit') || 999999;
    my $sql_params = defined $params->{sql_params} ? $params->{sql_params} : [];
    my $report_id  = $params->{report_id};

    # check parameters
    unless ($sql) {
        carp "execute_query() called without SQL argument";
        return;
    }

    Koha::Logger->get->debug("Report - execute_query($sql, $offset, $limit)");

    my ( $is_sql_valid, $errors ) = Koha::Report->new({ savedsql => $sql })->is_sql_valid;
    return (undef, @{$errors}[0]) unless $is_sql_valid;

    foreach my $sql_param ( @$sql_params ){
        if ( $sql_param =~ m/\n/ ){
            my @list = split /\n/, $sql_param;
            my @quoted_list;
            foreach my $item ( @list ){
                $item =~ s/\r//;
              push @quoted_list, C4::Context->dbh->quote($item);
            }
            $sql_param = "(".join(",",@quoted_list).")";
        }
    }

    my ($useroffset, $userlimit);

    # Grab offset/limit from user supplied LIMIT and drop the LIMIT so we can control pagination
    ($sql, $useroffset, $userlimit) = strip_limit($sql);

    Koha::Logger->get->debug(
        sprintf "User has supplied (OFFSET,) LIMIT = %s, %s",
        $useroffset, ( defined($userlimit) ? $userlimit : 'UNDEF' ) );

    $offset += $useroffset;
    if (defined($userlimit)) {
        if ($offset + $limit > $userlimit ) {
            $limit = $userlimit - $offset;
        } elsif ( ! $offset && $limit < $userlimit ) {
            $limit = $userlimit;
        }
    }
    $sql .= " LIMIT ?, ?";

    my $dbh = C4::Context->dbh;

    $dbh->do( 'UPDATE saved_sql SET last_run = NOW() WHERE id = ?', undef, $report_id ) if $report_id;

    my $sth = $dbh->prepare($sql);
    eval {
        $sth->execute(@$sql_params, $offset, $limit);
    };
    warn $@ if $@;

    return ( $sth, { queryerr => $sth->errstr } ) if ($sth->err);
    return ( $sth );
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
    my $cache_expiry = $fields->{cache_expiry};
    my $public = $fields->{public};

    $sql =~ s/(\s*\;\s*)$//;    # removes trailing whitespace and /;/
    my $now = dt_from_string;
    my $report = Koha::Report->new(
        {
            borrowernumber  => $borrowernumber,
            date_created    => $now, # Must be moved to Koha::Report->store
            last_modified   => $now, # Must be moved to Koha::Report->store
            savedsql        => $sql,
            report_name     => $name,
            report_area     => $area,
            report_group    => $group,
            report_subgroup => $subgroup,
            type            => $type,
            notes           => $notes,
            cache_expiry    => $cache_expiry,
            public          => $public,
        }
    )->store;

    return $report->id;
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

    $sql =~ s/(\s*\;\s*)$// if defined $sql;    # removes trailing whitespace and /;/
    my $report = Koha::Reports->find($id);
    $report->last_modified(dt_from_string);
    $report->savedsql($sql);
    $report->report_name($name);
    $report->notes($notes);
    $report->report_group($group);
    $report->report_subgroup($subgroup);
    $report->cache_expiry($cache_expiry) if defined $cache_expiry;
    $report->public($public);
    $report->store();
    if( $cache_expiry >= 2592000 ){
      die "Please specify a cache expiry less than 30 days\n"; # That's a bit harsh
    }

    return $report;
}

sub store_results {
    my ( $id, $json ) = @_;
    my $dbh = C4::Context->dbh();
    $dbh->do(q|
        INSERT INTO saved_reports ( report_id, report, date_run ) VALUES ( ?, ?, NOW() );
    |, undef, $id, $json );
}

sub format_results {
    my ( $id ) = @_;
    my $dbh = C4::Context->dbh();
    my ( $report_name, $notes, $json, $date_run ) = $dbh->selectrow_array(q|
       SELECT ss.report_name, ss.notes, sr.report, sr.date_run
       FROM saved_sql ss
       LEFT JOIN saved_reports sr ON sr.report_id = ss.id
       WHERE sr.id = ?
    |, undef, $id);
    return {
        report_name => $report_name,
        notes => $notes,
        results => from_json( $json ),
        date_run => $date_run,
    };
}

sub delete_report {
    my (@ids) = @_;
    return unless @ids;
    foreach my $id (@ids) {
        my $data = Koha::Reports->find($id);
        logaction( "REPORTS", "DELETE", $id, $data->report_name." | ".$data->savedsql ) if C4::Context->preference("ReportsLog");
    }
    my $dbh = C4::Context->dbh;
    my $query = 'DELETE FROM saved_sql WHERE id IN (' . join( ',', ('?') x @ids ) . ')';
    my $sth = $dbh->prepare($query);
    return $sth->execute(@ids);
}

sub get_saved_reports_base_query {
    my $area_name_sql_snippet = get_area_name_sql_snippet;
    return <<EOQ;
SELECT s.*, $area_name_sql_snippet, av_g.lib AS groupname, av_sg.lib AS subgroupname,
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
            push @cond, "DATE(last_modified) = ? OR
                         DATE(last_run) = ?";
            push @args, $date, $date;
        }
        if (my $author = $filter->{author}) {
            $author = "%$author%";
            push @cond, "surname LIKE ? OR
                         firstname LIKE ?";
            push @args, $author, $author;
        }
        if (my $keyword = $filter->{keyword}) {
            push @cond, q|
                       report LIKE ?
                    OR report_name LIKE ?
                    OR notes LIKE ?
                    OR savedsql LIKE ?
                    OR s.id = ?
            |;
            push @args, "%$keyword%", "%$keyword%", "%$keyword%", "%$keyword%", $keyword;
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
    $query .= " GROUP BY s.id, s.borrowernumber, s.date_created, s.last_modified, s.savedsql, s.last_run, s.report_name, s.type, s.notes, s.cache_expiry, s.public, s.report_area, s.report_group, s.report_subgroup, s.mana_id, av_g.lib, av_sg.lib, b.firstname, b.surname";
    $query .= " ORDER by date_created";

    my $result = $dbh->selectall_arrayref($query, {Slice => {}}, @args);

    return $result;
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

    # mysql doesn't support a column selection, set column to %
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

=head2 get_sql($report_id)

Given a report id, return the SQL statement for that report.
Otherwise, it just returns.

=cut

sub get_sql {
	my ($id) = @_ or return;
	my $dbh = C4::Context->dbh();
	my $query = "SELECT * FROM saved_sql WHERE id = ?";
	my $sth = $dbh->prepare($query);
	$sth->execute($id);
	my $data=$sth->fetchrow_hashref();
	return $data->{'savedsql'};
}

sub get_results {
    my ( $report_id ) = @_;
    my $dbh = C4::Context->dbh;
    return $dbh->selectall_arrayref(q|
        SELECT id, report, date_run
        FROM saved_reports
        WHERE report_id = ?
    |, { Slice => {} }, $report_id);
}

=head2 GetReservedAuthorisedValues

    my %reserved_authorised_values = GetReservedAuthorisedValues();

Returns a hash containig all reserved words

=cut

sub GetReservedAuthorisedValues {
    my %reserved_authorised_values =
            map { $_ => 1 } ( 'date',
                              'list',
                              'branches',
                              'itemtypes',
                              'cn_source',
                              'categorycode',
                              'biblio_framework',
                              'cash_registers',
                              'debit_types',
                              'credit_types' );

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
         Koha::AuthorisedValues->search({ category => $authorised_value })->count ) {
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
        $authval =~ s/\:all$// if $authval;
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

=head2 EmailReport

    my ( $emails, $arrayrefs ) = EmailReport($report_id, $letter_code, $module, $branch, $email)

Take a report and use it to process a Template Toolkit formatted notice
Returns arrayrefs containing prepared letters and errors respectively

=cut

sub EmailReport {

    my $params     = shift;
    my $report_id  = $params->{report_id};
    my $from       = $params->{from};
    my $email_col  = $params->{email} || 'email';
    my $module     = $params->{module};
    my $code       = $params->{code};
    my $branch     = $params->{branch} || "";

    my @errors = ();
    my @emails = ();

    return ( undef, [{ FATAL => "MISSING_PARAMS" }] ) unless ($report_id && $module && $code);

    return ( undef, [{ FATAL => "NO_LETTER" }] ) unless
    my $letter = Koha::Notice::Templates->find({
        module     => $module,
        code       => $code,
        branchcode => $branch,
        message_transport_type => 'email',
    });
    $letter = $letter->unblessed;
    $letter->{'content-type'} = 'text/html; charset="UTF-8"' if $letter->{'is_html'};

    my $report = Koha::Reports->find( $report_id );
    my $sql = $report->savedsql;
    return ( { FATAL => "NO_REPORT" } ) unless $sql;

    #don't pass offset or limit, hardcoded limit of 999,999 will be used
    my ( $sth, $errors ) = execute_query( { sql => $sql, report_id => $report_id } );
    return ( undef, [{ FATAL => "REPORT_FAIL" }] ) if $errors;

    my $counter = 1;
    my $template = $letter->{content};

    while ( my $row = $sth->fetchrow_hashref() ) {
        my $email;
        my $err_count = scalar @errors;
        push ( @errors, { NO_BOR_COL => $counter } ) unless defined $row->{borrowernumber};
        push ( @errors, { NO_EMAIL_COL => $counter } ) unless ( defined $row->{$email_col} );
        push ( @errors, { NO_FROM_COL => $counter } ) unless defined ( $from || $row->{from} );
        push ( @errors, { NO_BOR => $row->{borrowernumber} } ) unless Koha::Patrons->find({borrowernumber=>$row->{borrowernumber}});

        my $from_address = $from || $row->{from};
        my $to_address = $row->{$email_col};
        push ( @errors, { NOT_PARSE => $counter } ) unless my $content = process_tt( $template, $row );
        $counter++;
        next if scalar @errors > $err_count; #If any problems, try next

        $letter->{content}       = $content;
        $email->{borrowernumber} = $row->{borrowernumber};
        $email->{letter}         = { %$letter };
        $email->{from_address}   = $from_address;
        $email->{to_address}     = $to_address;

        push ( @emails, $email );
    }

    return ( \@emails, \@errors );

}

sub _get_display_value {
    my ( $original_value, $column ) = @_;
    if ( $column eq 'periodicity' ) {
        my $dbh = C4::Context->dbh();
        my $query = "SELECT description FROM subscription_frequencies WHERE id = ?";
        my $sth   = $dbh->prepare($query);
        $sth->execute($original_value);
        return $sth->fetchrow;
    }
    return $original_value;
}


=head3 convert_sql

my $updated_sql = C4::Reports::Guided::convert_sql( $sql );

Convert a sql query using biblioitems.marcxml to use the new
biblio_metadata.metadata field instead

=cut

sub convert_sql {
    my ( $sql ) = @_;
    my $updated_sql = $sql;
    if ( $sql =~ m|biblioitems| and $sql =~ m|marcxml| ) {
        $updated_sql =~ s|biblioitems|biblio_metadata|g;
        $updated_sql =~ s|marcxml|metadata|g;
    }
    return $updated_sql;
}

1;
__END__

=head1 AUTHOR

Chris Cormack <crc@liblime.com>

=cut
