package C4::Patroncards::Patroncard;

# Copyright 2009 Foundations Bible College.
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

use autouse 'Data::Dumper' => qw(Dumper);
use Text::Wrap qw(wrap);
#use Font::TTFMetrics;

use C4::Creators::Lib qw(get_font_types);
use C4::Creators::PDF qw(StrWidth);
use C4::Patroncards::Lib qw(unpack_UTF8 text_alignment leading box get_borrower_attributes);

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');
}

sub new {
    my ($invocant, %params) = @_;
    my $type = ref($invocant) || $invocant;
    my $self = {
        batch_id                => $params{'batch_id'},
        #card_number             => $params{'card_number'},
        borrower_number         => $params{'borrower_number'},
        llx                     => $params{'llx'},
        lly                     => $params{'lly'},
        height                  => $params{'height'},
        width                   => $params{'width'},
        layout                  => $params{'layout'},
        text_wrap_cols          => $params{'text_wrap_cols'},
    };
    bless ($self, $type);
    return $self;
}

sub draw_barcode {
    my ($self, $pdf) = @_;
#FIXME: We do some scaling foo on the barcode here which probably should be done by the one invoking draw_barcode
    my $barcode_width = 0.8 * $self->{'width'};                         # this scales the barcode width to 80% of the label width
    my $barcode_y_scale_factor = 0.01 * $self->{'height'};              # this scales the barcode height to 1% of the label height
    _draw_barcode(      $self,
                        llx     => $self->{'llx'} + $self->{'layout'}->{'barcode'}->[0]->{'llx'},
                        lly     => $self->{'lly'} + $self->{'layout'}->{'barcode'}->[0]->{'lly'},
                        width   => $barcode_width,
                        y_scale_factor  => $barcode_y_scale_factor,
                        barcode_type    => $self->{'layout'}->{'barcode'}->[0]->{'type'},
                        barcode_data    => $self->{'layout'}->{'barcode'}->[0]->{'data'},
                        text    => $self->{'layout'}->{'barcode'}->[0]->{'text_print'},
    );
}

sub draw_guide_box {
    my ($self, $pdf) = @_;
    warn sprintf('No pdf object passed in.') and return -1 if !$pdf;
    my $obj_stream = "q\n";                            # save the graphic state
    $obj_stream .= "0.5 w\n";                          # border line width
    $obj_stream .= "1.0 0.0 0.0  RG\n";                # border color red
    $obj_stream .= "1.0 1.0 1.0  rg\n";                # fill color white
    $obj_stream .= "$self->{'llx'} $self->{'lly'} $self->{'width'} $self->{'height'} re\n";    # a rectangle
    $obj_stream .= "B\n";                              # fill (and a little more)
    $obj_stream .= "Q\n";                              # restore the graphic state
    $pdf->Add($obj_stream);
}

sub draw_text {
    my ($self, $pdf, %params) = @_;
    warn sprintf('No pdf object passed in.') and return -1 if !$pdf;
    my @card_text = ();
    return unless (ref($self->{'layout'}->{'text'}) eq 'ARRAY'); # just in case there is not text
    my $text = [@{$self->{'layout'}->{'text'}}]; # make a copy of the arrayref *not* simply a pointer
    while (scalar @$text) {
        my $line = shift @$text;
        my $parse_line = $line;
        my @orig_line = split(/ /,$line);
        if ($parse_line =~ m/<[A-Za-z0-9]+>/) {     # test to see if the line has db fields embedded...
            my @fields = ();
            while ($parse_line =~ m/<([A-Za-z0-9]+)>(.*$)/) {
                push (@fields, $1);
                $parse_line = $2;
            }
            my $borrower_attributes = get_borrower_attributes($self->{'borrower_number'},@fields);
            grep{ # substitute data for db fields
                if ($_ =~ m/<([A-Za-z0-9]+)>/) {
                    my $field = $1;
                    $_ =~ s/$_/$borrower_attributes->{$field}/;
                }
            } @orig_line;
            $line = join(' ',@orig_line);
        }
        my $text_attribs = shift @$text;
        my $origin_llx = $self->{'llx'} + $text_attribs->{'llx'};
        my $origin_lly = $self->{'lly'} + $text_attribs->{'lly'};
        my $Tx = 0;     # final text llx
        my $Ty = $origin_lly;   # final text lly
        my $Tw = 0;     # final text word spacing. See http://www.adobe.com/devnet/pdf/pdf_reference.html ISO 32000-1
#FIXME: Move line wrapping code to its own sub if possible
        my $trim = '';
        my @lines = ();
#FIXME: Using embedded True Type fonts is a far superior way of handing things as well as being much more unicode friendly.
#       However this will take significant work using better than PDF::Reuse to do it. For the time being, I'm leaving
#       the basic code here commented out to preserve the basic method of accomplishing this. -chris_n
#
#        my $m = Font::TTFMetrics->new("/usr/share/fonts/truetype/msttcorefonts/Times_New_Roman_Bold.ttf");
#        my $units_per_em =  $m->get_units_per_em();
#        my $font_units_width = $m->string_width($line);
#        my $string_width = ($font_units_width * $text_attribs->{'font_size'}) / $units_per_em;
        my $string_width = C4::Creators::PDF->StrWidth($line, $text_attribs->{'font'}, $text_attribs->{'font_size'});
        if (($string_width + $text_attribs->{'llx'}) > $self->{'width'}) {
            WRAP_LINES:
            while (1) {
#                $line =~ m/^.*(\s\b.*\b\s*|\s&|\<\b.*\b\>)$/; # original regexp... can be removed after dev stage is over
                $line =~ m/^.*(\s.*\s*|\s&|\<.*\>)$/;
                warn sprintf('Line wrap failed. DEBUG INFO: Data: \'%s\'\n Method: C4::Patroncards->draw_text Additional Information: Line wrap regexp failed. (Please file in this information in a bug report at http://bugs.koha-community.org', $line) and last WRAP_LINES if !$1;
                $trim = $1 . $trim;
                $line =~ s/$1//;
                $string_width = C4::Creators::PDF->StrWidth($line, $text_attribs->{'font'}, $text_attribs->{'font_size'});
#                $font_units_width = $m->string_width($line);
#                $string_width = ($font_units_width * $text_attribs->{'font_size'}) / $units_per_em;
                if (($string_width + $text_attribs->{'llx'}) < $self->{'width'}) {
                    ($Tx, $Tw) = text_alignment($origin_llx, $self->{'width'}, $text_attribs->{'llx'}, $string_width, $line, $text_attribs->{'text_alignment'});
                    push @lines, {line=> $line, Tx => $Tx, Ty => $Ty, Tw => $Tw};
                    $line = undef;
                    last WRAP_LINES if $trim eq '';
                    $Ty -= leading($text_attribs->{'font_size'});
                    $line = $trim;
                    $trim = '';
                    $string_width = C4::Creators::PDF->StrWidth($line, $text_attribs->{'font'}, $text_attribs->{'font_size'});
                    #$font_units_width = $m->string_width($line);
                    #$string_width = ($font_units_width * $text_attribs->{'font_size'}) / $units_per_em;
                    if (($string_width + $text_attribs->{'llx'}) < $self->{'width'}) {
                        ($Tx, $Tw) = text_alignment($origin_llx, $self->{'width'}, $text_attribs->{'llx'}, $string_width, $line, $text_attribs->{'text_alignment'});
                        $line =~ s/^\s+//g;     # strip naughty leading spaces
                        push @lines, {line=> $line, Tx => $Tx, Ty => $Ty, Tw => $Tw};
                        last WRAP_LINES;
                    }
                }
            }
        }
        else {
            ($Tx, $Tw) = text_alignment($origin_llx, $self->{'width'}, $text_attribs->{'llx'}, $string_width, $line, $text_attribs->{'text_alignment'});
            $line =~ s/^\s+//g;     # strip naughty leading spaces
            push @lines, {line=> $line, Tx => $Tx, Ty => $Ty, Tw => $Tw};
        }
# Draw boxes around text box areas
# FIXME: This needs to compensate for the point height of decenders. In its current form it is helpful but not really usable. The boxes are also not transparent atm.
#        If these things were fixed, it may be desirable to give the user control over whether or not to display these boxes for layout design.
        if (0) {
            my $box_height = 0;
            my $box_lly = $origin_lly;
            if (scalar(@lines) > 1) {
                $box_height += scalar(@lines) * ($text_attribs->{'font_size'} * 1.2);
                $box_lly -= ($text_attribs->{'font_size'} * 0.2);
            }
            else {
                $box_height += $text_attribs->{'font_size'};
            }
            box ($origin_llx, $box_lly, $self->{'width'} - $text_attribs->{'llx'}, $box_height, $pdf);
        }
        $pdf->Font($text_attribs->{'font'});
        $pdf->FontSize($text_attribs->{'font_size'});
        foreach my $line (@lines) {
            $pdf->Text($line->{'Tx'}, $line->{'Ty'}, $line->{'line'});
        }
    }
}

sub draw_image {
    my ($self, $pdf) = @_;
    warn sprintf('No pdf object passed in.') and return -1 if !$pdf;
    my $images = $self->{'layout'}->{'images'};
    PROCESS_IMAGES:
    foreach my $image (keys %$images) {
        next PROCESS_IMAGES if $images->{$image}->{'data_source'}->[0]->{'image_source'} eq 'none';
        my $Tx = $self->{'llx'} + $images->{$image}->{'Tx'};
        my $Ty = $self->{'lly'} + $images->{$image}->{'Ty'};
        warn sprintf('No image passed in.') and next if !$images->{$image}->{'data'};
        my $intName = $pdf->AltJpeg($images->{$image}->{'data'},$images->{$image}->{'Sx'}, $images->{$image}->{'Sy'}, 1, $images->{$image}->{'alt'}->{'data'},$images->{$image}->{'alt'}->{'Sx'}, $images->{$image}->{'alt'}->{'Sy'}, 1);
        my $obj_stream = "q\n";
        $obj_stream .= "$images->{$image}->{'Sx'} $images->{$image}->{'Ox'} $images->{$image}->{'Oy'} $images->{$image}->{'Sy'} $Tx $Ty cm\n";       # see http://www.adobe.com/devnet/pdf/pdf_reference.html sec 8.3.3 of ISO 32000-1
        $obj_stream .= "/$intName Do\n";
        $obj_stream .= "Q\n";
        $pdf->Add($obj_stream);
    }
}

sub _draw_barcode {   # this is cut-and-paste from Label.pm because there is no common place for it atm...
    my $self = shift;
    my %params = @_;
    my $x_scale_factor = 1;
    my $num_of_chars = length($params{'barcode_data'});
    my $tot_bar_length = 0;
    my $bar_length = 0;
    my $guard_length = 10;
    if ($params{'barcode_type'} =~ m/CODE39/) {
        $bar_length = '17.5';
        $tot_bar_length = ($bar_length * $num_of_chars) + ($guard_length * 2);  # not sure what all is going on here and on the next line; this is old (very) code
        $x_scale_factor = ($params{'width'} / $tot_bar_length);
        if ($params{'barcode_type'} eq 'CODE39MOD') {
            my $c39 = CheckDigits('code_39');   # get modulo 43 checksum
            $params{'barcode_data'} = $c39->complete($params{'barcode_data'});
        }
        elsif ($params{'barcode_type'} eq 'CODE39MOD10') {
            my $c39_10 = CheckDigits('siret');   # get modulo 10 checksum
            $params{'barcode_data'} = $c39_10->complete($params{'barcode_data'});
        }
        eval {
            PDF::Reuse::Barcode::Code39(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode_data}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                hide_asterisk       => 1,
                text                => $params{'text'},
                mode                => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
        }
    }
    elsif ($params{'barcode_type'} eq 'COOP2OF5') {
        $bar_length = '9.43333333333333';
        $tot_bar_length = ($bar_length * $num_of_chars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length) * 0.9;
        eval {
            PDF::Reuse::Barcode::COOP2of5(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode_data}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
        }
    }
    elsif ( $params{'barcode_type'} eq 'INDUSTRIAL2OF5' ) {
        $bar_length = '13.1333333333333';
        $tot_bar_length = ($bar_length * $num_of_chars) + ($guard_length * 2);
        $x_scale_factor = ($params{'width'} / $tot_bar_length) * 0.9;
        eval {
            PDF::Reuse::Barcode::Industrial2of5(
                x                   => $params{'llx'},
                y                   => $params{'lly'},
                value               => "*$params{barcode_data}*",
                xSize               => $x_scale_factor,
                ySize               => $params{'y_scale_factor'},
                mode                    => 'graphic',
            );
        };
        if ($@) {
            warn sprintf('Barcode generation failed for item %s with this error: %s', $self->{'item_number'}, $@);
        }
    }
}

1;
__END__

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut



