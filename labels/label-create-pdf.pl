#!/usr/bin/perl

# Copyright Chris Nighswonger 2009
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
use C4::Auth;
use C4::Debug;
use C4::Creators;
use C4::Labels;

my $cgi = new CGI;

my ( undef, $loggedinuser, $cookie ) = get_template_and_user({
								     template_name   => "labels/label-home.tt",
								     query           => $cgi,
								     type            => "intranet",
								     authnotrequired => 0,
								     flagsrequired   => { tools => 'label_creator' },
								     debug           => 1,
								     });

my $batch_id;
my @label_ids;
my @item_numbers;
$batch_id    = $cgi->param('batch_id') if $cgi->param('batch_id');
my $template_id = $cgi->param('template_id') || undef;
my $layout_id   = $cgi->param('layout_id') || undef;
my $start_label = $cgi->param('start_label') || 1;
@label_ids   = $cgi->param('label_id') if $cgi->param('label_id');
@item_numbers  = $cgi->param('item_number') if $cgi->param('item_number');

my $items = undef;



my $pdf_file = (@label_ids || @item_numbers ? "label_single_" . scalar(@label_ids || @item_numbers) : "label_batch_$batch_id");
print $cgi->header( -type       => 'application/pdf',
                    -encoding   => 'utf-8',
                    -attachment => "$pdf_file.pdf",
                  );

our $pdf = C4::Creators::PDF->new(InitVars => 0);
my $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
our $template = C4::Labels::Template->retrieve(template_id => $template_id, profile_id => 1);
my $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);

sub _calc_next_label_pos {
    my ($row_count, $col_count, $llx, $lly) = @_;
    if ($col_count < $template->get_attr('cols')) {
        $llx = ($llx + $template->get_attr('label_width') + $template->get_attr('col_gap'));
        $col_count++;
    }
    else {
        $llx = $template->get_attr('left_margin');
        if ($row_count == $template->get_attr('rows')) {
            $pdf->Page();
            $lly = ($template->get_attr('page_height') - $template->get_attr('top_margin') - $template->get_attr('label_height'));
            $row_count = 1;
        }
        else {
            $lly = ($lly - $template->get_attr('row_gap') - $template->get_attr('label_height'));
            $row_count++;
        }
        $col_count = 1;
    }
    return ($row_count, $col_count, $llx, $lly);
}

sub _print_text {
    my $label_text = shift;
    foreach my $text_line (@$label_text) {
        $pdf->Font($text_line->{'font'});
        $pdf->FontSize( $text_line->{'font_size'} );
        $pdf->Text( $text_line->{'text_llx'}, $text_line->{'text_lly'}, $text_line->{'line'} );
    }
}

$| = 1;

# set the paper size
my $lowerLeftX  = 0;
my $lowerLeftY  = 0;
my $upperRightX = $template->get_attr('page_width');
my $upperRightY = $template->get_attr('page_height');

$pdf->Compress(1);
$pdf->Mbox($lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY);

my ($row_count, $col_count, $llx, $lly) = $template->get_label_position($start_label);

if (@label_ids) {
    my $batch_items = $batch->get_attr('items');
    grep {
        my $label_id = $_;
        push(@{$items}, grep{$_->{'label_id'} == $label_id;} @{$batch_items});
    } @label_ids;
}
elsif (@item_numbers) {
    grep {
        push(@{$items}, {item_number => $_});
    } @item_numbers;
}
else {
    $items = $batch->get_attr('items');
}

LABEL_ITEMS:
foreach my $item (@{$items}) {
    my ($barcode_llx, $barcode_lly, $barcode_width, $barcode_y_scale_factor) = 0,0,0,0;
    if ($layout->get_attr('printing_type') eq 'ALT') {  # we process the ALT style printing type here because it is not an atomic printing type
        my $label_a = C4::Labels::Label->new(
                                        batch_id            => $batch_id,
                                        item_number         => $item->{'item_number'},
                                        llx                 => $llx,
                                        lly                 => $lly,
                                        width               => $template->get_attr('label_width'),
                                        height              => $template->get_attr('label_height'),
                                        top_text_margin     => $template->get_attr('top_text_margin'),
                                        left_text_margin    => $template->get_attr('left_text_margin'),
                                        barcode_type        => $layout->get_attr('barcode_type'),
                                        printing_type       => 'BIB',
                                        guidebox            => $layout->get_attr('guidebox'),
                                        font                => $layout->get_attr('font'),
                                        font_size           => $layout->get_attr('font_size'),
                                        callnum_split       => $layout->get_attr('callnum_split'),
                                        justify             => $layout->get_attr('text_justify'),
                                        format_string       => $layout->get_attr('format_string'),
                                        text_wrap_cols      => $layout->get_text_wrap_cols(label_width => $template->get_attr('label_width'), left_text_margin => $template->get_attr('left_text_margin')),
                                          );
        $pdf->Add($label_a->draw_guide_box) if $layout->get_attr('guidebox');
        my $label_a_text = $label_a->create_label();
        _print_text($label_a_text);
        ($row_count, $col_count, $llx, $lly) = _calc_next_label_pos($row_count, $col_count, $llx, $lly);
        my $label_b = C4::Labels::Label->new(
                                        batch_id            => $batch_id,
                                        item_number         => $item->{'item_number'},
                                        llx                 => $llx,
                                        lly                 => $lly,
                                        width               => $template->get_attr('label_width'),
                                        height              => $template->get_attr('label_height'),
                                        top_text_margin     => $template->get_attr('top_text_margin'),
                                        left_text_margin    => $template->get_attr('left_text_margin'),
                                        barcode_type        => $layout->get_attr('barcode_type'),
                                        printing_type       => 'BAR',
                                        guidebox            => $layout->get_attr('guidebox'),
                                        font                => $layout->get_attr('font'),
                                        font_size           => $layout->get_attr('font_size'),
                                        callnum_split       => $layout->get_attr('callnum_split'),
                                        justify             => $layout->get_attr('text_justify'),
                                        format_string       => $layout->get_attr('format_string'),
                                        text_wrap_cols      => $layout->get_text_wrap_cols(label_width => $template->get_attr('label_width'), left_text_margin => $template->get_attr('left_text_margin')),
                                          );
        $pdf->Add($label_b->draw_guide_box) if $layout->get_attr('guidebox');
        my $label_b_text = $label_b->create_label();
        ($row_count, $col_count, $llx, $lly) = _calc_next_label_pos($row_count, $col_count, $llx, $lly);
        next LABEL_ITEMS;
    }
    else {
    }
        my $label = C4::Labels::Label->new(
                                        batch_id            => $batch_id,
                                        item_number         => $item->{'item_number'},
                                        llx                 => $llx,
                                        lly                 => $lly,
                                        width               => $template->get_attr('label_width'),
                                        height              => $template->get_attr('label_height'),
                                        top_text_margin     => $template->get_attr('top_text_margin'),
                                        left_text_margin    => $template->get_attr('left_text_margin'),
                                        barcode_type        => $layout->get_attr('barcode_type'),
                                        printing_type       => $layout->get_attr('printing_type'),
                                        guidebox            => $layout->get_attr('guidebox'),
                                        font                => $layout->get_attr('font'),
                                        font_size           => $layout->get_attr('font_size'),
                                        callnum_split       => $layout->get_attr('callnum_split'),
                                        justify             => $layout->get_attr('text_justify'),
                                        format_string       => $layout->get_attr('format_string'),
                                        text_wrap_cols      => $layout->get_text_wrap_cols(label_width => $template->get_attr('label_width'), left_text_margin => $template->get_attr('left_text_margin')),
                                          );
        $pdf->Add($label->draw_guide_box) if $layout->get_attr('guidebox');
        my $label_text = $label->create_label();
        _print_text($label_text) if $label_text;
        ($row_count, $col_count, $llx, $lly) = _calc_next_label_pos($row_count, $col_count, $llx, $lly);
        next LABEL_ITEMS;
}

$pdf->End();

__END__

=head1 NAME

labels/label-create-pdf.pl - A script for creating a pdf export of labels and label batches in Koha

=head1 ABSTRACT

This script provides the means of producing a pdf of labels for items either individually, in groups, or in batches from within Koha.

=head1 USAGE

This script is intended to be called as a cgi script although it could be easily modified to accept command line parameters. The script accepts four single
parameters and two "multiple" parameters as follows:

    C<batch_id>         A single valid batch id to export.
    C<template_id>      A single valid template id to be applied to the current export. This parameter is manditory.
    C<layout_id>        A single valid layout id to be applied to the current export. This parameter is manditory.
    C<start_label>      The number of the label on which to begin the export. This parameter is optional.
    C<lable_ids>        A single valid label id to export. Multiple label ids may be submitted to export multiple labels.
    C<item_numbers>     A single valid item number to export. Multiple item numbers may be submitted to export multiple items.

B<NOTE:> One of the C<batch_id>, C<label_ids>, or C<item_number> parameters is manditory. However, do not pass a combination of them or bad things might result.

    example:
        http://staff-client.kohadev.org/cgi-bin/koha/labels/label-create-pdf.pl?batch_id=1&template_id=1&layout_id=5&start_label=1

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along with Koha; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
Fifth Floor, Boston, MA 02110-1301 USA.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
