package C4::Labels::PDF;

# Copyright 2009 Foundations Bible College.
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
use PDF::Reuse;
use PDF::Reuse::Barcode;

BEGIN {
    use version; our $VERSION = qv('1.0.0_1');
}

sub _InitVars {
    my $self = shift;
    my $param = shift;
    prInitVars($param);
}

sub new {
    my $invocant = shift;
    my $type = ref($invocant) || $invocant;
    my %opts = @_;
    my $self = {};
    _InitVars() if ($opts{InitVars} == 0);
    _InitVars($opts{InitVars}) if ($opts{InitVars} > 0);
    delete($opts{InitVars});
    prDocDir($opts{'DocDir'}) if $opts{'DocDir'};
    delete($opts{'DocDir'});
    prFile(%opts);
    bless ($self, $type);
    return $self;
}

sub End {
    my $self = shift;
    prEnd();
}

sub Add {
    my $self = shift;
    my $string = shift;
    prAdd($string);
}

sub Bookmark {
    my $self = shift;
    my $reference = shift;
    prBookmark($reference);
}

sub Compress {
    my $self = shift;
    my $directive = shift;
    prCompress($directive);
}

sub Doc {
    my $self = shift;
    my %params = @_;
    prDoc(%params);
}

sub DocForm {
    my $self = shift;
    my %params = @_;
    return prDocForm(%params);
}

sub Extract {
    my $self = shift;
    my ($pdfFile, $pageNo, $oldInternalName) = @_;
    return prExtract($pdfFile, $pageNo, $oldInternalName);
}

sub Field {
    my $self = shift;
    my ($fieldName, $value) = @_;
    prField($fieldName, $value);
}

sub Font {
    my $self = shift;
    my $fontName = shift;
    return prFont($fontName);
}

sub FontSize {
    my $self = shift;
    my $size = shift;
    return prFontSize($size);
}

sub Form {
    my $self = shift;
    my %params = @_;
    return prForm(%params);
}

sub GetLogBuffer {
    my $self = shift;
    return prGetLogBuffer();
}

sub GraphState {
    my $self = shift;
    my $string = shift;
    prGraphState($string);
}

sub Image {
    my $self = shift;
    my %params = @_;
    return prImage(%params);
}

sub Init {
    my $self = shift;
    my ($string, $duplicateCode) = @_;
    prInit($string, $duplicateCode);
}

sub Jpeg {
    my $self = shift;
    my ($imageFile, $width, $height) = @_;
    return prJpeg($imageFile, $width, $height);
}

sub Js {
    my $self = shift;
    my $string_or_fileName = shift;
    prJs($string_or_fileName);
}

sub Link {
    my $self = shift;
    my %params = @_;
    prLink(%params);
}

sub Log {
    my $self = shift;
    my $string = shift;
    prLog($string);
}

sub LogDir {
    my $self = shift;
    my $directory = shift;
    prLogDir($directory);
}

sub Mbox {
    my $self = shift;
    my ($lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY) = @_;
    prMbox($lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY);
}

sub Page {
    my $self = shift;
    my $noLog = shift;
    prPage($noLog);
}

sub SinglePage {
    my $self = shift;
    my ($file, $pageNumber) = @_;
    return prSinglePage($file, $pageNumber);
}

sub StrWidth {
    my $self = shift;
    my ($string, $font, $fontSize) = @_;
    return prStrWidth($string, $font, $fontSize);
}

sub Text {
    my $self = shift;
    my ($x, $y, $string, $align, $rotation) = @_;
    return prText($x, $y, $string, $align, $rotation);
}

sub TTFont {
    my $self = shift;
    my $path = shift;
    return prTTFont($path);
}

sub Code128 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Code128(%opts);
}

sub Code39 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Code39(%opts);
}

sub COOP2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::COOP2of5(%opts);
}

sub EAN13 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::EAN13(%opts);
}

sub EAN8 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::EAN8(%opts);
}

sub IATA2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::IATA2of5(%opts);
}

sub Industrial2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Industrial2of5(%opts);
}

sub ITF {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::ITF(%opts);
}

sub Matrix2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Matrix2of5(%opts);
}

sub NW7 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::NW7(%opts);
}

sub UPCA {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::UPCA(%opts);
}

sub UPCE {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::UPCE(%opts);
}

1;
__END__


=head1 NAME

C4::Labels::PDF -   A class wrapper for PDF::Reuse and PDF::Reuse::Barcode to allow usage as a psuedo-object. For usage see
                    PDF::Reuse documentation and C4::Labels::PDF code.

=cut

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut
