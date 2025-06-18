package C4::Creators::PDF;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;
use PDF::Reuse qw(
    prAdd
    prAltJpeg
    prBookmark
    prCompress
    prDoc
    prDocDir
    prDocForm
    prEnd
    prExtract
    prField
    prFile
    prFont
    prFontSize
    prForm
    prGetLogBuffer
    prGraphState
    prImage
    prInit
    prInitVars
    prJpeg
    prJs
    prLink
    prLog
    prLogDir
    prMbox
    prPage
    prSinglePage
    prStrWidth
    prText
    prTTFont
);
use PDF::Reuse::Barcode;
use File::Temp;
use List::Util qw( first );

sub _InitVars {
    my $self  = shift;
    my $param = shift;
    prInitVars($param);
}

=head1 Functions

=cut

=head2 new

Missing POD for new.

=cut

sub new {
    my $invocant = shift;
    my $type     = ref($invocant) || $invocant;
    my %opts     = @_;
    my $self     = {};
    _InitVars()                  if ( $opts{InitVars} == 0 );
    _InitVars( $opts{InitVars} ) if ( $opts{InitVars} > 0 );
    delete( $opts{InitVars} );
    prDocDir( $opts{'DocDir'} ) if $opts{'DocDir'};
    delete( $opts{'DocDir'} );

    my $fh = File::Temp->new( UNLINK => 0, SUFFIX => '.pdf' );
    $opts{Name} = $self->{filename} = "$fh";    # filename
    close $fh;                                  # we need just filename

    prFile( \%opts );
    bless( $self, $type );
    return $self;
}

=head2 End

Missing POD for End.

=cut

sub End {
    my $self = shift;

    prEnd();

    # slurp temporary filename and print it out for plack to pick up
    local $/ = undef;
    open( my $fh, '<', $self->{filename} ) || die "$self->{filename}: $!";
    print <$fh>;
    close $fh;
    unlink $self->{filename};
}

=head2 Add

Missing POD for Add.

=cut

sub Add {
    my $self   = shift;
    my $string = shift;
    prAdd($string);
}

=head2 Bookmark

Missing POD for Bookmark.

=cut

sub Bookmark {
    my $self      = shift;
    my $reference = shift;
    prBookmark($reference);
}

=head2 Compress

Missing POD for Compress.

=cut

sub Compress {
    my $self      = shift;
    my $directive = shift;
    prCompress($directive);
}

=head2 Doc

Missing POD for Doc.

=cut

sub Doc {
    my $self   = shift;
    my %params = @_;
    prDoc(%params);
}

=head2 DocForm

Missing POD for DocForm.

=cut

sub DocForm {
    my $self   = shift;
    my %params = @_;
    return prDocForm(%params);
}

=head2 Extract

Missing POD for Extract.

=cut

sub Extract {
    my $self = shift;
    my ( $pdfFile, $pageNo, $oldInternalName ) = @_;
    return prExtract( $pdfFile, $pageNo, $oldInternalName );
}

=head2 Field

Missing POD for Field.

=cut

sub Field {
    my $self = shift;
    my ( $fieldName, $value ) = @_;
    prField( $fieldName, $value );
}

=head2 Font

Missing POD for Font.

=cut

sub Font {
    my $self     = shift;
    my $fontName = shift;

    my $ttf = C4::Context->config('ttf');

    if ($ttf) {
        my $ttf_path = first { $_->{type} eq $fontName } @{ $ttf->{font} };
        if ( -e $ttf_path->{content} ) {
            return prTTFont( $ttf_path->{content} );
        } else {
            warn "ERROR in koha-conf.xml -- missing <font type=\"$fontName\">/path/to/font.ttf</font>";
        }
    }
    return prFont($fontName);
}

=head2 FontSize

Missing POD for FontSize.

=cut

sub FontSize {
    my $self = shift;
    my $size = shift;
    return prFontSize($size);
}

=head2 Form

Missing POD for Form.

=cut

sub Form {
    my $self   = shift;
    my %params = @_;
    return prForm(%params);
}

=head2 GetLogBuffer

Missing POD for GetLogBuffer.

=cut

sub GetLogBuffer {
    my $self = shift;
    return prGetLogBuffer();
}

=head2 GraphState

Missing POD for GraphState.

=cut

sub GraphState {
    my $self   = shift;
    my $string = shift;
    prGraphState($string);
}

=head2 Image

Missing POD for Image.

=cut

sub Image {
    my $self   = shift;
    my %params = @_;
    return prImage(%params);
}

=head2 Init

Missing POD for Init.

=cut

sub Init {
    my $self = shift;
    my ( $string, $duplicateCode ) = @_;
    prInit( $string, $duplicateCode );
}

=head2 AltJpeg

Missing POD for AltJpeg.

=cut

sub AltJpeg {
    my $self = shift;
    my ( $imageData, $width, $height, $imageFormat, $altImageData, $altImageWidth, $altImageHeight, $altImageFormat ) =
        @_;
    return prAltJpeg(
        $imageData, $width, $height, $imageFormat, $altImageData, $altImageWidth, $altImageHeight,
        $altImageFormat
    );
}

=head2 Jpeg

Missing POD for Jpeg.

=cut

sub Jpeg {
    my $self = shift;
    my ( $imageData, $width, $height, $imageFormat ) = @_;
    return prJpeg( $imageData, $width, $height, $imageFormat );
}

=head2 Js

Missing POD for Js.

=cut

sub Js {
    my $self               = shift;
    my $string_or_fileName = shift;
    prJs($string_or_fileName);
}

=head2 Link

Missing POD for Link.

=cut

sub Link {
    my $self   = shift;
    my %params = @_;
    prLink(%params);
}

=head2 Log

Missing POD for Log.

=cut

sub Log {
    my $self   = shift;
    my $string = shift;
    prLog($string);
}

=head2 LogDir

Missing POD for LogDir.

=cut

sub LogDir {
    my $self      = shift;
    my $directory = shift;
    prLogDir($directory);
}

=head2 Mbox

Missing POD for Mbox.

=cut

sub Mbox {
    my $self = shift;
    my ( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY ) = @_;
    prMbox( $lowerLeftX, $lowerLeftY, $upperRightX, $upperRightY );
}

=head2 Page

Missing POD for Page.

=cut

sub Page {
    my $self  = shift;
    my $noLog = shift;
    prPage($noLog);
}

=head2 SinglePage

Missing POD for SinglePage.

=cut

sub SinglePage {
    my $self = shift;
    my ( $file, $pageNumber ) = @_;
    return prSinglePage( $file, $pageNumber );
}

=head2 StrWidth

Missing POD for StrWidth.

=cut

sub StrWidth {
    my $self = shift;
    my ( $string, $font, $fontSize ) = @_;

    # replace font code with correct internal font
    $font = C4::Creators::PDF->Font($font);

    return prStrWidth( $string, $font, $fontSize );
}

=head2 Text

Missing POD for Text.

=cut

sub Text {
    my $self = shift;
    my ( $x, $y, $string, $align, $rotation ) = @_;
    return prText( $x, $y, $string, $align, $rotation );
}

=head2 TTFont

Missing POD for TTFont.

=cut

sub TTFont {
    my $self = shift;
    my $path = shift;
    return prTTFont($path);
}

=head2 Code128

Missing POD for Code128.

=cut

sub Code128 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Code128(%opts);
}

=head2 Code39

Missing POD for Code39.

=cut

sub Code39 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Code39(%opts);
}

=head2 COOP2of5

Missing POD for COOP2of5.

=cut

sub COOP2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::COOP2of5(%opts);
}

=head2 EAN13

Missing POD for EAN13.

=cut

sub EAN13 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::EAN13(%opts);
}

=head2 EAN8

Missing POD for EAN8.

=cut

sub EAN8 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::EAN8(%opts);
}

=head2 IATA2of5

Missing POD for IATA2of5.

=cut

sub IATA2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::IATA2of5(%opts);
}

=head2 Industrial2of5

Missing POD for Industrial2of5.

=cut

sub Industrial2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Industrial2of5(%opts);
}

=head2 ITF

Missing POD for ITF.

=cut

sub ITF {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::ITF(%opts);
}

=head2 Matrix2of5

Missing POD for Matrix2of5.

=cut

sub Matrix2of5 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::Matrix2of5(%opts);
}

=head2 NW7

Missing POD for NW7.

=cut

sub NW7 {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::NW7(%opts);
}

=head2 UPCA

Missing POD for UPCA.

=cut

sub UPCA {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::UPCA(%opts);
}

=head2 UPCE

Missing POD for UPCE.

=cut

sub UPCE {
    my $self = shift;
    my %opts = @_;
    PDF::Reuse::Barcode::UPCE(%opts);
}

1;
__END__


=head1 NAME

C4::Creators::PDF -   A class wrapper for PDF::Reuse and PDF::Reuse::Barcode to allow usage as a pseudo-object. For usage see
                    PDF::Reuse documentation and C4::Creators::PDF code.

=cut

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=cut
