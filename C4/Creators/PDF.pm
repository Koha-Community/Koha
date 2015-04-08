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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use PDF::Reuse;
use PDF::Reuse::Barcode;
use File::Temp;
use List::Util qw/first/;

BEGIN {
    use version; our $VERSION = qv('3.07.00.049');
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

    my $ttf = C4::Context->config('ttf');

    if ( $ttf ) {
        my $ttf_path = first { $_->{type} eq $fontName } @{ $ttf->{font} };
        if ( -e $ttf_path->{content} ) {
            return prTTFont($ttf_path->{content});
        } else {
            warn "ERROR in koha-conf.xml -- missing <font type=\"$fontName\">/path/to/font.ttf</font>";
        }
    }
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
    return prJpeg($imageData, $width, $height, $imageFormat);
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

    # replace font code with path to TTF font file if need be
    my $ttf = C4::Context->config('ttf');
    if ( $ttf ) {
        my $ttf_path = first { $_->{type} eq $font } @{ $ttf->{font} };
        if ( -e $ttf_path->{content} ) {
            $font = $ttf_path->{content};
        } else {
            warn "ERROR in koha-conf.xml -- missing <font type=\"$font\">/path/to/font.ttf</font>";
        }
    }

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
