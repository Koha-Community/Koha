package C4::Labels::DataSourceFormatter;
# Copyright 2015 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use DateTime;
use Class::Inspector;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use List::Util;

use C4::Context;

use Koha::Exception::UnknownObject;
use Koha::Exception::BadParameter;

use Koha::Logger;
our $logger = Koha::Logger->get();

=head SYNOPSIS

Define subroutines that format and print text.
All subroutines here starting with public_*
are exposed to the user as selectable Data Formatters.
This is to avoid namespace polluting modules like PDF::Reuse from exposing unintended formatters to the user.

All subroutines get the following parameters for the given item:
@PARAM1 HASHRef of source data parameters,
            {   text => "CPL", #String, text to print

            }
@PARAM2 C4::Labels::Sheet::Element, the Element-object containing all the formatting parameters

Define the subroutine documentation in intranet-tmpl/prog/en/includes/labels/data-source-formatter-documentation.inc

PDF::Reuse has already been initialized, so it is safe to start calling PDF::Reuse subroutines here.

=cut

my $barcodeHeight = 38; #When y-axis scaling is 0.75

sub public_barcode39 {
    my ($data, $element) = @_;
    my $text = $data->{text};
    my $pos = $element->getPdfPosition();
    my $fontSize = $element->getFontSize();
    my $customAttr = $element->getCustomAttr();

    my $showText = (defined $customAttr->{showtext}) ? $customAttr->{showtext} : 1; #Show the barcode values as text underneath it? (1 || 0)
    my $yScaling = (defined $customAttr->{'y-scale'}) ? $customAttr->{'y-scale'} : 1.0;
    my $xScaling = (defined $customAttr->{'x-scale'}) ? $customAttr->{'x-scale'} : 1.0;

    #Validate $text is of proper format
    $text = uc($text);
    if ($text =~/[^A-Z0-9-.$\/+% ]/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."():> Given text '$text' has unallowed characters. Only these characters are allowed: A-Z, 0-9, -, ., $, /, +, % and space");
    }

    my %pos = (
        x             => $pos->{x},
        y             => $pos->{y} - ($barcodeHeight*$yScaling),
        ySize         => $yScaling,
        xSize         => $xScaling,
    );
    $logger->debug(  "Barcode39 ".$logger->flatten(\%pos)  ) if $logger->is_debug;
    PDF::Reuse::Barcode::Code39 (%pos,
                                 value         => '*'.$text.'*',
                                 text          => $showText,
                                 hide_asterisk => 1,);
}

sub public_barcode128 {
    my ($data, $element) = @_;
    my $text = $data->{text};
    my $pos = $element->getPdfPosition();
    my $fontSize = $element->getFontSize();
    my $customAttr = $element->getCustomAttr();

    my $showText = (defined $customAttr->{showtext}) ? $customAttr->{showtext} : 1; #Show the barcode values as text underneath it? (1 || 0)
    my $yScaling = (defined $customAttr->{'y-scale'}) ? $customAttr->{'y-scale'} : 1.0;
    my $xScaling = (defined $customAttr->{'x-scale'}) ? $customAttr->{'x-scale'} : 1.0;

    #Validate $text is of proper format
    $text = uc($text);
    if ($text =~/[^A-Z0-9-.$\/+% ]/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."():> Given text '$text' has unallowed characters. Only these characters are allowed: A-Z, 0-9, -, ., $, /, +, % and space");
    }

    my %pos = (
        x             => $pos->{x},
        y             => $pos->{y} - ($barcodeHeight*$yScaling),
        ySize         => $yScaling,
        xSize         => $xScaling,
    );
    $logger->debug(  "Barcode128 ".$logger->flatten(\%pos)  ) if $logger->is_debug;
    PDF::Reuse::Barcode::Code128 (%pos,
                                  value         => $text,
                                  text          => $showText,);
}

sub public_barcodeEAN13 {
    my ($data, $element) = @_;
    my $text = $data->{text};
    my $pos = $element->getPdfPosition();
    my $fontSize = $element->getFontSize();
    my $customAttr = $element->getCustomAttr();

    my $showText = (defined $customAttr->{showtext}) ? $customAttr->{showtext} : 1; #Show the barcode values as text underneath it? (1 || 0)
    my $yScaling = (defined $customAttr->{'y-scale'}) ? $customAttr->{'y-scale'} : 1.0;
    my $xScaling = (defined $customAttr->{'x-scale'}) ? $customAttr->{'x-scale'} : 1.0;

    #Validate $text is of proper format
    $text = uc($text);
    if ($text =~/[^0-9]/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."():> Given text '$text' has unallowed characters. Only these characters are allowed: 0-9");
    }
    if (length($text) != 13) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."():> Given text '$text' must be 13 characters long.");
    }

    my %pos = (
        x             => $pos->{x},
        y             => $pos->{y} - ($barcodeHeight*$yScaling),
        ySize         => $yScaling,
        xSize         => $xScaling,
    );
    $logger->debug(  "EAN13 ".$logger->flatten(\%pos)  ) if $logger->is_debug;
    PDF::Reuse::Barcode::EAN13  (%pos,
                                 value         => $text,
                                 text          => $showText,);
}

sub public_barcodeEAN13checksum {
    my ($data, $element) = @_;
    my $text = $data->{text};
    my $pos = $element->getPdfPosition();
    my $fontSize = $element->getFontSize();
    my $customAttr = $element->getCustomAttr();

    my $showText = (defined $customAttr->{showtext}) ? $customAttr->{showtext} : 1; #Show the barcode values as text underneath it? (1 || 0)
    my $yScaling = (defined $customAttr->{'y-scale'}) ? $customAttr->{'y-scale'} : 1.0;
    my $xScaling = (defined $customAttr->{'x-scale'}) ? $customAttr->{'x-scale'} : 1.0;

    #Validate $text is of proper format
    $text = uc($text);
    if ($text =~/[^0-9]/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."():> Given text '$text' has unallowed characters. Only these characters are allowed: 0-9");
    }
    if (length($text) != 12) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."():> Given text '$text' must be 12 characters long.");
    }

    my %pos = (
        x             => $pos->{x},
        y             => $pos->{y} - ($barcodeHeight*$yScaling),
        ySize         => $yScaling,
        xSize         => $xScaling,
    );
    $logger->debug(  "EAN13checksum ".$logger->flatten(\%pos)  ) if $logger->is_debug;
    PDF::Reuse::Barcode::EAN13  (%pos,
                                 value         => $text,
                                 text          => $showText,);
}

sub public_oneLiner {
    my ($data, $element) = @_;

    _printLines(_formatLines($element, $data->{text}, 'oneLiner'));
}
sub public_oneLinerShrinkText {
    my ($data, $element) = @_;

    _printLines(_formatLines($element, $data->{text}, 'oneLinerShrink'));
}
sub public_twoLiner {
    my ($data, $element) = @_;

    _printLines(_formatLines($element, $data->{text}, 'twoLiner'));
}
sub public_twoLinerShrink {
    my ($data, $element) = @_;

    _printLines(_formatLines($element, $data->{text}, 'twoLinerShrink'));
}

sub _formatLines {
    #Set parameters and default values
    my ($element, $text, $mutator) = @_;
    my $width = $element->getPdfDimensions()->{width};
    my $pos = $element->getPdfPosition();
    my $fontSize = $element->getFontSize();
    prFontSize($fontSize);
    _getTTFont($element->getFont());
    my @lines;

    #Make the initial measurement should we cut the given text
    my ($cuttingPos, $line) = _fitText($width, $fontSize, $text);
    if ($cuttingPos) {

        if ($mutator eq 'oneLinerShrink') { #Shrink the font
            my $i = 0; #Iteration counter to prevent an endless loop
            while($cuttingPos && $i++ < 10) {
                ($fontSize, undef) = prFontSize( $fontSize-1 ); #Shrink the font to take less space
                ($cuttingPos, $line) = _fitText($width, $fontSize, $text);
            }
            push(@lines, $line);
        }
        elsif ($mutator eq 'twoLiner') {
            ($cuttingPos, $line) = _fitText($width, $fontSize, $text);
            push(@lines, $line);
            if ($cuttingPos) { #When the text is measured again in smaller font we might not have to cut it at all!
                $line = _fitText(  $width, $fontSize, substr($text, $cuttingPos)  ); #Cut the second row text from the first row text
                push(@lines, $line);
            }
        }
        elsif ($mutator eq 'twoLinerShrink') {
            ##First find a font size which fits multiple rows best
            my $i = 0; #Iteration counter to prevent an endless loop
            my $minFontSize = $fontSize*0.7; #Shrink a maximum of 30%
            my $maxShrinkIterations = $fontSize - $minFontSize;
            ($cuttingPos, $line) = _fitText(($width*2-$fontSize/2), $fontSize, $text); #Measure if we can fit this into two rows
            while($cuttingPos && $i++ < $maxShrinkIterations) {
                ($fontSize, undef) = prFontSize( $fontSize-1 ); #Shrink the font to take less space
                ($cuttingPos, $line) = _fitText(($width*2-$fontSize/2), $fontSize, $text);
            }

            ##Push first row
            ($cuttingPos, $line) = _fitText($width, $fontSize, $text);
            push(@lines, $line);
            if ($cuttingPos) { ##Push second row
                $line = _fitText(  $width, $fontSize, substr($text, $cuttingPos)  ); #Cut the second row text from the first row text
                push(@lines, $line);
            }
        }
        elsif ($mutator eq 'oneLiner') {
            push(@lines, $line);
        }

        return ($pos, \@lines, $fontSize, $element->getFont(), $element->getColour());
    }
    else {
        return ($pos, [$text], $fontSize, $element->getFont(), $element->getColour());
    }
}

=head _printLines

    _printLines($pos, $lines, $fontSize, $font, $colour);

Simply prints the given lines, starting from a new line, using the given parameters.

@PARAM1 HASHRef of Integers, position on the pdf-sheet, {x => 55, y => 123}
@PARAM2 ARRAYRef of Strings
@PARAM3 Integer
@PARAM4 String, available types shown in C4::Context->config('ttf');
@PARAM5 HASHRef of Integers, {r => 12, g => 45, b => 256}

=cut

sub _printLines {
    my ($pos, $lines, $fontSize, $font, $colour) = @_;

    PDF::Reuse::prFontSize($fontSize);
    _getTTFont($font);
    my $lineSeparation = 0;

    for (my $i=0 ; $i<scalar(@$lines) ; $i++) {
        my $line = $lines->[$i];
        my $posTop = $pos->{y} - ($fontSize*($i+1)) - (($i != 0) ? $lineSeparation*$i : 0);
        my @pos = ($pos->{x}, $posTop);
        $logger->debug(  "_printLine ".$logger->flatten(\@pos)  ) if $logger->is_debug;
        PDF::Reuse::prText(@pos, $line);
    }
}

=head _fitText()
my ($shorteningPosition, $shortenedText) = _fitText($availableWidth, $fontSize, $text);

Shortens the given $text to fit the given $availableWidth.
Returns the $shortenedText and the length of the new text so we know the point of cutting.
$shorteningPosition is undef if no cutting happened.

=cut
sub _fitText {
    my ($availableWidth, $fontSize, $text) = @_;

    #Remove leading whitespace
    $text =~ s/^\s+//;
    my $tooLong; #A boolean (flag) if we had to shorten the text

    #my $textWidth = sprintf(  '%1$d', prStrWidth( $text, 'Helvetica', $fontSize )  );
    my $textWidth = sprintf(  '%1$d', prStrWidth( $text, undef, $fontSize )  );
    $availableWidth = sprintf('%1$d', $availableWidth); #Making sure this is an integer so Perl wont go crazy during float comparisons.
    while ($textWidth > $availableWidth) {
        $text = substr( $text, 0, length($text)-1 );
        $textWidth = sprintf(  '%1$d', prStrWidth( $text )  );
        $tooLong = 1;
    }
    return (length $text, $text) if $tooLong;
    return (undef, $text);
}

=head _getTTFont

Selects one of the enabled Koha TrueType-fonts.

=cut

sub _getTTFont {
    my ($font) = @_;

    return prTTFont($font->{content});
}

1;
