#!/usr/bin/perl

# Copyright 2006 Katipo Communications.
# Some parts Copyright 2009 Foundations Bible College.
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

use CGI;
use Sys::Syslog qw(syslog);
use Data::Dumper;

use C4::Debug;
use C4::Labels::Batch 1.000000;
use C4::Labels::Template 1.000000;
use C4::Labels::Layout 1.000000;
use C4::Labels::PDF 1.000000;
use C4::Labels::Label 1.000000;

=head

=cut

my $cgi = new CGI;

my $batch_id    = $cgi->param('batch_id') if $cgi->param('batch_id');
my $template_id = $cgi->param('template_id') || undef;
my $layout_id   = $cgi->param('layout_id') || undef;
my $start_label = $cgi->param('start_label') || 1;
my @label_ids   = $cgi->param('label_id') if $cgi->param('label_id');
my @item_numbers  = $cgi->param('item_number') if $cgi->param('item_number');

my $items = undef;

my $pdf_file = (@label_ids || @item_numbers ? "label_single_" . scalar(@label_ids || @item_numbers) : "label_batch_$batch_id");
print $cgi->header( -type       => 'application/pdf',
                    -encoding   => 'utf-8',
                    -attachment => "$pdf_file.pdf",
                  );

my $pdf = C4::Labels::PDF->new(InitVars => 0);
my $batch = C4::Labels::Batch->retrieve(batch_id => $batch_id);
my $template = C4::Labels::Template->retrieve(template_id => $template_id, profile_id => 1);
my $layout = C4::Labels::Layout->retrieve(layout_id => $layout_id);

sub _calc_next_label_pos {
    my ($row_count, $col_count, $llx, $lly) = @_;
    if ($col_count lt $template->get_attr('cols')) {
        $llx = ($llx + $template->get_attr('label_width') + $template->get_attr('col_gap'));
        $col_count++;
    }
    else {
        $llx = $template->get_attr('left_margin');
        if ($row_count eq $template->get_attr('rows')) {
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
        my $pdf_font = $pdf->Font($text_line->{'font'});
        my $line = "BT /$pdf_font $text_line->{'font_size'} Tf $text_line->{'text_llx'} $text_line->{'text_lly'} Td ($text_line->{'line'}) Tj ET";
        $pdf->Add($line);
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
    my $label = C4::Labels::Label->new(
                                    batch_id            => $batch_id,
                                    item_number         => $item->{'item_number'},
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
    my $label_type = $label->get_label_type;
    if ($label_type eq 'BIB') {
        my $line_spacer = ($label->get_attr('font_size') * 1);    # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).
        my $text_lly = ($lly + ($template->get_attr('label_height') - $template->get_attr('top_text_margin')));
        my $label_text = $label->draw_label_text(
                                        llx             => $llx,
                                        lly             => $text_lly,
                                        line_spacer     => $line_spacer,
                                        );
        _print_text($label_text);
        ($row_count, $col_count, $llx, $lly) = _calc_next_label_pos($row_count, $col_count, $llx, $lly);
        next LABEL_ITEMS;
    }
    elsif ($label_type eq 'BARBIB') {
        $barcode_llx = $llx + $template->get_attr('left_text_margin');                             # this places the bottom left of the barcode the left text margin distance to right of the the left edge of the label ($llx)
        $barcode_lly = ($lly + $template->get_attr('label_height')) - $template->get_attr('top_text_margin');        # this places the bottom left of the barcode the top text margin distance below the top of the label ($lly)
        $barcode_width = 0.8 * $template->get_attr('label_width');                                 # this scales the barcode width to 80% of the label width
        $barcode_y_scale_factor = 0.01 * $template->get_attr('label_height');                      # this scales the barcode height to 10% of the label height
        my $line_spacer = ($label->get_attr('font_size') * 1);    # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).
        my $text_lly = ($lly + ($template->get_attr('label_height') - $template->get_attr('top_text_margin')));
        my $label_text = $label->draw_label_text(
                                        llx             => $llx,
                                        lly             => $text_lly,
                                        line_spacer     => $line_spacer,
                                        );
        _print_text($label_text);
    }
    else {
        $barcode_llx = $llx + $template->get_attr('left_text_margin');             # this places the bottom left of the barcode the left text margin distance to right of the the left edge of the label ($llx)
        $barcode_lly = $lly + $template->get_attr('top_text_margin');              # this places the bottom left of the barcode the top text margin distance above the bottom of the label ($lly)
        $barcode_width = 0.8 * $template->get_attr('label_width');                 # this scales the barcode width to 80% of the label width
        $barcode_y_scale_factor = 0.01 * $template->get_attr('label_height');      # this scales the barcode height to 10% of the label height
        if ($label_type eq 'BIBBAR' || $label_type eq 'ALT') {
            my $line_spacer = ($label->get_attr('font_size') * 1);    # number of pixels between text rows (This is actually leading: baseline to baseline minus font size. Recommended starting point is 20% of font size.).
            my $text_lly = ($lly + ($template->get_attr('label_height') - $template->get_attr('top_text_margin')));
            my $label_text = $label->draw_label_text(
                                            llx             => $llx,
                                            lly             => $text_lly,
                                            line_spacer     => $line_spacer,
                                            );
            _print_text($label_text);
        }
        if ($label_type eq 'ALT') {
        ($row_count, $col_count, $llx, $lly) = _calc_next_label_pos($row_count, $col_count, $llx, $lly);
        }
    }
    $label->barcode(
                llx                 => $barcode_llx,
                lly                 => $barcode_lly,
                width               => $barcode_width,
                y_scale_factor      => $barcode_y_scale_factor,
    );
    ($row_count, $col_count, $llx, $lly) = _calc_next_label_pos($row_count, $col_count, $llx, $lly);
}

$pdf->End();

exit(1);
