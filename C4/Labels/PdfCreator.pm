package C4::Labels::PdfCreator;
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
use Scalar::Util qw(blessed);
use PDF::Reuse;
use File::Fu::File;
use Try::Tiny;
use Scalar::Util qw(blessed);

use C4::Context;
use C4::Labels::DataSourceManager;

use Koha::Exception::BadParameter;
use Koha::Exception::UnknownObject;
use Koha::Exception::DB;
use Koha::Exception::Labels::UnknownItems;

use Koha::Logger;
our $logger = Koha::Logger->get();

=head new

    my $creator = C4::Labels::PdfCreator->new({
        sheet => C4::Labels::Sheet,                   #MANDATORY
        margins => {left => 5, top => 5},             #Defaults to 0
        file => '/tmp/labels.pdf' || File::Fu::File,  #MANDATORY
    });
    $creator->create(@barcodes);

=cut

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless($self, $class);
    $self->setSheet($params->{sheet});
    $self->setMargins($params->{margins});
    $self->setFile($params->{file});
    return $self;
}

=head create

    $pdfCreator->create(['167N001', '167N002', ...]);

Creates a pdf using the given sheet and margins.
The trick is that PDF::Reuse's coordinates start from bottom left, where coordinates used
in css3 start from top left, thus the sheet coordinates need to be inverted somehow.
=cut

sub create {
    my ($self, $itemBarcodes) = @_;
    my $items = $self->_normalizeBarcodesToItems($itemBarcodes); #Check if we have bad items.
    my $sheet = $self->getSheet();

    ##Start .pdf creation.
    my $filePath = $self->getFile()->stringify();
    $logger->debug("Writing PDF to '$filePath'") if $logger->is_debug;
#    system("rm", "$filePath");
    prFile($filePath);
    $self->setMediaBoxFromSheet($sheet);
    ($self->{fontSize}, $self->{fontSizeOld}) = prFontSize(12);
    $self->{font} = getTTFont();
    $self->setOrigo();

    $sheet->setPdfPosition($self->getOrigo());
    $self->printBoundingBox($sheet);

    my $firstRun = 1; #Used to prevent new page creation for the first label

    my $i = 0; #How many labels have already been printed?
    for (my $i=0 ; $i<@$itemBarcodes ; $i++) {
        my $barcode = $itemBarcodes->[$i];
        my $itemIndex = $i % scalar(@{$sheet->{items}});
        my $item = $sheet->getItems()->[$itemIndex];

        if ($itemIndex == 0 && not($firstRun)) { #Have we filled all Item slots on this page?
            #Start a new page
            prPage();
            $self->printBoundingBox($sheet);
        }
        $firstRun = 0 if $firstRun;

        next() if (not($barcode) || length($barcode) == 0); #Don't print an empty barcode, but reserve the sticker slot.
        foreach my $region (@{$item->{regions}}) {
            $region->setPdfPosition($self->getOrigo());
            $self->printBoundingBox($region);
            foreach my $element (@{$region->{elements}}) {
                $element->setPdfPosition($self->getOrigo());
                $self->printBoundingBox($element);
                $self->printElement($element, $barcode);
            }
        }
    }

    prEnd();
    return ($filePath);
}

=head2 setMediaBoxFromSheet

Sets the MediaBox-property of a PDF-Page.
MediaBox I suppose is basically the page size.

Based on http://www.adobe.com/content/dam/Adobe/en/devnet/acrobat/pdfs/PDF32000_2008.pdf
Page 85, Table 30, MediaBox

=cut

sub setMediaBoxFromSheet {
    my ($self, $sheet) = @_;
    unless ($sheet->isa('C4::Labels::Sheet')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[0]."():> Param \$sheet '$sheet' is not a proper Sheet-object!");
    }
    my @pos = (0, 0, $sheet->getPdfDimensions()->{width}, $sheet->getPdfDimensions()->{height});
    $logger->debug("Setting MediaBox as '@pos'") if $logger->is_debug;
    prMbox(@pos);
}

sub printBoundingBox {
    my ($self, $object) = @_;
    if ($object->getBoundingBox()) {
        my $pos = $object->getPdfPosition();
        my @pos = ($pos->{x}, $pos->{y}, $object->getPdfDimensions()->{width}, $object->getPdfDimensions()->{height});
        $logger->debug("Bounding box at '".join(', ',@pos)."'") if $logger->is_debug;
        prAdd(_box(@pos));
    }
}
sub printElement {
    my ($self, $element, $itemId) = @_;

    try {
        $logger->debug("PrintElement item:'$itemId'") if $logger->is_debug;
        my $text = C4::Labels::DataSourceManager::executeDataSource($element, $itemId);
        $logger->debug("PrintElement item:'$itemId', text:'$text'") if $logger->is_debug;
        C4::Labels::DataSourceManager::executeDataFormat($element, $text);
    } catch { #Simply tag the Exception with the current Element and pass it upstream
        $logger->warn("PrintElement item:'$itemId', exception:'$_'") if $logger->is_warn;
        my $idTag = "Error printing label for Item '$itemId'";
        die "$idTag\n$_" unless blessed($_) && $_->can('rethrow');
        $_->{message} = $idTag."\n".$_->{message};
        $_->rethrow();
    }
}

=head _fitText()

my ($shorteningPosition, $shortenedText) = _fitText($availableWidth, $text);

Shortens the given $text to fit the given $availableWidth.
Returns the $shortenedText and the length of the new text so we know the point of cutting.
$shorteningPosition is undef if no cutting happened.

=cut

sub _fitText {
    my ($availableWidth, $text) = @_;

    my $tooLong; #A boolean (flag) if we had to shorten the text

    my $textWidth = sprintf(  '%1$d', prStrWidth( $text, 'Helvetica', 12 )  );
    $availableWidth = sprintf('%1$d', $availableWidth); #Making sure this is an integer so Perl wont go crazy during float comparisons.
    while ($textWidth > $availableWidth) {
        $text = substr( $text, 0, length($text)-1 );
        $textWidth = sprintf(  '%1$d', prStrWidth( $text )  );
        $tooLong = 1;
    }
    return (length $text, $text) if $tooLong;
    return (undef, $text);
}
sub _box {
    my ( $llx, $lly, $width, $height ) = @_;
    unless ( defined $llx and defined $lly and defined $width and defined $height ) {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($llx, $lly, $width, $height):> undefined parameter!");
    }
    $height *= -1; #Reverse height since we come from top to bottom

    my $obj_stream = "q\n";                            # save the graphic state
    $obj_stream .= "0.5 w\n";                          # border line width
    $obj_stream .= "1.0 0.0 0.0  RG\n";                # border color red
    $obj_stream .= "1.0 1.0 1.0  rg\n";                # fill color white
    $obj_stream .= "$llx $lly $width $height re\n";    # a rectangle
    $obj_stream .= "B\n";                              # fill (and a little more)
    $obj_stream .= "Q\n";                              # restore the graphic state
    return $obj_stream;
}
sub getTTFont {
    my $fontName = shift || 'TR'; #DejaVuSerif.ttf
    my $ttf = C4::Context->config('ttf') or Koha::Exception::UnknownObject->throw(error => __PACKAGE__.":: No TrueType-font configured!");
    my $ttf_path = List::Util::first { $_->{type} eq $fontName } @{ $ttf->{font} };
    if ( -e $ttf_path->{content} ) {
        return prTTFont($ttf_path->{content});
    } else {
        Koha::Exception::UnknownObject->throw(error => __PACKAGE__.":: ERROR in koha-conf.xml -- missing <font type=\"$fontName\">/path/to/font.ttf</font>");
    }
}
sub getPos {
    my ($self, $position) = @_;
    my $sheetHeight = $self->getSheet()->getHeight();
    my $origo = $self->getOrigo();
    my $x = $origo->[0] + $position->{left};
    my $y = $sheetHeight + $origo->[1] - $position->{top};
    return [$x, $y];
}
sub setOrigo {
    my ($self) = @_;
    my $margins = $self->getMargins();
    $self->{origo} = [$margins->{left}, $margins->{top}];
}
sub getOrigo {
    return shift->{origo};
}
sub setSheet {
    my ($self, $sheet) = @_;
    unless (blessed($sheet) && $sheet->isa('C4::Labels::Sheet')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'sheet' is not a C4::Labels::Sheet-object");
    }
    $self->{sheet} = $sheet;
}
sub getSheet { return shift->{sheet}; }
sub setMargins {
    my ($self, $margins) = @_;
    if ($margins) {
        unless (ref($margins) eq 'HASH') {
            Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'margins' is not a hash");
        }
        unless ($margins->{left} =~ /^-?\d+$/ && $margins->{top} =~ /^-?\d+$/) {
            Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'margins' has bad 'left' and/or 'top' -attributes");
        }
        $self->{margins} = $margins;
    }
    else {
        $self->{margins} = {left => 0, top => 0};
    }
}
sub getMargins { return shift->{margins}; }
sub setFile {
    my ($self, $filePath) = @_;
    unless ($filePath) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[0]."():> Parameter 'file' doesn't exist. This must be a full path to the desired .pdf-file location, eg. '/tmp/koha/pdf/labels.pdf' or a File::Fu::File-object");
    }
    my $file = (blessed($filePath) && $filePath->isa('File::Fu::File')) ? $filePath : File::Fu::File->new($filePath);
    $file->touch(); #Check that we have a permission to access the file

    $self->{file} = $file;
}
sub getFile { return shift->{file}; }

=head _normalizeBarcodesToItems

    my $items = _normalizeBarcodesToItems($barcodesAry);

Gets a bunch of Items/barcodes and casts them all to C4::Items.
If casting is impossible, collects bad barcodes and throws an error.
@PARAM1, ARRAYRef, HASHRefs of Items or scalars of koha.items.barcodes
@THROWS Koha::Exception::UnknownObject if some Items were not found
@THROWS Koha::Exception::BadParameter if @PARAM1 is invalid.

=cut

sub _normalizeBarcodesToItems {
    my ($self, $barcodesAry) = @_;
    unless(ref($barcodesAry) eq 'ARRAY') {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($barcodesAry):> Parameter 1 is not an ARRAYRef");
    }

    my @errors;
    my @items;
    for (my $i=0 ; $i<scalar(@$barcodesAry) ; $i++) {
        my $ibc = $barcodesAry->[$i];
        my $item;
        if (ref($ibc) eq 'HASH' && $ibc->{barcode}) {
            #This is an C4::Item most certainly so accept it as it is
            $item = $ibc;
        }
        elsif ($ibc) {
            #This is a barcode so fetch an item by barcode
            $item = C4::Items::GetItem(undef, $ibc, undef);
        }
        else {
            $item = '';
        }
        unless(defined($item)) {
            push(@errors, $ibc);
            splice(@$barcodesAry, $i, 1);
            #$barcodesAry->[$i] = undef; #Can't decide should the barcodeAry be shortened or the bad indexes be set as undef?
        }
        $items[$i] = $item;
    }

    if (scalar(@errors)) {
        Koha::Exception::Labels::UnknownItems->throw(badBunch => \@errors);
    }
    return \@items;
}

return 1;
