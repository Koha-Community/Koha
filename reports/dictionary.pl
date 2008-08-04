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
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use strict;
use C4::Auth;
use CGI;
use C4::Output;
use C4::Reports;
use C4::Dates qw( DHTMLcalendar );

=head1 NAME

Script to control the guided report creation

=head1 DESCRIPTION


=over2

=cut

my $input = new CGI;
my $referer = $input->referer();

my $phase = $input->param('phase');
my $no_html = 0; # this will be set if we dont want to print out an html::template
my 	( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/dictionary.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
	);

if ($phase eq 'View Dictionary'){
	# view the dictionary we use to set up abstract variables such as all borrowers over fifty who live in a certain town
	my $areas = C4::Reports::get_report_areas();
	my $definitions = get_from_dictionary();
	$template->param( 'areas' => $areas ,
		'start_dictionary' => 1,
		'definitions' => $definitions,
	);
}
elsif ($phase eq 'Add New Definition'){
	# display form allowing them to add a new definition
	$template->param( 'new_dictionary' => 1,
		);
}

elsif ($phase eq 'New Term step 2'){
	# Choosing the area
	my $areas = C4::Reports::get_report_areas();
	my $definition_name=$input->param('definition_name');
	my $definition_description=$input->param('definition_description');		
	$template->param( 'step_2' => 1,
		'areas' => $areas,
		'definition_name' => $definition_name,
		'definition_description' => $definition_description,
	);
}

elsif ($phase eq 'New Term step 3'){
	# Choosing the columns
	my $area = $input->param('areas');
	my $columns = get_columns($area,$input);
	my $definition_name=$input->param('definition_name');
	my $definition_description=$input->param('definition_description');		
	$template->param( 'step_3' => 1,
		'area' => $area,
		'columns' => $columns,
		'definition_name' => $definition_name,
		'definition_description' => $definition_description,
	);
}

elsif ($phase eq 'New Term step 4'){
	# Choosing the values
	my $area=$input->param('area');
	my $definition_name=$input->param('definition_name');
	my $definition_description=$input->param('definition_description');		
    my @columns = $input->param('columns');
	my $columnstring = join (',',@columns);
	my @column_loop;
	foreach my $column (@columns){
		my %tmp_hash;
		$tmp_hash{'name'}=$column;
		my $type =get_column_type($column);
		if ($type eq 'distinct'){
			my $values = get_distinct_values($column);
			$tmp_hash{'values'} = $values;
			$tmp_hash{'distinct'} = 1;
			  
		}
		if ($type eq 'DATE' || $type eq 'DATETIME'){
			$tmp_hash{'date'}=1;
		}
		if ($type eq 'TEXT'){
			$tmp_hash{'text'}=1;
		}
#		else {
#			warn $type;#
#			}
		push @column_loop,\%tmp_hash;
		}

	$template->param( 'step_4' => 1,
		'area' => $area,
		'definition_name' => $definition_name,
		'definition_description' => $definition_description,
		'columns' => \@column_loop,
		'columnstring' => $columnstring,
                'DHTMLcalendar_dateformat' => C4::Dates->DHTMLcalendar(),
	);
}

elsif ($phase eq 'New Term step 5'){
	# Confirmation screen
	my $areas = C4::Reports::get_report_areas();
	my $area = $input->param('area');
    my $areaname = $areas->[$area - 1]->{'name'};
	my $columnstring = $input->param('columnstring');
	my $definition_name=$input->param('definition_name');
	my $definition_description=$input->param('definition_description');	
	my @criteria = $input->param('criteria_column'); 
	my $query_criteria;
	my @criteria_loop;
	foreach my $crit (@criteria) {
		my $value = $input->param( $crit . "_value" );
		if ($value) {
                    my %tmp_hash;
                    $tmp_hash{'name'}=$crit;
                    $tmp_hash{'value'} = $value;
                    push @criteria_loop,\%tmp_hash;
                    if ($value =~ C4::Dates->regexp(C4::Context->preference('dateformat'))) {    
                        my $date = C4::Dates->new($value);
                        $value = $date->output("iso");
                    }
                    $query_criteria .= " AND $crit='$value'";
		}
		$value = $input->param( $crit . "_start_value" );
		if ($value) {
                    my %tmp_hash;
                    $tmp_hash{'name'}="$crit Start";
                    $tmp_hash{'value'} = $value;
                    push @criteria_loop,\%tmp_hash;
                    if ($value =~ C4::Dates->regexp(C4::Context->preference('dateformat'))) {    
                        my $date = C4::Dates->new($value);
                        $value = $date->output("iso");
                    }
                    $query_criteria .= " AND $crit >= '$value'";
		}
		$value = $input->param( $crit . "_end_value" );
		if ($value) {
                    my %tmp_hash;
                    $tmp_hash{'name'}="$crit End";
                    $tmp_hash{'value'} = $value;
                    push @criteria_loop,\%tmp_hash;
                    if ($value =~ C4::Dates->regexp(C4::Context->preference('dateformat'))) {    
                        my $date = C4::Dates->new($value);
                        $value = $date->output("iso");
                    }
                    $query_criteria .= " AND $crit <= '$value'";
		}		  
	}
	$template->param( 'step_5' => 1,
		'area' => $area,
		'areaname' => $areaname,
		'definition_name' => $definition_name,
		'definition_description' => $definition_description,
		'query' => $query_criteria,
		'columnstring' => $columnstring,
		'criteria_loop' => \@criteria_loop,
	);
}

elsif ($phase eq 'New Term step 6'){
	# Saving
	my $area = $input->param('area');
	my $definition_name=$input->param('definition_name');
	my $definition_description=$input->param('definition_description');		
	my $sql=$input->param('sql');
	save_dictionary($definition_name,$definition_description,$sql,$area);
	$no_html=1;
	print $input->redirect("/cgi-bin/koha/reports/dictionary.pl?phase=View%20Dictionary");	

}
elsif ($phase eq 'Delete Definition'){
	$no_html=1;
	my $id = $input->param('id');
	delete_definition($id);
	print $input->redirect("/cgi-bin/koha/reports/dictionary.pl?phase=View%20Dictionary");
	}

$template->param( 'referer' => $referer );


if (!$no_html){
	output_html_with_http_headers $input, $cookie, $template->output;
}
