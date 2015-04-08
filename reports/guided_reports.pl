#!/usr/bin/perl

# Copyright 2007 Liblime ltd
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
use CGI qw/-utf8/;
use Text::CSV::Encoded;
use URI::Escape;
use File::Temp;
use File::Basename qw( dirname );
use C4::Reports::Guided;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Debug;
use C4::Branch; # XXX subfield_is_koha_internal_p
use C4::Koha qw/IsAuthorisedValueCategory GetFrameworksLoop/;

=head1 NAME

guided_reports.pl

=head1 DESCRIPTION

Script to control the guided report creation

=cut

my $input = new CGI;
my $usecache = C4::Context->ismemcached;

my $phase = $input->param('phase');
my $flagsrequired;
if ( $phase eq 'Build new' or $phase eq 'Delete Saved' ) {
    $flagsrequired = 'create_reports';
}
elsif ( $phase eq 'Use saved' ) {
    $flagsrequired = 'execute_reports';
} else {
    $flagsrequired = '*';
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/guided_reports_start.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => $flagsrequired },
        debug           => 1,
    }
);
my $session = $cookie ? get_session($cookie->value) : undef;

my $filter;
if ( $input->param("filter_set") ) {
    $filter = {};
    $filter->{$_} = $input->param("filter_$_") foreach qw/date author keyword group subgroup/;
    $session->param('report_filter', $filter) if $session;
    $template->param( 'filter_set' => 1 );
}
elsif ($session) {
    $filter = $session->param('report_filter');
}


my @errors = ();
if ( !$phase ) {
    $template->param( 'start' => 1 );
    # show welcome page
}
elsif ( $phase eq 'Build new' ) {
    # build a new report
    $template->param( 'build1' => 1 );
    $template->param(
        'areas'        => get_report_areas(),
        'usecache'     => $usecache,
        'cache_expiry' => 300,
        'public'       => '0',
    );
} elsif ( $phase eq 'Use saved' ) {

    # use a saved report
    # get list of reports and display them
    my $group = $input->param('group');
    my $subgroup = $input->param('subgroup');
    $filter->{group} = $group;
    $filter->{subgroup} = $subgroup;
    $template->param(
        'saved1' => 1,
        'savedreports' => get_saved_reports($filter),
        'usecache' => $usecache,
        'groups_with_subgroups'=> groups_with_subgroups($group, $subgroup),
    );
}

elsif ( $phase eq 'Delete Multiple') {
    my @ids = $input->param('ids');
    delete_report( @ids );
    print $input->redirect("/cgi-bin/koha/reports/guided_reports.pl?phase=Use%20saved");
    exit;
}

elsif ( $phase eq 'Delete Saved') {
	
	# delete a report from the saved reports list
    my $ids = $input->param('reports');
    delete_report($ids);
    print $input->redirect("/cgi-bin/koha/reports/guided_reports.pl?phase=Use%20saved");
	exit;
}		

elsif ( $phase eq 'Show SQL'){
	
    my $id = $input->param('reports');
    my $report = get_saved_report($id);
    $template->param(
        'id'      => $id,
        'reportname' => $report->{report_name},
        'notes'      => $report->{notes},
	'sql'     => $report->{savedsql},
	'showsql' => 1,
    );
}

elsif ( $phase eq 'Edit SQL'){
    my $id = $input->param('reports');
    my $report = get_saved_report($id);
    my $group = $report->{report_group};
    my $subgroup  = $report->{report_subgroup};
    $template->param(
        'sql'        => $report->{savedsql},
        'reportname' => $report->{report_name},
        'groups_with_subgroups' => groups_with_subgroups($group, $subgroup),
        'notes'      => $report->{notes},
        'id'         => $id,
        'cache_expiry' => $report->{cache_expiry},
        'public' => $report->{public},
        'usecache' => $usecache,
        'editsql'    => 1,
    );
}

elsif ( $phase eq 'Update SQL'){
    my $id         = $input->param('id');
    my $sql        = $input->param('sql');
    my $reportname = $input->param('reportname');
    my $group      = $input->param('group');
    my $subgroup   = $input->param('subgroup');
    my $notes      = $input->param('notes');
    my $cache_expiry = $input->param('cache_expiry');
    my $cache_expiry_units = $input->param('cache_expiry_units');
    my $public = $input->param('public');
    my $save_anyway = $input->param('save_anyway');

    my @errors;

    # if we have the units, then we came from creating a report from SQL and thus need to handle converting units
    if( $cache_expiry_units ){
      if( $cache_expiry_units eq "minutes" ){
        $cache_expiry *= 60;
      } elsif( $cache_expiry_units eq "hours" ){
        $cache_expiry *= 3600; # 60 * 60
      } elsif( $cache_expiry_units eq "days" ){
        $cache_expiry *= 86400; # 60 * 60 * 24
      }
    }
    # check $cache_expiry isnt too large, Memcached::set requires it to be less than 30 days or it will be treated as if it were an absolute time stamp
    if( $cache_expiry >= 2592000 ){
      push @errors, {cache_expiry => $cache_expiry};
    }

    create_non_existing_group_and_subgroup($input, $group, $subgroup);

    if ($sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i) {
        push @errors, {sqlerr => $1};
    }
    elsif ($sql !~ /^(SELECT)/i) {
        push @errors, {queryerr => 1};
    }

    if (@errors) {
        $template->param(
            'errors'    => \@errors,
            'sql'       => $sql,
        );
    } else {

        # Check defined SQL parameters for authorised value validity
        my $problematic_authvals = ValidateSQLParameters($sql);

        if ( scalar @$problematic_authvals > 0 && not $save_anyway ) {
            # There's at least one problematic parameter, report to the
            # GUI and provide all user input for further actions
            $template->param(
                'id' => $id,
                'sql' => $sql,
                'reportname' => $reportname,
                'group' => $group,
                'subgroup' => $subgroup,
                'notes' => $notes,
                'public' => $public,
                'problematic_authvals' => $problematic_authvals,
                'warn_authval_problem' => 1,
                'phase_update' => 1
            );

        } else {
            # No params problem found or asked to save anyway
            update_sql( $id, {
                    sql => $sql,
                    name => $reportname,
                    group => $group,
                    subgroup => $subgroup,
                    notes => $notes,
                    public => $public,
                } );
            $template->param(
                'save_successful'       => 1,
                'reportname'            => $reportname,
                'id'                    => $id,
            );
        }
        if ( $usecache ) {
            $template->param(
                cache_expiry => $cache_expiry,
                cache_expiry_units => $cache_expiry_units,
            );
        }
    }
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
    my $cache_expiry_units = $input->param('cache_expiry_units'),
    my $cache_expiry = $input->param('cache_expiry');

    # we need to handle converting units
    if( $cache_expiry_units eq "minutes" ){
      $cache_expiry *= 60;
    } elsif( $cache_expiry_units eq "hours" ){
      $cache_expiry *= 3600; # 60 * 60
    } elsif( $cache_expiry_units eq "days" ){
      $cache_expiry *= 86400; # 60 * 60 * 24
    }
    # check $cache_expiry isnt too large, Memcached::set requires it to be less than 30 days or it will be treated as if it were an absolute time stamp
    if( $cache_expiry >= 2592000 ){ # oops, over the limit of 30 days
      # report error to user
      $template->param(
        'cache_error' => 1,
        'build1' => 1,
        'areas'   => get_report_areas(),
        'cache_expiry' => $cache_expiry,
        'usecache' => $usecache,
        'public' => $input->param('public'),
      );
    } else {
      # they have choosen a new report and the area to report on
      $template->param(
          'build2' => 1,
          'area'   => $input->param('area'),
          'types'  => get_report_types(),
          'cache_expiry' => $cache_expiry,
          'public' => $input->param('public'),
      );
    }
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
        columns  => get_columns($area,$input),
        'cache_expiry' => $input->param('cache_expiry'),
        'public' => $input->param('public'),
    );
}

elsif ( $phase eq 'Choose these columns' ) {
    # we now know type, area, and columns
    # next step is the constraints
    my $area    = $input->param('area');
    my $type    = $input->param('type');
    my @columns = $input->param('columns');
    my $column  = join( ',', @columns );

    $template->param(
        'build4' => 1,
        'area'   => $area,
        'type'   => $type,
        'column' => $column,
        definitions => get_from_dictionary($area),
        criteria    => get_criteria($area,$input),
        'public' => $input->param('public'),
    );
    if ( $usecache ) {
        $template->param(
            cache_expiry => $input->param('cache_expiry'),
            cache_expiry_units => $input->param('cache_expiry_units'),
        );
    }

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

        # If value is not defined, then it may be range values
        if (!defined $value) {

            my $fromvalue = $input->param( "from_" . $crit . "_value" );
            my $tovalue   = $input->param( "to_"   . $crit . "_value" );

            # If the range values are dates
            if ($fromvalue =~ C4::Dates->regexp('syspref') && $tovalue =~ C4::Dates->regexp('syspref')) {
                $fromvalue = C4::Dates->new($fromvalue)->output("iso");
                $tovalue = C4::Dates->new($tovalue)->output("iso");
            }

            if ($fromvalue && $tovalue) {
                $query_criteria .= " AND $crit >= '$fromvalue' AND $crit <= '$tovalue'";
            }

        } else {

            # If value is a date
            if ($value =~ C4::Dates->regexp('syspref')) {
                $value = C4::Dates->new($value)->output("iso");
            }
            # don't escape runtime parameters, they'll be at runtime
            if ($value =~ /<<.*>>/) {
                $query_criteria .= " AND $crit=$value";
            } else {
                $query_criteria .= " AND $crit='$value'";
            }
        }
    }
    $template->param(
        'build5'         => 1,
        'area'           => $area,
        'type'           => $type,
        'column'         => $column,
        'definition'     => $definition,
        'criteriastring' => $query_criteria,
        'public' => $input->param('public'),
    );
    if ( $usecache ) {
        $template->param(
            cache_expiry => $input->param('cache_expiry'),
            cache_expiry_units => $input->param('cache_expiry_units'),
        );
    }

    # get columns
    my @columns = split( ',', $column );
    my @total_by;

    # build structue for use by tmpl_loop to choose columns to order by
    # need to do something about the order of the order :)
	# we also want to use the %columns hash to get the plain english names
    foreach my $col (@columns) {
        my %total = (name => $col);
        my @selects = map {+{ value => $_ }} (qw(sum min max avg count));
        $total{'select'} = \@selects;
        push @total_by, \%total;
    }

    $template->param( 'total_by' => \@total_by );
}

elsif ( $phase eq 'Choose these operations' ) {
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
        'definition'     => $definition,
        'cache_expiry' => $input->param('cache_expiry'),
        'public' => $input->param('public'),
    );

    # get columns
    my @columns = split( ',', $column );
    my @order_by;

    # build structue for use by tmpl_loop to choose columns to order by
    # need to do something about the order of the order :)
    foreach my $col (@columns) {
        my %order = (name => $col);
        my @selects = map {+{ value => $_ }} (qw(asc desc));
        $order{'select'} = \@selects;
        push @order_by, \%order;
    }

    $template->param( 'order_by' => \@order_by );
}

elsif ( $phase eq 'Build report' ) {

    # now we have all the info we need and can build the sql
    my $area     = $input->param('area');
    my $type     = $input->param('type');
    my $column   = $input->param('column');
    my $crit     = $input->param('criteria');
    my $totals   = $input->param('totals');
    my $definition = $input->param('definition');
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
        'area'       => $area,
        'sql'        => $sql,
        'type'       => $type,
        'cache_expiry' => $input->param('cache_expiry'),
        'public' => $input->param('public'),
    );
}

elsif ( $phase eq 'Save' ) {
    # Save the report that has just been built
    my $area           = $input->param('area');
    my $sql  = $input->param('sql');
    my $type = $input->param('type');
    $template->param(
        'save' => 1,
        'area'  => $area,
        'sql'  => $sql,
        'type' => $type,
        'cache_expiry' => $input->param('cache_expiry'),
        'public' => $input->param('public'),
        'groups_with_subgroups' => groups_with_subgroups($area), # in case we have a report group that matches area
    );
}

elsif ( $phase eq 'Save Report' ) {
    # save the sql pasted in by a user
    my $area  = $input->param('area');
    my $group = $input->param('group');
    my $subgroup = $input->param('subgroup');
    my $sql   = $input->param('sql');
    my $name  = $input->param('reportname');
    my $type  = $input->param('types');
    my $notes = $input->param('notes');
    my $cache_expiry = $input->param('cache_expiry');
    my $cache_expiry_units = $input->param('cache_expiry_units');
    my $public = $input->param('public');
    my $save_anyway = $input->param('save_anyway');


    # if we have the units, then we came from creating a report from SQL and thus need to handle converting units
    if( $cache_expiry_units ){
      if( $cache_expiry_units eq "minutes" ){
        $cache_expiry *= 60;
      } elsif( $cache_expiry_units eq "hours" ){
        $cache_expiry *= 3600; # 60 * 60
      } elsif( $cache_expiry_units eq "days" ){
        $cache_expiry *= 86400; # 60 * 60 * 24
      }
    }
    # check $cache_expiry isnt too large, Memcached::set requires it to be less than 30 days or it will be treated as if it were an absolute time stamp
    if( $cache_expiry && $cache_expiry >= 2592000 ){
      push @errors, {cache_expiry => $cache_expiry};
    }

    create_non_existing_group_and_subgroup($input, $group, $subgroup);

    ## FIXME this is AFTER entering a name to save the report under
    if ($sql =~ /;?\W?(UPDATE|DELETE|DROP|INSERT|SHOW|CREATE)\W/i) {
        push @errors, {sqlerr => $1};
    }
    elsif ($sql !~ /^(SELECT)/i) {
        push @errors, {queryerr => "No SELECT"};
    }

    if (@errors) {
        $template->param(
            'errors'    => \@errors,
            'sql'       => $sql,
            'reportname'=> $name,
            'type'      => $type,
            'notes'     => $notes,
            'cache_expiry' => $cache_expiry,
            'public'    => $public,
        );
    } else {
        # Check defined SQL parameters for authorised value validity
        my $problematic_authvals = ValidateSQLParameters($sql);

        if ( scalar @$problematic_authvals > 0 && not $save_anyway ) {
            # There's at least one problematic parameter, report to the
            # GUI and provide all user input for further actions
            $template->param(
                'area' => $area,
                'group' =>  $group,
                'subgroup' => $subgroup,
                'sql' => $sql,
                'reportname' => $name,
                'type' => $type,
                'notes' => $notes,
                'public' => $public,
                'problematic_authvals' => $problematic_authvals,
                'warn_authval_problem' => 1,
                'phase_save' => 1
            );
            if ( $usecache ) {
                $template->param(
                    cache_expiry => $cache_expiry,
                    cache_expiry_units => $cache_expiry_units,
                );
            }
        } else {
            # No params problem found or asked to save anyway
            my $id = save_report( {
                    borrowernumber => $borrowernumber,
                    sql            => $sql,
                    name           => $name,
                    area           => $area,
                    group          => $group,
                    subgroup       => $subgroup,
                    type           => $type,
                    notes          => $notes,
                    cache_expiry   => $cache_expiry,
                    public         => $public,
                } );
            $template->param(
                'save_successful' => 1,
                'reportname'      => $name,
                'id'              => $id,
            );
        }
    }
}

elsif ($phase eq 'Run this report'){
    # execute a saved report
    my $limit      = $input->param('limit') || 20;
    my $offset     = 0;
    my $report_id  = $input->param('reports');
    my @sql_params = $input->param('sql_params');
    # offset algorithm
    if ($input->param('page')) {
        $offset = ($input->param('page') - 1) * $limit;
    }

    $template->param(
        'limit'   => $limit,
        'report_id' => $report_id,
    );

    my ( $sql, $type, $name, $notes );
    if (my $report = get_saved_report($report_id)) {
        $sql   = $report->{savedsql};
        $name  = $report->{report_name};
        $notes = $report->{notes};

        my @rows = ();
        # if we have at least 1 parameter, and it's not filled, then don't execute but ask for parameters
        if ($sql =~ /<</ && !@sql_params) {
            # split on ??. Each odd (2,4,6,...) entry should be a parameter to fill
            my @split = split /<<|>>/,$sql;
            my @tmpl_parameters;
            my @authval_errors;
            for(my $i=0;$i<($#split/2);$i++) {
                my ($text,$authorised_value) = split /\|/,$split[$i*2+1];
                my $input;
                my $labelid;
                if ( not defined $authorised_value ) {
                    # no authorised value input, provide a text box
                    $input = "text";
                } elsif ( $authorised_value eq "date" ) {
                    # require a date, provide a date picker
                    $input = 'date';
                } else {
                    # defined $authorised_value, and not 'date'
                    my $dbh=C4::Context->dbh;
                    my @authorised_values;
                    my %authorised_lib;
                    # builds list, depending on authorised value...
                    if ( $authorised_value eq "branches" ) {
                        my $branches = GetBranchesLoop();
                        foreach my $thisbranch (@$branches) {
                            push @authorised_values, $thisbranch->{value};
                            $authorised_lib{$thisbranch->{value}} = $thisbranch->{branchname};
                        }
                    }
                    elsif ( $authorised_value eq "itemtypes" ) {
                        my $sth = $dbh->prepare("SELECT itemtype,description FROM itemtypes ORDER BY description");
                        $sth->execute;
                        while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
                            push @authorised_values, $itemtype;
                            $authorised_lib{$itemtype} = $description;
                        }
                    }
                    elsif ( $authorised_value eq "biblio_framework" ) {
                        my $frameworks = GetFrameworksLoop();
                        my $default_source = '';
                        push @authorised_values,$default_source;
                        $authorised_lib{$default_source} = 'Default';
                        foreach my $framework (@$frameworks) {
                            push @authorised_values, $framework->{value};
                            $authorised_lib{$framework->{value}} = $framework->{description};
                        }
                    }
                    elsif ( $authorised_value eq "cn_source" ) {
                        my $class_sources = GetClassSources();
                        my $default_source = C4::Context->preference("DefaultClassificationSource");
                        foreach my $class_source (sort keys %$class_sources) {
                            next unless $class_sources->{$class_source}->{'used'} or
                                        ($class_source eq $default_source);
                            push @authorised_values, $class_source;
                            $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
                        }
                    }
                    elsif ( $authorised_value eq "categorycode" ) {
                        my $sth = $dbh->prepare("SELECT categorycode, description FROM categories ORDER BY description");
                        $sth->execute;
                        while ( my ( $categorycode, $description ) = $sth->fetchrow_array ) {
                            push @authorised_values, $categorycode;
                            $authorised_lib{$categorycode} = $description;
                        }

                        #---- "true" authorised value
                    }
                    else {
                        if ( IsAuthorisedValueCategory($authorised_value) ) {
                            my $query = '
                            SELECT authorised_value,lib
                            FROM authorised_values
                            WHERE category=?
                            ORDER BY lib
                            ';
                            my $authorised_values_sth = $dbh->prepare($query);
                            $authorised_values_sth->execute( $authorised_value);

                            while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
                                push @authorised_values, $value;
                                $authorised_lib{$value} = $lib;
                                # For item location, we show the code and the libelle
                                $authorised_lib{$value} = $lib;
                            }
                        } else {
                            # not exists $authorised_value_categories{$authorised_value})
                            push @authval_errors, {'entry' => $text,
                                                   'auth_val' => $authorised_value };
                            # tell the template there's an error
                            $template->param( auth_val_error => 1 );
                            # skip scrolling list creation and params push
                            next;
                        }
                    }
                    $labelid = $text;
                    $labelid =~ s/\W//g;
                    $input =CGI::scrolling_list(      # FIXME: factor out scrolling_list
                        -name     => "sql_params",
                        -id       => "sql_params_".$labelid,
                        -values   => \@authorised_values,
#                     -default  => $value,
                        -labels   => \%authorised_lib,
                        -override => 1,
                        -size     => 1,
                        -multiple => 0,
                        -tabindex => 1,
                    );
                }

                push @tmpl_parameters, {'entry' => $text, 'input' => $input, 'labelid' => $labelid };
            }
            $template->param('sql'         => $sql,
                            'name'         => $name,
                            'sql_params'   => \@tmpl_parameters,
                            'auth_val_errors'  => \@authval_errors,
                            'enter_params' => 1,
                            'reports'      => $report_id,
                            );
        } else {
            # OK, we have parameters, or there are none, we run the report
            # if there were parameters, replace before running
            # split on ??. Each odd (2,4,6,...) entry should be a parameter to fill
            my @split = split /<<|>>/,$sql;
            my @tmpl_parameters;
            for(my $i=0;$i<$#split/2;$i++) {
                my $quoted = C4::Context->dbh->quote($sql_params[$i]);
                # if there are special regexp chars, we must \ them
                $split[$i*2+1] =~ s/(\||\?|\.|\*|\(|\)|\%)/\\$1/g;
                $sql =~ s/<<$split[$i*2+1]>>/$quoted/;
            }
            my ($sth, $errors) = execute_query($sql, $offset, $limit);
            my $total = nb_rows($sql) || 0;
            unless ($sth) {
                die "execute_query failed to return sth for report $report_id: $sql";
            } else {
                my $headers= header_cell_loop($sth);
                $template->param(header_row => $headers);
                while (my $row = $sth->fetchrow_arrayref()) {
                    my @cells = map { +{ cell => $_ } } @$row;
                    push @rows, { cells => \@cells };
                }
            }

            my $totpages = int($total/$limit) + (($total % $limit) > 0 ? 1 : 0);
            my $url = "/cgi-bin/koha/reports/guided_reports.pl?reports=$report_id&amp;phase=Run%20this%20report&amp;limit=$limit";
            if (@sql_params) {
                $url = join('&amp;sql_params=', $url, map { URI::Escape::uri_escape($_) } @sql_params);
            }
            $template->param(
                'results' => \@rows,
                'sql'     => $sql,
                'id'      => $report_id,
                'execute' => 1,
                'name'    => $name,
                'notes'   => $notes,
                'errors'  => defined($errors) ? [ $errors ] : undef,
                'pagination_bar'  => pagination_bar($url, $totpages, $input->param('page')),
                'unlimited_total' => $total,
                'sql_params'      => \@sql_params,
            );
        }
    }
    else {
        push @errors, { no_sql_for_id => $report_id };
    }
}

elsif ($phase eq 'Export'){

	# export results to tab separated text or CSV
	my $sql    = $input->param('sql');  # FIXME: use sql from saved report ID#, not new user-supplied SQL!
    my $format = $input->param('format');
	my ($sth, $q_errors) = execute_query($sql);
    unless ($q_errors and @$q_errors) {
        my ( $type, $content );
        if ($format eq 'tab') {
            $type = 'application/octet-stream';
            $content .= join("\t", header_cell_values($sth)) . "\n";
            while (my $row = $sth->fetchrow_arrayref()) {
                $content .= join("\t", @$row) . "\n";
            }
        } else {
            my $delimiter = C4::Context->preference('delimiter') || ',';
            if ( $format eq 'csv' ) {
                $type = 'application/csv';
                my $csv = Text::CSV::Encoded->new({ encoding_out => 'utf8', sep_char => $delimiter});
                $csv or die "Text::CSV::Encoded->new({binary => 1}) FAILED: " . Text::CSV::Encoded->error_diag();
                if ($csv->combine(header_cell_values($sth))) {
                    $content .= $csv->string(). "\n";
                } else {
                    push @$q_errors, { combine => 'HEADER ROW: ' . $csv->error_diag() } ;
                }
                while (my $row = $sth->fetchrow_arrayref()) {
                    if ($csv->combine(@$row)) {
                        $content .= $csv->string() . "\n";
                    } else {
                        push @$q_errors, { combine => $csv->error_diag() } ;
                    }
                }
            }
            elsif ( $format eq 'ods' ) {
                $type = 'application/vnd.oasis.opendocument.spreadsheet';
                my $ods_fh = File::Temp->new( UNLINK => 0 );
                my $ods_filepath = $ods_fh->filename;

                use OpenOffice::OODoc;
                my $tmpdir = dirname $ods_filepath;
                odfWorkingDirectory( $tmpdir );
                my $container = odfContainer( $ods_filepath, create => 'spreadsheet' );
                my $doc = odfDocument (
                    container => $container,
                    part      => 'content'
                );
                my $table = $doc->getTable(0);
                my @headers = header_cell_values( $sth );
                my $rows = $sth->fetchall_arrayref();
                my ( $nb_rows, $nb_cols ) = ( 0, 0 );
                $nb_rows = @$rows;
                $nb_cols = @headers;
                $doc->expandTable( $table, $nb_rows + 1, $nb_cols );

                my $row = $doc->getRow( $table, 0 );
                my $j = 0;
                for my $header ( @headers ) {
                    $doc->cellValue( $row, $j, $header );
                    $j++;
                }
                my $i = 1;
                for ( @$rows ) {
                    $row = $doc->getRow( $table, $i );
                    for ( my $j = 0 ; $j < $nb_cols ; $j++ ) {
                        my $value = Encode::encode( 'UTF8', $rows->[$i - 1][$j] );
                        $doc->cellValue( $row, $j, $value );
                    }
                    $i++;
                }
                $doc->save();
                binmode(STDOUT);
                open $ods_fh, '<', $ods_filepath;
                $content .= $_ while <$ods_fh>;
                unlink $ods_filepath;
            }
        }
        print $input->header(
            -type => $type,
            -attachment=>"reportresults.$format"
        );
        print $content;

        foreach my $err (@$q_errors, @errors) {
            print "# ERROR: " . (map {$_ . ": " . $err->{$_}} keys %$err) . "\n";
        }   # here we print all the non-fatal errors at the end.  Not super smooth, but better than nothing.
        exit;
    }
    $template->param(
        'sql'           => $sql,
        'execute'       => 1,
        'name'          => 'Error exporting report!',
        'notes'         => '',
        'errors'        => $q_errors,
    );
}

elsif ( $phase eq 'Create report from SQL' ) {

    my ($group, $subgroup);
    # allow the user to paste in sql
    if ( $input->param('sql') ) {
        $group = $input->param('report_group');
        $subgroup  = $input->param('report_subgroup');
        $template->param(
            'sql'           => $input->param('sql') // '',
            'reportname'    => $input->param('reportname') // '',
            'notes'         => $input->param('notes') // '',
        );
    }
    $template->param(
        'create' => 1,
        'groups_with_subgroups' => groups_with_subgroups($group, $subgroup),
        'public' => '0',
        'cache_expiry' => 300,
        'usecache' => $usecache,
    );
}

elsif ($phase eq 'Create Compound Report'){
	$template->param( 'savedreports' => get_saved_reports(),
		'compound' => 1,
	);
}

elsif ($phase eq 'Save Compound'){
    my $master    = $input->param('master');
	my $subreport = $input->param('subreport');
	my ($mastertables,$subtables) = create_compound($master,$subreport);
	$template->param( 'save_compound' => 1,
		master=>$mastertables,
		subsql=>$subtables
	);
}

# pass $sth, get back an array of names for the column headers
sub header_cell_values {
    my $sth = shift or return ();
    my @cols;
    foreach my $c (@{$sth->{NAME}}) {
        # TODO in Bug 11944
        #FIXME apparently DBI still needs a utf8 fix for this?
        utf8::decode($c);
        push @cols, $c;
    }
    return @cols;
}

# pass $sth, get back a TMPL_LOOP-able set of names for the column headers
sub header_cell_loop {
    my @headers = map { +{ cell => $_ } } header_cell_values (shift);
    return \@headers;
}

foreach (1..6) {
     $template->{VARS}->{'build' . $_} and $template->{VARS}->{'buildx' . $_} and last;
}
$template->param(   'referer' => $input->referer(),
                );

output_html_with_http_headers $input, $cookie, $template->output;

sub groups_with_subgroups {
    my ($group, $subgroup) = @_;

    my $groups_with_subgroups = get_report_groups();
    my @g_sg;
    my @sorted_keys = sort {
        $groups_with_subgroups->{$a}->{name} cmp $groups_with_subgroups->{$b}->{name}
    } keys %$groups_with_subgroups;
    foreach my $g_id (@sorted_keys) {
        my $v = $groups_with_subgroups->{$g_id};
        my @subgroups;
        if (my $sg = $v->{subgroups}) {
            foreach my $sg_id (sort { $sg->{$a} cmp $sg->{$b} } keys %$sg) {
                push @subgroups, {
                    id => $sg_id,
                    name => $sg->{$sg_id},
                    selected => ($group && $g_id eq $group && $subgroup && $sg_id eq $subgroup ),
                };
            }
        }
        push @g_sg, {
            id => $g_id,
            name => $v->{name},
            selected => ($group && $g_id eq $group),
            subgroups => \@subgroups,
        };
    }
    return \@g_sg;
}

sub create_non_existing_group_and_subgroup {
    my ($input, $group, $subgroup) = @_;

    if (defined $group and $group ne '') {
        my $report_groups = C4::Reports::Guided::get_report_groups;
        if (not exists $report_groups->{$group}) {
            my $groupdesc = $input->param('groupdesc') // $group;
            C4::Koha::AddAuthorisedValue('REPORT_GROUP', $group, $groupdesc);
        }
        if (defined $subgroup and $subgroup ne '') {
            if (not exists $report_groups->{$group}->{subgroups}->{$subgroup}) {
                my $subgroupdesc = $input->param('subgroupdesc') // $subgroup;
                C4::Koha::AddAuthorisedValue('REPORT_SUBGROUP', $subgroup, $subgroupdesc, $group);
            }
        }
    }
}
