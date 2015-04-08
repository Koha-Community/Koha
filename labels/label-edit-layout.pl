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

use CGI;
use POSIX;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Labels;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/label-edit-layout.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op') || '';
my $layout_id = $cgi->param('layout_id') || $cgi->param('element_id') || '';
my $layout_choice = $cgi->param('layout_choice') || '';
our $layout = '';

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

    my @text_fields = grep /\w/, split /\s*,\s/, $format_string;
    my %tf = map {$_ => 1} @text_fields;
    my @missing_fields = grep { !$tf{$_} } @{ C4::Labels::Layout->PRESET_FIELDS };

    my $field_count = scalar(@text_fields) + scalar( @missing_fields);

    my @fields;
    my $field_index = 1;
    foreach my $f (@text_fields) {
        push @fields, {field_name => ($f . "_tbl"), field_label => $f, order => $field_index};
        $field_index++;
    }
    foreach my $f (@missing_fields) {
        push @fields, {field_name => ($f . "_tbl"), field_label => $f};
    }
    return (\@fields, $field_count);
}

if ($op eq 'edit') {
    warn sprintf("Error performing '%s': No 'layout_id' passed in.", $op) unless ($layout_id);
    $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);

}
elsif  ($op eq 'save') {
    my $format_string = '';
    if ($layout_choice eq 'layout_table') {       # translate the field table into a format_string
        my %layout_table;
        foreach my $cgi_param ($cgi->param()) {
            if (($cgi_param =~ m/^(.*)_tbl$/) && ($cgi->param($cgi_param))) {
                my $value = $cgi->param($cgi_param);
                $layout_table{$1} = $value;
            }
        }
        $format_string = join ', ', sort { $layout_table{$a} <=> $layout_table{$b} } keys %layout_table;
        $cgi->param('format_string', $format_string);
    }
    my @params = (
                    barcode_type    => $cgi->param('barcode_type') || 'CODE39',
                    printing_type   => $cgi->param('printing_type') || 'BAR',
                    layout_name     => $cgi->param('layout_name') || 'DEFAULT',
                    guidebox        => ($cgi->param('guidebox') ? 1 : 0),
                    font            => $cgi->param('font') || 'TR',
                    font_size       => $cgi->param('font_size') || 3,
                    callnum_split   => ($cgi->param('callnum_split') ? 1 : 0),
                    text_justify    => $cgi->param('text_justify') || 'L',
                    format_string   => $cgi->param('format_string') || 'title, author, isbn, issn, itemtype, barcode, itemcallnumber',
    );
    if ($layout_id) {   # if a label_id was passed in, this is an update to an existing layout
        $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);
        $layout->set_attr(@params);
        $layout_id = $layout->save();
    }
    else {      # if no label_id, this is a new layout so insert it
        $layout = C4::Labels::Layout->new(@params);
        $layout_id = $layout->save();
    }
    print $cgi->redirect("label-manage.pl?label_element=layout" . ($layout_id == -1 ? "&element_id=$layout_id&op=$op&error=1" : ''));
    exit;
}
else {  # if we get here, this is a new layout
    $layout = C4::Labels::Layout->new();
}

my $barcode_types = _set_selected(get_barcode_types(), $layout, 'barcode_type');
my $label_types = _set_selected(get_label_types(), $layout, 'printing_type');
my $font_types = _set_selected(get_font_types(), $layout, 'font');
my $text_justification_types = _set_selected(get_text_justification_types(), $layout, 'text_justify');
my ($select_text_fields, $select_text_fields_cnt) = _select_format_string($layout->get_attr('format_string'));

$template->param(
        barcode_types   => $barcode_types,
        label_types     => $label_types,
        font_types      => $font_types,
        text_justification_types    => $text_justification_types,
        fields          => $select_text_fields,
        field_count     => $select_text_fields_cnt,
        layout_id       => $layout->get_attr('layout_id') > -1 ? $layout->get_attr('layout_id') : '',
        layout_name     => $layout->get_attr('layout_name'),
        guidebox        => $layout->get_attr('guidebox'),
        font_size       => $layout->get_attr('font_size'),
        callnum_split   => $layout->get_attr('callnum_split'),
        format_string   => $layout->get_attr('format_string'),
        layout_string   => 1,   # FIXME: This should not be hard-coded; It should perhaps be yet another syspref... CN
);
output_html_with_http_headers $cgi, $cookie, $template->output;
