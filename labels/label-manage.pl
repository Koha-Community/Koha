#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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
use warnings;
use vars qw($debug);

use CGI;
use Data::Dumper;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Labels;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-manage.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $db_rows = {};
my $display_columns = { layout =>   [  # db column       => {col label                  is link?
                                        {layout_id       => {label => 'Layout ID',      link_field      => 0}},
                                        {layout_name     => {label => 'Layout',         link_field      => 0}},
                                        {barcode_type    => {label => 'Barcode Type',   link_field      => 0}},
                                        {printing_type   => {label => 'Print Type',     link_field      => 0}},
                                        {format_string   => {label => 'Fields to Print',link_field      => 0}},
                                        {select          => {label => 'Select',         value           => 'layout_id'}},
                                    ],
                        template => [   {template_id     => {label => 'Template ID',    link_field      => 0}},
                                        {template_code   => {label => 'Template Name',  link_field      => 0}},
                                        {template_desc   => {label => 'Description',    link_field      => 0}},
                                        {select          => {label => 'Select',         value           => 'template_id'}},
                                    ],
                        profile =>  [   {profile_id      => {label => 'Profile ID',     link_field      => 0}},
                                        {printer_name    => {label => 'Printer Name',   link_field      => 0}},
                                        {paper_bin       => {label => 'Paper Bin',      link_field      => 0}},
                                        {_template_code  => {label => 'Template Name',  link_field      => 0}},     # this display column does not have a corrisponding db column in the profile table, hence the underscore
                                        {select          => {label => 'Select',         value           => 'profile_id'}},
                                    ],
                        batch =>    [   {batch_id        => {label => 'Batch ID',       link_field      => 0}},
                                        {_item_count     => {label => 'Item Count',     link_field      => 0}},
                                        {select          => {label => 'Select',         value           => 'batch_id'}},
                                    ],
};

my $label_element = $cgi->param('label_element') || 'template';   # default to template managment
my $op = $cgi->param('op') || 'none';
my $element_id = $cgi->param('element_id') || undef;
my $error = $cgi->param('error') || 0;

my $branch_code = ($label_element eq 'batch' ? C4::Context->userenv->{'branch'} : '');

if ($op eq 'delete') {
    if          ($label_element eq 'layout')    {$error = C4::Labels::Layout::delete(layout_id => $element_id);}
    elsif       ($label_element eq 'template')  {$error = C4::Labels::Template::delete(template_id => $element_id);}
    elsif       ($label_element eq 'profile')   {$error = C4::Labels::Profile::delete(profile_id => $element_id);}
    elsif       ($label_element eq 'batch')     {$error = C4::Labels::Batch::delete(batch_id => $element_id, branch_code => $branch_code);}
    else                                        {}      # FIXME: Some error trapping code
}

if      ($label_element eq 'layout')    {$db_rows = get_all_layouts(table_name => 'creator_layouts', filter => 'creator=\'Labels\'');}
elsif   ($label_element eq 'template')  {$db_rows = get_all_templates(table_name => 'creator_templates', filter => 'creator=\'Labels\'');}
elsif   ($label_element eq 'profile')   {$db_rows = get_all_profiles(table_name => 'printers_profile', filter => 'creator=\'Labels\'');}
elsif   ($label_element eq 'batch')     {$db_rows = get_batch_summary(filter => "branch_code=\'$branch_code\' OR branch_code=\'NB\'", creator => 'Labels');}
else                                    {}      # FIXME: Some error trapping code

my $table = html_table($display_columns->{$label_element}, $db_rows);

$template->param(error => $error) if ($error) && ($error ne 0);
$template->param(print => 1) if ($label_element eq 'batch');
$template->param(
                op              => $op,
                element_id      => $element_id,
                table_loop      => $table,
                label_element   => $label_element,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
