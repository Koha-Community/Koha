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
use Text::CSV_XS;
use XML::Simple;
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Creators;
use C4::Patroncards;

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "patroncards/edit-layout.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

my $op = $cgi->param('op') || 'new'; # make 'new' the default operation if none is submitted
my $layout_id = $cgi->param('layout_id') || $cgi->param('element_id') || '';
my $layout_choice = $cgi->param('layout_choice') || '';
my $layout = '';
my $layout_xml = undef;

my $units = get_unit_values();
my $font_types = get_font_types();
my $alignment_types = get_text_justification_types();
my $barcode_types = get_barcode_types();
my $image_sources = [
    {type => 'none', name => 'None', selected => 1},
    {type => 'patronimages', name => 'Patron Image', selected => 0},
    {type => 'creator_images', name => 'Other Image', selected => 0},
];
my $image_names = get_all_image_names();
unshift @$image_names, {type => 'none', name => 'Select Image', selected => 1};

sub _set_selected {
    my ($selection, $source_list) = @_;
    my @select_list = ();       # we must make a copy of the referent otherwise we modify the original which causes bad things to happen
    my $selected = 0;
    SET_SELECTED:
    foreach my $type (@$source_list) {
        if (($selection) && ($type->{'type'} eq $selection)) {  # even if there is no current selection we must still build the select box
            $selected = 1;
        }
        else {
            $selected = 0;
        }
        push @select_list, {type => $type->{'type'}, name => $type->{'name'}, selected => $selected};
    };
    return \@select_list;
}

if ($op eq 'edit') {
    warn sprintf("Error performing '%s': No 'layout_id' passed in.", $op) unless ($layout_id);
    $layout = C4::Patroncards::Layout->retrieve(layout_id => $layout_id);
    $layout_xml = XMLin($layout->get_attr('layout_xml'), ForceArray => 1);
#       Handle text fields...
    my $field_number = 0;
    my @text_fields = ();
    if ($layout_xml->{'text'}) {
        while (scalar @{$layout_xml->{'text'}}) {
            $field_number++;
            push @text_fields, (
                                "field_" . $field_number => 1,      # indicate field as currently "selected" for display in form
                                "field_" . $field_number . "_text" => shift @{$layout_xml->{'text'}},
                                );
            my $field_params = shift @{$layout_xml->{'text'}};
            push @text_fields, (
                                "field_" . $field_number . "_llx" => $field_params->{'llx'},
                                "field_" . $field_number . "_lly" => $field_params->{'lly'},
                                "field_" . $field_number . "_font" => _set_selected($field_params->{'font'}, $font_types),
                                "field_" . $field_number . "_font_size" => $field_params->{'font_size'},
                                "field_" . $field_number . "_text_alignment" => _set_selected($field_params->{'text_alignment'}, $alignment_types),
                                );
        }
    }

#   Handle fields not currently used
    UNUSED_TEXT_FIELDS:
    for (my $field = $field_number + 1; $field < 4; $field++) {     # limit 3 text fields
        push @text_fields, (
                        "field_$field" . "_font" => get_font_types(),
                        "field_$field" . "_text_alignment" => get_text_justification_types(),
                        );
    }

#   Handle images...
    my $image_count = 0;
    my @images = ();
    foreach my $image (keys %{$layout_xml->{'images'}}) {
        $image_count++;
        push @images, ( $image . "_image" => "$image",
                        $image . "_Dx" => $layout_xml->{'images'}->{$image}->{'Dx'},
                        $image . "_Tx" => $layout_xml->{'images'}->{$image}->{'Tx'},
                        $image . "_Ty" => $layout_xml->{'images'}->{$image}->{'Ty'},
                        $image . "_image_source" => _set_selected($layout_xml->{'images'}->{$image}->{'data_source'}->[0]->{'image_source'}, $image_sources),
                        $image . "_image_name" => _set_selected($layout_xml->{'images'}->{$image}->{'data_source'}->[0]->{'image_name'}, $image_names),
                        );
    }

#   Handle image fields not currently used
    UNUSED_IMAGE_FIELDS:
    for (my $image = $image_count + 1; $image < 3; $image++) {     #limit 2 images
        push @images, (
                        "image_$image" . "_image_source" => $image_sources,
                        "image_$image" . "_image_name" => $image_names,
                        );
    }

#   Handle barcodes...
    my @barcode = ();
    foreach my $barcode_param (keys %{$layout_xml->{'barcode'}->[0]}) {
        push @barcode, (($barcode_param eq 'type' ? ("barcode_" . $barcode_param => _set_selected($layout_xml->{'barcode'}->[0]->{'barcode_type'}, $barcode_types)) : ("barcode_" . $barcode_param => $layout_xml->{'barcode'}->[0]->{$barcode_param})));
    }

    $template->param(
            layout_id       => $layout->get_attr('layout_id') > -1 ? $layout->get_attr('layout_id') : '',
            layout_name     => $layout->get_attr('layout_name'),
            page_side       => ($layout_xml->{'page_side'} eq 'F' ? 0 : 1),
            guide_box       => $layout_xml->{'guide_box'},
            units           => $units,
            @barcode,
            barcode_type    => get_barcode_types(),
            @text_fields,
            @images,
            guidebox        => 0,
    );
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}
elsif  ($op eq 'save') {
    my $format_string = undef;
    my $layout = {};
    my $layout_name = undef;
    my $layout_id = undef;
    my $text_lines = [];
    my $array_index = 0;
    my $image_select = 0;
    my $field_enabled = 0;
    CGI_PARAMS:
    foreach my $parameter ($cgi->param()) {     # parse the field values and build a hash of the layout for conversion to xml and storage in the db
        if ($parameter =~ m/^field_([0-9])_(.*)$/) {
            my $field_number = $1;
            my $field_data = $2;
            $field_enabled = $field_number if $field_data eq 'enable';
            next CGI_PARAMS unless $field_number == $field_enabled;
            if ($field_data eq 'text') {
                push @$text_lines, $cgi->param($parameter);
                if ($array_index <= 0) {
                    $array_index++;
                }
                else {
                    $array_index += 2; # after hitting 1, increment by 2 so counting odds
                }
            }
            elsif ($array_index > 0) {
                $text_lines->[$array_index]->{$field_data} = $cgi->param($parameter);
            }
        }
        elsif ($parameter =~ m/^barcode_(.*)$/) {
            $field_enabled = $1 if $1 eq 'print';
            next CGI_PARAMS unless $field_enabled eq 'print';
            $layout->{'barcode'}->{$1} = $cgi->param($parameter);
        }
        elsif ($parameter =~m/^image_([0-9])_(.*)$/) {
            my $image_number = $1;
            my $image_data = $2;
            $field_enabled = $image_number if $cgi->param("image_$image_number" . "_image_source") ne 'none';
            next CGI_PARAMS unless $image_number == $field_enabled;
            if ($image_data =~ m/^image_(.*)$/) {
                $layout->{'images'}->{"image_$image_number"}->{'data_source'}->{"image_$1"} = $cgi->param($parameter);
            }
            else {
                $layout->{'images'}->{"image_$image_number"}->{$image_data} = $cgi->param($parameter);
            }
        }
        else {
            $layout_name = $cgi->param($parameter) if $parameter eq 'layout_name';
            $layout_id = $cgi->param($parameter) if $parameter eq 'layout_id';
            $layout->{'units'} = $cgi->param($parameter) if $parameter eq 'units';
            $layout->{'page_side'} = $cgi->param($parameter) if $parameter eq 'page_side';
            $layout->{'guide_box'} = $cgi->param($parameter) if $parameter eq 'guide_box';
        }
    }
    $layout->{'text'} = $text_lines;
    my @params = (layout_name => $layout_name, layout_id => $layout_id, layout_xml => XMLout($layout));
    if ($layout_id) {   # if a label_id was passed in, this is an update to an existing layout
        $layout = C4::Patroncards::Layout->retrieve(layout_id => $layout_id);
        $layout->set_attr(@params);
        $layout_id = $layout->save();
    }
    else {      # if no label_id, this is a new layout so insert it
        $layout = C4::Patroncards::Layout->new(@params);
        $layout_id = $layout->save();
    }
    print $cgi->redirect("manage.pl?card_element=layout" . ($layout_id == -1 ? "&element_id=$layout_id&op=$op&error=101" : ''));
    exit;
}
elsif  ($op eq 'new') { # this is a new layout
    $layout = C4::Patroncards::Layout->new();
    my @fields = ();
    for (my $field; $field < 4; $field++) {     # limit 3 text fields
        push @fields, (
                        "field_$field" . "_font" => get_font_types(),
                        "field_$field" . "_text_alignment" => get_text_justification_types(),
                        );
    }

    my @images = ();
    for (my $image; $image < 3; $image++) {     #limit 2 images
        push @images, (
                        "image_$image" . "_image_source" => $image_sources,
                        "image_$image" . "_image_name" => $image_names,
                        );
    }

    $template->param(
                    units               => get_unit_values(),
                    @fields,
                    barcode_type        => get_barcode_types(),
                    @images,
                    );

output_html_with_http_headers $cgi, $cookie, $template->output;
exit;
}
else { # trap unsupported operation here
    warn sprintf("Unsupported operation type submitted: %s", $op);
    print $cgi->redirect("manage.pl?card_element=layout&element_id=$layout_id&error=201");
    exit;
}

__END__
