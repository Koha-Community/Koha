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
use Sys::Syslog qw(syslog);
use CGI;
use HTML::Template::Pro;
use Data::Dumper;
use POSIX;
use Text::CSV_XS;

use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Debug;
use C4::Labels::Lib 1.000000 qw(get_barcode_types get_label_types get_font_types get_text_justification_types);
use C4::Labels::Layout 1.000000;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-layout.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);


my $op = $cgi->param('op') || $ARGV[0] || '';
my $layout_id = $cgi->param('layout_id') || $cgi->param('element_id') || $ARGV[1] || '';
my $layout = '';

sub _set_selected {
    my ($type_list, $object, $data_type) = @_;
    SET_SELECTED:
    foreach my $type (@$type_list) {
        if ($layout->get_attr($data_type)) {
            if ($type->{'type'} eq $layout->get_attr($data_type)) {
                $type->{'selected'} = 1;
            }
        }
        else {
            $type->{'selected'} = 1;
            last SET_SELECTED;
        }
    };
    return $type_list;
}

sub _select_format_string {     # generate field table based on format_string
    my $format_string = shift;
    $format_string =~ s/(?<=,) (?![A-Z][a-z][0-9])//g;  # remove spaces between fields
    my $table = [];
    my $fields = [];
    my ($row_index, $col_index, $field_index) = (0,0,0);
    my $cols = 5;       # number of columns to wrap on
    my $csv = Text::CSV_XS->new({ allow_whitespace => 1 });
    my $status = $csv->parse($format_string);
    my @text_fields = $csv->fields();
    syslog("LOG_ERR", "labels/label-edit-layout.pl : Error parsing format_string. Parser returned: %s",$csv->error_input()) if $csv->error_input();
    my $field_count = $#text_fields + 1;
    POPULATE_TABLE:
    foreach my $text_field (@text_fields) {
        $$fields[$col_index] = {field_empty => 0, field_name => ($text_field . "_tbl"), field_label => $text_field, order => [{num => '', selected => 0}]};
        for (my $order_i = 1; $order_i <= $field_count; $order_i++) {
            $$fields[$col_index]{'order'}[$order_i] = {num => $order_i, selected => ($field_index == $order_i-1 ? 1 : 0)};
        }
        $col_index++;
        $field_index++;
        if ((($col_index > 0) && !($col_index % $cols)) || ($field_index == $field_count)) {    # wrap to new row
            if (($field_index == $field_count) && ($row_index > 0)) { # in this case fill out row with empty fields
                while ($col_index < $cols) {
                    $$fields[$col_index] = {field_empty => 1, field_name => '', field_label => '', order => [{num => '', selected => 0}]};
                    $col_index++;
                }
                $$table[$row_index] = {text_fields => $fields};
                last POPULATE_TABLE;
            }
            $$table[$row_index] = {text_fields => $fields};
            $row_index++;
            $fields = [];
            $col_index = 0;
        }
    }
    return $table;
}

if ($op eq 'edit') {
    syslog("LOG_ERR", "labels/label-edit-layout.pl : Error performing '%s': No 'layout_id' passed in.", $op) unless ($layout);
    $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);

}
elsif  ($op eq 'save') {
    my $format_string = '';
    if ($cgi->param('layout_choice') eq 'layout_table') {       # translate the field table into a format_string
        my @layout_table = ();
        foreach my $cgi_param ($cgi->param()) {
            if (($cgi_param =~ m/^(.*)_tbl$/) && ($cgi->param($cgi_param))) {
                my $value = $cgi->param($cgi_param);
                $layout_table[$value - 1] = $1;
            }
        }
        @layout_table = grep {$_} @layout_table;        # this removes numerically 'skipped' fields. ie. user omits a number in sequential order
        $format_string = join ', ', @layout_table;
        $cgi->param('format_string', $format_string);
    }
    my @params = (
                    barcode_type    => $cgi->param('barcode_type'),
                    printing_type   => $cgi->param('printing_type'),
                    layout_name     => $cgi->param('layout_name'),
                    guidebox        => ($cgi->param('guidebox') ? 1 : 0),
                    font            => $cgi->param('font'),
                    font_size       => $cgi->param('font_size'),
                    callnum_split   => ($cgi->param('callnum_split') ? 1 : 0),
                    text_justify    => $cgi->param('text_justify'),
                    format_string   => $cgi->param('format_string'),
    );
    if ($layout_id) {   # if a label_id was passed in, this is an update to an existing layout
        $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);
        $layout->set_attr(@params);
        $layout->save();
    }
    else {      # if no label_id, this is a new layout so insert it
        $layout = C4::Labels::Layout->new(@params);
        $layout->save();
    }
    print $cgi->redirect("label-manage.pl?label_element=layout");
    exit;
}
else {  # if we get here, this is a new layout
    $layout = C4::Labels::Layout->new();
}

my $barcode_types = _set_selected(get_barcode_types(), $layout, 'barcode_type');
my $label_types = _set_selected(get_label_types(), $layout, 'printing_type');
my $font_types = _set_selected(get_font_types(), $layout, 'font');
my $text_justification_types = _set_selected(get_text_justification_types(), $layout, 'text_justify');
my $select_text_fields = _select_format_string($layout->get_attr('format_string'));

$template->param(
        barcode_types   => $barcode_types,
        label_types     => $label_types,
        font_types      => $font_types,
        text_justification_types    => $text_justification_types,
        field_table     => $select_text_fields,
        layout_id       => $layout->get_attr('layout_id') > -1 ? $layout->get_attr('layout_id') : '',
        layout_name     => $layout->get_attr('layout_name'),
        guidebox        => $layout->get_attr('guidebox'),
        font_size       => $layout->get_attr('font_size'),
        callnum_split   => $layout->get_attr('callnum_split'),
        format_string   => $layout->get_attr('format_string'),
);
output_html_with_http_headers $cgi, $cookie, $template->output;
