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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth                      qw( get_template_and_user );
use C4::Output                    qw( output_html_with_http_headers );
use C4::MarcModificationTemplates qw(
    AddModificationTemplate
    AddModificationTemplateAction
    DelModificationTemplate
    DelModificationTemplateAction
    ExportModificationTemplates
    GetModificationTemplateActions
    GetModificationTemplates
    ImportModificationTemplates
    ModModificationTemplateAction
    MoveModificationTemplateAction
);

my $cgi = CGI->new;

my $op          = $cgi->param('op') || q{};
my $template_id = $cgi->param('template_id');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/marc_modification_templates.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { tools => 'marc_modification_templates' },
    }
);

if ( $op eq "cud-create_template" ) {
    $template_id = '' unless $cgi->param('duplicate_current_template');
    $template_id = AddModificationTemplate( scalar $cgi->param('template_name'), $template_id );
    print $cgi->redirect(
        "/cgi-bin/koha/tools/marc_modification_templates.pl?template_id=$template_id&op=select_template");
} elsif ( $op eq "cud-delete_template" ) {

    DelModificationTemplate($template_id);
    $template_id = '';

} elsif ( $op eq "cud-add_action" ) {

    my $mmta_id                = $cgi->param('mmta_id');
    my $action                 = $cgi->param('action');
    my $field_number           = $cgi->param('field_number');
    my $use_indicators         = $cgi->param('use_indicators') ? 1 : 0;
    my $from_field             = $cgi->param('from_field');
    my $from_subfield          = $cgi->param('from_subfield');
    my $from_ind1              = $cgi->param('from_ind1');
    my $from_ind2              = $cgi->param('from_ind2');
    my $field_value            = $cgi->param('field_value');
    my $to_field               = $cgi->param('to_field');
    my $to_subfield            = $cgi->param('to_subfield');
    my $to_ind1                = $cgi->param('to_ind1');
    my $to_ind2                = $cgi->param('to_ind2');
    my $to_regex_search        = $cgi->param('to_regex_search');
    my $to_regex_replace       = $cgi->param('to_regex_replace');
    my $to_regex_modifiers     = $cgi->param('to_regex_modifiers');
    my $conditional            = $cgi->param('conditional');
    my $conditional_field      = $cgi->param('conditional_field');
    my $conditional_subfield   = $cgi->param('conditional_subfield');
    my $conditional_ind1       = $cgi->param('conditional_ind1');
    my $conditional_ind2       = $cgi->param('conditional_ind2');
    my $conditional_comparison = $cgi->param('conditional_comparison');
    my $conditional_value      = $cgi->param('conditional_value');
    my $conditional_regex      = ( $cgi->param('conditional_regex') eq 'on' ) ? 1 : 0;
    my $description            = $cgi->param('description');

    if ($from_field) {
        unless ($mmta_id) {
            AddModificationTemplateAction(
                $template_id,
                $action,
                $field_number,
                $use_indicators,
                $from_field,
                $from_subfield,
                $from_ind1,
                $from_ind2,
                $field_value,
                $to_field,
                $to_subfield,
                $to_ind1,
                $to_ind2,
                $to_regex_search,
                $to_regex_replace,
                $to_regex_modifiers,
                $conditional,
                $conditional_field,
                $conditional_subfield,
                $conditional_ind1,
                $conditional_ind2,
                $conditional_comparison,
                $conditional_value,
                $conditional_regex,
                $description
            );
        } else {
            ModModificationTemplateAction(
                $mmta_id,
                $action,
                $field_number,
                $use_indicators,
                $from_field,
                $from_subfield,
                $from_ind1,
                $from_ind2,
                $field_value,
                $to_field,
                $to_subfield,
                $to_ind1,
                $to_ind2,
                $to_regex_search,
                $to_regex_replace,
                $to_regex_modifiers,
                $conditional,
                $conditional_field,
                $conditional_subfield,
                $conditional_ind1,
                $conditional_ind2,
                $conditional_comparison,
                $conditional_value,
                $conditional_regex,
                $description
            );
        }
    } else {
        $template->param( error => 'no_from_field' );
    }

} elsif ( $op eq "cud-delete_action" ) {
    DelModificationTemplateAction( scalar $cgi->param('mmta_id') );

} elsif ( $op eq "move_action" ) {

    MoveModificationTemplateAction( scalar $cgi->param('mmta_id'), scalar $cgi->param('where') );

} elsif ( $op eq "export" ) {

    my @template_ids;
    if ( $cgi->param('export_all') ) {

        # Export all templates
        my @templates = GetModificationTemplates();
        @template_ids = map { $_->{template_id} } @templates;
    } else {

        # Export selected templates
        @template_ids = $cgi->multi_param('template_ids');
    }

    my $json = ExportModificationTemplates( \@template_ids );

    print $cgi->header(
        -type       => 'application/json',
        -attachment => 'marc_modification_templates.json',
        -charset    => 'utf-8',
    );
    print $json;

    exit;

} elsif ( $op eq "cud-import" ) {

    my $upload = $cgi->upload('import_file');
    if ($upload) {
        my $json;
        {
            local $/;
            while ( my $line = <$upload> ) {
                $json .= $line;
            }
        }

        my $skip_existing = $cgi->param('skip_existing') ? 1 : 0;

        my $result = ImportModificationTemplates( $json, $skip_existing );

        $template->param(
            import_success    => $result->{success},
            import_skipped    => $result->{skipped},
            import_overwrote  => $result->{overwrote},
            import_errors     => $result->{errors},
            show_import_modal => 1,
        );
    } else {
        $template->param(
            import_error      => 'no_file_uploaded',
            show_import_modal => 1,
        );
    }

}

my @templates = GetModificationTemplates($template_id);

my @actions = GetModificationTemplateActions($template_id);
foreach my $action (@actions) {
    $action->{'action_delete_field'}           = ( $action->{'action'} eq 'delete_field' );
    $action->{'action_add_field'}              = ( $action->{'action'} eq 'add_field' );
    $action->{'action_update_field'}           = ( $action->{'action'} eq 'update_field' );
    $action->{'action_move_field'}             = ( $action->{'action'} eq 'move_field' );
    $action->{'action_copy_field'}             = ( $action->{'action'} eq 'copy_field' );
    $action->{'action_copy_and_replace_field'} = ( $action->{'action'} eq 'copy_and_replace_field' );

    if ( defined $action->{'conditional'} ) {
        $action->{'conditional_if'}     = ( $action->{'conditional'} eq 'if' );
        $action->{'conditional_unless'} = ( $action->{'conditional'} eq 'unless' );
    }

    if ( defined $action->{'conditional_comparison'} ) {
        $action->{'conditional_comparison_exists'}     = ( $action->{'conditional_comparison'} eq 'exists' );
        $action->{'conditional_comparison_not_exists'} = ( $action->{'conditional_comparison'} eq 'not_exists' );
        $action->{'conditional_comparison_equals'}     = ( $action->{'conditional_comparison'} eq 'equals' );
        $action->{'conditional_comparison_not_equals'} = ( $action->{'conditional_comparison'} eq 'not_equals' );
    }
}

$template->param(
    TemplatesLoop => \@templates,
    ActionsLoop   => \@actions,

    template_id => $template_id,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
