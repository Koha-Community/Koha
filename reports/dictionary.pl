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
# along with Koha; if not, see <https://www.gnu.org/licenses>.
use Modern::Perl;
use C4::Auth   qw( get_template_and_user );
use CGI        qw ( -utf8 );
use C4::Output qw( output_html_with_http_headers );
use C4::Reports::Guided
    qw( get_from_dictionary get_columns get_column_type get_distinct_values save_dictionary delete_definition get_report_areas );
use Koha::DateUtils qw( dt_from_string output_pref );

=head1 NAME

Script to control the guided report creation

=head1 DESCRIPTION

=cut

my $input   = CGI->new;
my $referer = $input->referer();

my $op                     = $input->param('op') || q{list};
my $definition_name        = $input->param('definition_name');
my $definition_description = $input->param('definition_description');
my $area                   = $input->param('area') || '';
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "reports/dictionary.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { reports => '*' },
    }
);

if ( $op eq 'add_form' ) {

    # display form allowing them to add a new definition
    $template->param( 'new_dictionary' => 1, );

} elsif ( $op eq 'cud-add_form_2' ) {

    # Choosing the area
    $template->param(
        'step_2'                 => 1,
        'areas'                  => areas($area),
        'definition_name'        => $definition_name,
        'definition_description' => $definition_description,
    );

} elsif ( $op eq 'cud-add_form_3' ) {

    # Choosing the columns
    $template->param(
        'step_3'                 => 1,
        'area'                   => $area,
        'columns'                => get_columns($area),
        'definition_name'        => $definition_name,
        'definition_description' => $definition_description,
    );

} elsif ( $op eq 'cud-add_form_4' ) {

    # Choosing the values
    my @columns      = $input->multi_param('columns');
    my $columnstring = join( ',', @columns );
    my $forbidden    = Koha::Report->new->check_columns( undef, \@columns );
    my @column_loop;
    unless ($forbidden) {
        foreach my $column (@columns) {
            my %tmp_hash;
            $tmp_hash{'name'} = $column;
            my $type = get_column_type($column);
            if ( $type eq 'distinct' ) {
                my $values = get_distinct_values($column);
                $tmp_hash{'values'}   = $values;
                $tmp_hash{'distinct'} = 1;

            }
            if ( $type eq 'DATE' || $type eq 'DATETIME' ) {
                $tmp_hash{'date'} = 1;
            }
            if ( $type eq 'TEXT' || $type eq 'MEDIUMTEXT' ) {
                $tmp_hash{'text'} = 1;
            }
            push @column_loop, \%tmp_hash;
        }
    }

    if (@column_loop) {
        $template->param(
            'step_4'                 => 1,
            'area'                   => $area,
            'definition_name'        => $definition_name,
            'definition_description' => $definition_description,
            'columns'                => \@column_loop,
            'columnstring'           => $columnstring,
        );
    } else {
        $template->param( 'new_dictionary' => 1, passworderr => 1 );
    }

} elsif ( $op eq 'cud-add_form_5' ) {

    # Confirmation screen
    my $columnstring = $input->param('columnstring');
    my @criteria     = $input->multi_param('criteria_column');
    my $query_criteria;
    my @criteria_loop;

    foreach my $crit (@criteria) {
        my $value = $input->param( $crit . "_value" );
        if ($value) {
            my %tmp_hash;
            $tmp_hash{'name'}  = $crit;
            $tmp_hash{'value'} = $value;
            push @criteria_loop, \%tmp_hash;

            $query_criteria .= " AND $crit='$value'";
        }

        if ( my $date_type_value = $input->param( $crit . "_date_type_value" ) ) {
            if ( $date_type_value eq 'range' ) {
                if ( $value = $input->param( $crit . "_start_value" ) ) {
                    my %tmp_hash;
                    $tmp_hash{'name'}  = "$crit Start";
                    $tmp_hash{'value'} = $value;
                    push @criteria_loop, \%tmp_hash;

                    $query_criteria .= " AND $crit >= '$value'";
                }

                if ( $value = $input->param( $crit . "_end_value" ) ) {
                    my %tmp_hash;
                    $tmp_hash{'name'}  = "$crit End";
                    $tmp_hash{'value'} = $value;
                    push @criteria_loop, \%tmp_hash;

                    $query_criteria .= " AND $crit <= '$value'";
                }
            }

            # else we want all dates
        }
    }
    $template->param(
        'step_5'                 => 1,
        'area'                   => $area,
        'definition_name'        => $definition_name,
        'definition_description' => $definition_description,
        'query'                  => $query_criteria,
        'columnstring'           => $columnstring,
        'criteria_loop'          => \@criteria_loop,
    );

} elsif ( $op eq 'cud-add_form_6' ) {

    # Saving
    my $area = $input->param('area');
    my $sql  = $input->param('sql');
    save_dictionary( $definition_name, $definition_description, $sql, $area );
    $op = "list";

} elsif ( $op eq 'cud-delete' ) {
    my $id = $input->param('id');
    delete_definition($id);
    $op = "list";
}

if ( $op eq 'list' ) {

    # view the dictionary we use to set up abstract variables such as all borrowers over fifty who live in a certain town
    my $definitions = get_from_dictionary($area);
    $template->param(
        'areas'            => areas($area),
        'start_dictionary' => 1,
        'definitions'      => $definitions,
    );
}

$template->param( 'referer' => $referer );

output_html_with_http_headers $input, $cookie, $template->output;

sub areas {

    my $selected = shift;

    my $areas = get_report_areas();
    my @a;
    foreach my $area (@$areas) {
        push @a, {
            id       => $area,
            selected => ( $area eq $selected )
        };
    }

    return \@a;
}
