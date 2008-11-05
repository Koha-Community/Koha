#!/usr/bin/perl

# Copyright 2007 Liblime ltd
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
use C4::Reports::Guided;
use C4::Auth;
use C4::Output;
use C4::Dates;
use C4::Debug;

=head1 NAME

Script to control the guided report creation

=head1 DESCRIPTION


=over2

=cut

my $input = new CGI;
my $referer = $input->referer();

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/guided_reports_start.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => 1 },
        debug           => 1,
    }
);

my $phase = $input->param('phase');
my $no_html = 0; # this will be set if we dont want to print out an html::template

if ( !$phase ) {
    $template->param( 'start' => 1 );

    # show welcome page
}

elsif ( $phase eq 'Build new' ) {

    # build a new report
    $template->param( 'build1' => 1 );

    # get report areas
    my $areas = get_report_areas();
    $template->param( 'areas' => $areas );

}

elsif ( $phase eq 'Used saved' ) {

    # use a saved report
    # get list of reports and display them
    $template->param( 'saved1' => 1 );
    my $reports = get_saved_reports();
    $template->param( 'savedreports' => $reports );
}

elsif ( $phase eq 'Delete Saved') {
	
	# delete a report from the saved reports list
	$no_html = 1;
	my $id = $input->param('reports');
	delete_report($id);
    print $input->redirect("/cgi-bin/koha/reports/guided_reports.pl?phase=Used%20saved");
	
}		

elsif ( $phase eq 'Show SQL'){
	
	my $id = $input->param('reports');
	my $sql = get_sql($id);
	$template->param(
		'sql' => $sql,
		'showsql' => 1,
		);
}

elsif ($phase eq 'retrieve results') {
	my $id = $input->param('id');
	my ($results,$name,$notes) = format_results($id);
	# do something
	$template->param(
		'retresults' => 1,
		'results' => $results,
		'name' => $name,
		'notes' => $notes,
		);
	
}

elsif ( $phase eq 'Report on this Area' ) {

    # they have choosen a new report and the area to report on
    # get area
    my $area = $input->param('areas');
    $template->param(
        'build2' => 1,
        'area'   => $area
    );

    # get report types
    my $types = get_report_types();
    $template->param( 'types' => $types );
}

elsif ( $phase eq 'Choose this type' ) {

    # they have chosen type and area
    # get area and type and pass them to the template
    my $area = $input->param('area');
    my $type = $input->param('types');
    $template->param(
        'build3' => 1,
        'area'   => $area,
        'type'   => $type,
    );

    # get columns
    my $columns = get_columns($area,$input);
    $template->param( 'columns' => $columns );
}

elsif ( $phase eq 'Choose these columns' ) {

    # we now know type, area, and columns
    # next step is the constraints
    my $area    = $input->param('area');
    my $type    = $input->param('type');
    my @columns = $input->param('columns');
    my $column  = join( ',', @columns );
	my $definitions = get_from_dictionary($area);
    $template->param(
        'build4' => 1,
        'area'   => $area,
        'type'   => $type,
        'column' => $column,
    );
    my $criteria = get_criteria($area,$input);
    $template->param( 'criteria' => $criteria,
	'definitions' => $definitions);
}

elsif ( $phase eq 'Choose these criteria' ) {
    my $area     = $input->param('area');
    my $type     = $input->param('type');
    my $column   = $input->param('column');
	my @definitions = $input->param('definition');
	my $definition = join (',',@definitions);
    my @criteria = $input->param('criteria_column');
	my $query_criteria;
    foreach my $crit (@criteria) {
        my $value = $input->param( $crit . "_value" );
        if ($value) {
            if ($value =~ C4::Dates->regexp(C4::Context->preference('dateformat'))) { 
                my $date = C4::Dates->new($value);
                $value = $date->output("iso");
            }
            $query_criteria .= " AND $crit='$value'";
        }
    }

    $template->param(
        'build5'         => 1,
        'area'           => $area,
        'type'           => $type,
        'column'         => $column,
        'definition'     => $definition,
        'criteriastring' => $query_criteria,
    );

    # get columns
    my @columns = split( ',', $column );
    my @total_by;

    # build structue for use by tmpl_loop to choose columns to order by
    # need to do something about the order of the order :)
	# we also want to use the %columns hash to get the plain english names
    foreach my $col (@columns) {
        my %total;
        $total{'name'} = $col;
        my @selects;
        my %select1;
        $select1{'value'} = 'sum';
        push @selects, \%select1;
        my %select2;
        $select2{'value'} = 'min';
        push @selects, \%select2;
        my %select3;
        $select3{'value'} = 'max';
        push @selects, \%select3;
        my %select4;
        $select4{'value'} = 'avg';
        push @selects, \%select4;
        my %select5;
        $select5{'value'} = 'count';
        push @selects, \%select5;

        $total{'select'} = \@selects;
        push @total_by, \%total;
    }

    $template->param( 'total_by' => \@total_by );
}

elsif ( $phase eq 'Choose These Operations' ) {
    my $area     = $input->param('area');
    my $type     = $input->param('type');
    my $column   = $input->param('column');
    my $criteria = $input->param('criteria');
	my $definition = $input->param('definition');
    my @total_by = $input->param('total_by');
    my $totals;
    foreach my $total (@total_by) {
        my $value = $input->param( $total . "_tvalue" );
        $totals .= "$value($total),";
    }

    $template->param(
        'build6'         => 1,
        'area'           => $area,
        'type'           => $type,
        'column'         => $column,
        'criteriastring' => $criteria,
        'totals'         => $totals,
        'definition'    => $definition,
    );

    # get columns
    my @columns = split( ',', $column );
    my @order_by;

    # build structue for use by tmpl_loop to choose columns to order by
    # need to do something about the order of the order :)
    foreach my $col (@columns) {
        my %order;
        $order{'name'} = $col;
        my @selects;
        my %select1;
        $select1{'value'} = 'asc';
        push @selects, \%select1;
        my %select2;
        $select2{'value'} = 'desc';
        push @selects, \%select2;
        $order{'select'} = \@selects;
        push @order_by, \%order;
    }

    $template->param( 'order_by' => \@order_by );
}

elsif ( $phase eq 'Build Report' ) {

    # now we have all the info we need and can build the sql
    my $area     = $input->param('area');
    my $type     = $input->param('type');
    my $column   = $input->param('column');
    my $crit     = $input->param('criteria');
    my $totals   = $input->param('totals');
	my $definition = $input->param('definition');
#    my @criteria = split( ',', $crit );
    my $query_criteria=$crit;
    # split the columns up by ,
    my @columns = split( ',', $column );
    my @order_by = $input->param('order_by');

    my $query_orderby;
    foreach my $order (@order_by) {
        my $value = $input->param( $order . "_ovalue" );
        if ($query_orderby) {
            $query_orderby .= ",$order $value";
        }
        else {
            $query_orderby = " ORDER BY $order $value";
        }
    }

    # get the sql
    my $sql =
      build_query( \@columns, $query_criteria, $query_orderby, $area, $totals, $definition );
    $template->param(
        'showreport' => 1,
        'sql'        => $sql,
        'type'       => $type
    );
}

elsif ( $phase eq 'Save' ) {
	# Save the report that has just been built
    my $sql  = $input->param('sql');
    my $type = $input->param('type');
    $template->param(
        'save' => 1,
        'sql'  => $sql,
        'type' => $type
    );
}

elsif ( $phase eq 'Save Report' ) {
    # save the sql pasted in by a user 
    my $sql  = $input->param('sql');
    my $name = $input->param('reportname');
    my $type = $input->param('types');
    my $notes = $input->param('notes');
    my @errors = ();
    my $error = {};
    if ($sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i) {
        $error->{'sqlerr'} = $1;
        push @errors, $error;
    }
    elsif ($sql !~ /^(SELECT)/i) {
        $error->{'queryerr'} = 1;
        push @errors, $error;
    }
    if (@errors) {
        $template->param(
            'save_successful'       => 1,
            'errors'    => \@errors,
            'sql'       => $sql,
            'reportname'=> $name,
            'type'      => $type,
            'notes'     => $notes,
        );
    }
    else {
        save_report( $sql, $name, $type, $notes );
        $template->param(
            'save_successful'       => 1,
        );
    }
}

# This condition is not used currently
#elsif ( $phase eq 'Execute' ) {
#    # run the sql, and output results in a template	
#    my $sql     = $input->param('sql');
#    my $type    = $input->param('type');
#    my ($results, $total, $errors) = execute_query($sql, $type);
#    $template->param(
#        'results' => $results,
#        'sql' => $sql,
#        'execute' => 1,
#    );
#}

elsif ($phase eq 'Run this report'){
    # execute a saved report
    # FIXME The default limit should not be hardcoded...
    my $limit = 20;
    my $offset;
    my $report = $input->param('reports');
    # offset algorithm
    if ($input->param('page')) {
        $offset = ($input->param('page') - 1) * 20;
    }
    else {
        $offset = 0;
    }
    my ($sql,$type,$name,$notes) = get_saved_report($report);
    my ($results, $total, $errors) = execute_query($sql, $type, $offset, $limit);
    my $totpages = int($total/$limit) + (($total % $limit) > 0 ? 1 : 0);
    my $url = "/cgi-bin/koha/reports/guided_reports.pl?reports=$report&phase=Run%20this%20report";
    $template->param(
        'results'       => $results,
        'sql'           => $sql,
        'execute'       => 1,
        'name'          => $name,
        'notes'         => $notes,
        'pagination_bar' => pagination_bar($url, $totpages, $input->param('page'), "page"),
        'errors'        => $errors,
    );
}	

elsif ($phase eq 'Export'){
    binmode STDOUT, ':utf8';

	# export results to tab separated text
	my $sql = $input->param('sql');
        my $format = $input->param('format');
	my ($results, $total, $errors) = execute_query($sql,1,0,0,$format);
        if ($#$errors == -1) {
            $no_html=1;
            print $input->header(       -type => 'application/octet-stream',
                                        -attachment=>'reportresults.csv'
                                );
	    print $results;
        } else {
            $template->param(
                'results'       => $results,
                'sql'           => $sql,
                'execute'       => 1,
                'name'          => 'Error exporting report!',
                'notes'         => '',
                'pagination_bar' => '',
                'errors'        => $errors,
            );
        }
}

elsif ($phase eq 'Create report from SQL') {
	# allow the user to paste in sql
        if ($input->param('sql')) {
            $template->param(
                'sql'           => $input->param('sql'),
                'reportname'    => $input->param('reportname'),
                'notes'         => $input->param('notes'),
            );
        }
	$template->param('create' => 1);
	my $types = get_report_types();
        if (my $type = $input->param('type')) {
            for my $i ( 0 .. $#{@$types}) {
                @$types[$i]->{'selected'} = 1 if @$types[$i]->{'id'} eq $type;
            }
        }
	$template->param( 'types' => $types ); 
}

elsif ($phase eq 'Create Compound Report'){
	my $reports = get_saved_reports();  
	$template->param( 'savedreports' => $reports,
		'compound' => 1,
	);
}

elsif ($phase eq 'Save Compound'){
    my $master = $input->param('master');
	my $subreport = $input->param('subreport');
#	my $compound_report = create_compound($master,$subreport);
#	my $results = run_compound($compound_report);
	my ($mastertables,$subtables) = create_compound($master,$subreport);
	$template->param( 'save_compound' => 1,
		master=>$mastertables,
		subsql=>$subtables
	);
}


$template->param(   'referer' => $referer,
                    'DHTMLcalendar_dateformat' => C4::Dates->DHTMLcalendar(),
                );


if (!$no_html){
	output_html_with_http_headers $input, $cookie, $template->output;
}
