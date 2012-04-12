package C4::Creators::PDF;

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use File::Temp;

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

    my $fh = File::Temp->new( UNLINK => 0, SUFFIX => '.pdf' );
    $opts{Name} = $self->{filename} = "$fh"; # filename
    close $fh; # we need just filename

    prFile(\%opts);
    bless ($self, $type);
    return $self;
}

sub End {
    my $self = shift;
    # if the pdf stream is utf8, explicitly set it to utf8; this avoids at lease some wide character errors -chris_n
    utf8::encode($PDF::Reuse::stream) if utf8::is_utf8($PDF::Reuse::stream);
    prEnd();

    # slurp temporary filename and print it out for plack to pick up
    local $/ = undef;
    open(my $fh, '<', $self->{filename}) || die "$self->{filename}: $!";
    print <$fh>;
    close $fh;
    unlink $self->{filename};
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

sub AltJpeg {
    my $self = shift;
    my ($imageData, $width, $height, $imageFormat, $altImageData, $altImageWidth, $altImageHeight, $altImageFormat) = @_;
    return prAltJpeg($imageData, $width, $height, $imageFormat, $altImageData, $altImageWidth, $altImageHeight, $altImageFormat);
}

sub Jpeg {
    my $self = shift;
    my ($imageData, $width, $height, $imageFormat) = @_;
    return prJpegBlob($imageData, $width, $height, $imageFormat);
}

# FIXME: This magick foo is an absolute hack until the maintainer of PDF::Reuse releases the next version which will include these features

sub prAltJpeg
{  my ($iData, $iWidth, $iHeight, $iFormat,$aiData, $aiWidth, $aiHeight, $aiFormat) = @_;
   my ($namnet, $utrad);
   if (! $PDF::Reuse::pos)                    # If no output is active, it is no use to continue
   {   return undef;
   }
   prJpegBlob($aiData, $aiWidth, $aiHeight, $aiFormat);
   my $altObjNr = $PDF::Reuse::objNr;
   $PDF::Reuse::imageNr++;
   $namnet = 'Ig' . $PDF::Reuse::imageNr;
   $PDF::Reuse::objNr++;
   $PDF::Reuse::objekt[$PDF::Reuse::objNr] = $PDF::Reuse::pos;
   $utrad = "$PDF::Reuse::objNr 0 obj\n" .
            "[ << /Image $altObjNr 0 R\n" .
            "/DefaultForPrinting true\n" .
            ">>\n" .
            "]\n" .
            "endobj\n";
   $PDF::Reuse::pos += syswrite *PDF::Reuse::UTFIL, $utrad;
   if ($PDF::Reuse::runfil)
   {  $PDF::Reuse::log .= "Jpeg~AltImage\n";
   }
   $PDF::Reuse::objRef{$namnet} = $PDF::Reuse::objNr;
   $namnet = prJpegBlob($iData, $iWidth, $iHeight, $iFormat, $PDF::Reuse::objNr);
   if (! $PDF::Reuse::pos)
   {  errLog("No output file, you have to call prFile first");
   }
   return $namnet;
}

sub prJpegBlob
{  my ($iData, $iWidth, $iHeight, $iFormat, $altArrayObjNr) = @_;
   my ($iLangd, $namnet, $utrad);
   if (! $PDF::Reuse::pos)                    # If no output is active, it is no use to continue
   {   return undef;
   }
   my $checkidOld = $PDF::Reuse::checkId;
   if (!$iFormat)
   {   my ($iFile, $checkId) = findGet($iData, $checkidOld);
       if ($iFile)
       {  $iLangd = (stat($iFile))[7];
          $PDF::Reuse::imageNr++;
          $namnet = 'Ig' . $PDF::Reuse::imageNr;
          $PDF::Reuse::objNr++;
          $PDF::Reuse::objekt[$PDF::Reuse::objNr] = $PDF::Reuse::pos;
          open (BILDFIL, "<$iFile") || errLog("Couldn't open $iFile, $!, aborts");
          binmode BILDFIL;
          my $iStream;
          sysread BILDFIL, $iStream, $iLangd;
          $utrad = "$PDF::Reuse::objNr 0 obj\n<</Type/XObject/Subtype/Image/Name/$namnet" .
                    "/Width $iWidth /Height $iHeight /BitsPerComponent 8 " .
                    ($altArrayObjNr ? "/Alternates $altArrayObjNr 0 R " : "") .
                    "/Filter/DCTDecode/ColorSpace/DeviceRGB"
                    . "/Length $iLangd >>stream\n$iStream\nendstream\nendobj\n";
          close BILDFIL;
          $PDF::Reuse::pos += syswrite $PDF::Reuse::UTFIL, $utrad;
          if ($PDF::Reuse::runfil)
          {  $PDF::Reuse::log .= "Cid~$PDF::Reuse::checkId\n";
             $PDF::Reuse::log .= "Jpeg~$iFile~$iWidth~$iHeight\n";
          }
          $PDF::Reuse::objRef{$namnet} = $PDF::Reuse::objNr;
       }
       undef $checkId;
   }
   elsif ($iFormat == 1)
   {  my $iBlob = $iData;
      $iLangd = length($iBlob);
      $PDF::Reuse::imageNr++;
      $namnet = 'Ig' . $PDF::Reuse::imageNr;
      $PDF::Reuse::objNr++;
      $PDF::Reuse::objekt[$PDF::Reuse::objNr] = $PDF::Reuse::pos;
      $utrad = "$PDF::Reuse::objNr 0 obj\n<</Type/XObject/Subtype/Image/Name/$namnet" .
                "/Width $iWidth /Height $iHeight /BitsPerComponent 8 " .
                ($altArrayObjNr ? "/Alternates $altArrayObjNr 0 R " : "") .
                "/Filter/DCTDecode/ColorSpace/DeviceRGB"
                . "/Length $iLangd >>stream\n$iBlob\nendstream\nendobj\n";
      $PDF::Reuse::pos += syswrite *PDF::Reuse::UTFIL, $utrad;
      if ($PDF::Reuse::runfil)
      {  $PDF::Reuse::log .= "Jpeg~Blob~$iWidth~$iHeight\n";
      }
      $PDF::Reuse::objRef{$namnet} = $PDF::Reuse::objNr;
   }
   if (! $PDF::Reuse::pos)
   {  errLog("No output file, you have to call prFile first");
   }
   return $namnet;
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

C4::Creators::PDF -   A class wrapper for PDF::Reuse and PDF::Reuse::Barcode to allow usage as a psuedo-object. For usage see
                    PDF::Reuse documentation and C4::Creators::PDF code.

=cut

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut
