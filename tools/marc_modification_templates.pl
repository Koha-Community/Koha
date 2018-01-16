#!/usr/bin/perl
# This file is part of Koha.
#
# Copyright 2010 Kyle M Hall <kyle.m.hall@gmail.com>
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

use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::MarcModificationTemplates;

my $cgi = new CGI;

my $op = $cgi->param('op') || q{};
my $template_id = $cgi->param('template_id');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({
            template_name => "tools/marc_modification_templates.tt",
            query => $cgi,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => { tools => 'marc_modification_templates' },
            debug => 1,
    });

if ( $op eq "create_template" ) {
  $template_id = '' unless $cgi->param('duplicate_current_template');
  $template_id = AddModificationTemplate( scalar $cgi->param('template_name'), $template_id );

} elsif ( $op eq "delete_template" ) {

  DelModificationTemplate( $template_id );
  $template_id = '';

} elsif ( $op eq "add_action" ) {

  my $mmta_id = $cgi->param('mmta_id');
  my $action = $cgi->param('action');
  my $field_number = $cgi->param('field_number');
  my $from_field = $cgi->param('from_field');
  my $from_subfield = $cgi->param('from_subfield');
  my $field_value = $cgi->param('field_value');
  my $to_field = $cgi->param('to_field');
  my $to_subfield = $cgi->param('to_subfield');
  my $to_regex_search = $cgi->param('to_regex_search');
  my $to_regex_replace = $cgi->param('to_regex_replace');
  my $to_regex_modifiers = $cgi->param('to_regex_modifiers');
  my $conditional = $cgi->param('conditional');
  my $conditional_field = $cgi->param('conditional_field');
  my $conditional_subfield = $cgi->param('conditional_subfield');
  my $conditional_comparison = $cgi->param('conditional_comparison');
  my $conditional_value = $cgi->param('conditional_value');
  my $conditional_regex = ( $cgi->param('conditional_regex') eq 'on' ) ? 1 : 0;
  my $description = $cgi->param('description');

    if ($from_field) {
        unless ($mmta_id) {
            AddModificationTemplateAction(
                $template_id,            $action,
                $field_number,           $from_field,
                $from_subfield,          $field_value,
                $to_field,               $to_subfield,
                $to_regex_search,        $to_regex_replace,
                $to_regex_modifiers,     $conditional,
                $conditional_field,      $conditional_subfield,
                $conditional_comparison, $conditional_value,
                $conditional_regex,      $description
            );
        }
        else {
            ModModificationTemplateAction(
                $mmta_id,                $action,
                $field_number,           $from_field,
                $from_subfield,          $field_value,
                $to_field,               $to_subfield,
                $to_regex_search,        $to_regex_replace,
                $to_regex_modifiers,     $conditional,
                $conditional_field,      $conditional_subfield,
                $conditional_comparison, $conditional_value,
                $conditional_regex,      $description
            );
        }
    }
    else {
        $template->param( error => 'no_from_field' );
    }

} elsif ( $op eq "delete_action" ) {
  DelModificationTemplateAction( scalar $cgi->param('mmta_id') );

} elsif ( $op eq "move_action" ) {

  MoveModificationTemplateAction( scalar $cgi->param('mmta_id'), scalar $cgi->param('where') );

}

my @templates = GetModificationTemplates( $template_id );

my @actions = GetModificationTemplateActions( $template_id );
foreach my $action ( @actions ) {
  $action->{'action_delete_field'} = ( $action->{'action'} eq 'delete_field' );
  $action->{'action_add_field'} = ( $action->{'action'} eq 'add_field' );
  $action->{'action_update_field'} = ( $action->{'action'} eq 'update_field' );
  $action->{'action_move_field'} = ( $action->{'action'} eq 'move_field' );
  $action->{'action_copy_field'} = ( $action->{'action'} eq 'copy_field' );
  $action->{'action_copy_and_replace_field'} = ( $action->{'action'} eq 'copy_and_replace_field' );

  $action->{'conditional_if'} = ( $action->{'conditional'} eq 'if' );
  $action->{'conditional_unless'} = ( $action->{'conditional'} eq 'unless' );

  $action->{'conditional_comparison_exists'} = ( $action->{'conditional_comparison'} eq 'exists' );
  $action->{'conditional_comparison_not_exists'} = ( $action->{'conditional_comparison'} eq 'not_exists' );
  $action->{'conditional_comparison_equals'} = ( $action->{'conditional_comparison'} eq 'equals' );
  $action->{'conditional_comparison_not_equals'} = ( $action->{'conditional_comparison'} eq 'not_equals' );
}

$template->param(
  TemplatesLoop => \@templates,
  ActionsLoop => \@actions,

  template_id => $template_id,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
