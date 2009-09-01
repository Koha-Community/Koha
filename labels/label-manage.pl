#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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
use warnings;
use vars qw($debug);

use Sys::Syslog qw(syslog);
use Switch qw(Perl6);
use CGI;
use HTML::Template::Pro;
use Data::Dumper;

use C4::Auth;
use C4::Output;
use C4::Context;
use autouse 'C4::Branch' => qw(get_branch_code_from_name);
use C4::Debug;
use C4::Labels::Lib 1.000000 qw(get_all_templates get_all_layouts get_all_profiles get_batch_summary get_barcode_types get_label_types get_column_names get_table_names SELECT);
use C4::Labels::Layout 1.000000;
use C4::Labels::Template 1.000000;
use C4::Labels::Profile 1.000000;
use C4::Labels::Batch 1.000000;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-manage.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $error = 0;
my $db_rows = {};
my $display_columns = { layout =>   [  #db column       => display column 
                                        {layout_id       => 'Layout ID'},
                                        {layout_name     => 'Layout'},
                                        {barcode_type    => 'Barcode Type'},
                                        {printing_type   => 'Print Type'},
                                        {format_string   => 'Fields to Print'},
                                        {select          => 'Select'},
                                    ],
                        template => [   {template_id     => 'Template ID'},
                                        {template_code   => 'Template Name'},
                                        {template_desc   => 'Description'},
                                        {select          => 'Select'},
                                    ],
                        profile =>  [   {profile_id      => 'Profile ID'},
                                        {printer_name    => 'Printer Name'},
                                        {paper_bin       => 'Paper Bin'},
                                        {_template_code  => 'Template Name'},     # this display column does not have a corrisponding db column in the profile table, hence the underscore
                                        {select          => 'Select'},
                                    ],
                        batch =>    [   {batch_id        => 'Batch ID'},
                                        {_item_count     => 'Item Count'},
                                        {select          => 'Select'},
                                    ],
};

my $label_element = $cgi->param('label_element') || $ARGV[0];
my $op = $cgi->param('op') || $ARGV[1] || '';
my $element_id = $cgi->param('element_id') || $ARGV[2] || '';
my $branch_code = ($label_element eq 'batch' ? get_branch_code_from_name($template->param('LoginBranchname')) : '');

sub _build_table {
    my $headers = shift;
    my $data = shift;
    my $table = [];
    my $fields = [];
    my @db_columns = ();
    my ($row_index, $col_index) = (0,0);
    my $cols = 0;       # number of columns to wrap on
    my $field_count = 0;
    POPULATE_HEADER:
    foreach my $db_column (@$headers) {
        my @key = keys %$db_column;
        push (@db_columns, $key[0]);
        $$fields[$col_index] = {select_field => 0, field_name => ($key[0]), field_label => $db_column->{$key[0]}};
        $field_count++;
        $col_index++;
    }
    $$table[$row_index] = {header_fields => $fields};
    $cols = $col_index;
    $field_count *= scalar(@$data);     # total fields to be displayed in the table
    $col_index = 0;
    $row_index++;
    $fields = [];
    POPULATE_TABLE:
    foreach my $db_row (@$data) {
        my $element_id = 0;
        POPULATE_ROW:
        foreach my $db_column (@db_columns) {
            if (grep {$db_column eq $_} keys %$db_row) {
                $element_id = $db_row->{$db_column} if $db_column =~ m/id/;
                $$fields[$col_index] = {select_field => 0, field_name => ($db_column . "_tbl"), field_value => $db_row->{$db_column}};
                $col_index++;
                next POPULATE_ROW;
            }
            elsif ($db_column =~ m/^_((.*)_(.*$))/) {   # this a special case
                my $table_name = get_table_names($2);
                my $record_set = SELECT($1, @$table_name[0], $2 . "_id = " . $db_row->{$2 . "_id"});
                $$fields[$col_index] = {select_field => 0, field_name => ($db_column . "_tbl"), field_value => $$record_set[0]{$1}};
                $col_index++;
                next POPULATE_ROW;
            }
        }
        $$fields[$col_index] = {select_field => 1, field_name => 'select', field_value => $element_id};
        $$table[$row_index] = {text_fields => $fields};
        $col_index = 0;
        $row_index++;
        $fields = [];
    }
    return $table;
}

if ($op eq 'delete') {
    given ($label_element) {
        when 'layout'   {$error = C4::Labels::Layout::delete(layout_id => $element_id); last;}
        when 'template' {$error = C4::Labels::Template::delete(template_id => $element_id); last;}
        when 'profile'  {$error = C4::Labels::Profile::delete(profile_id => $element_id); last;}
        when 'batch'    {$error = C4::Labels::Batch::delete(batch_id => $element_id); last;}
        default         {}      # FIXME: Some error trapping code 
    }
}

given ($label_element) {
    when 'layout'       {$db_rows = get_all_layouts();}
    when 'template'     {$db_rows = get_all_templates();}
    when 'profile'      {$db_rows = get_all_profiles();}
    when 'batch'        {$db_rows = get_batch_summary(filter => "branch_code=\'$branch_code\'");}
    default             {}      # FIXME: Some error trapping code
}

my $table = _build_table($display_columns->{$label_element}, $db_rows);

$template->param(error => $error) if ($error ne 0);
$template->param(print => 1) if ($label_element eq 'batch');
$template->param(
                op              => $op,
                element_id      => $element_id,
                table_loop      => $table,
                label_element   => $label_element,
                label_element_title     => ($label_element eq 'layout' ? 'Layouts' :
                                            $label_element eq 'template' ? 'Templates' :
                                            $label_element eq 'profile' ? 'Profiles' :
                                            $label_element eq 'batch' ? 'Batches' :
                                            ''
                                            ),
);

output_html_with_http_headers $cgi, $cookie, $template->output;
