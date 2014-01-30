package C4::Labels::OplibSheets::Sheet_6x1_1_2;

use PDF::Reuse;
use PDF::Reuse::Util;
use Modern::Perl;
use utf8;

use C4::Context;


my $debug = 1;

#$fontSizeOld is used to store the real font size when data elements need to be split on two rows with a smaller font.
my ($fontSize, $fontSizeOld);
my $fontName;


 ##########################
## Defining print regions ##
 ##########################

#By default PDF::Reuse generates a document which measures 841x595 units

my $padding = 6;

#Columns and rows travelling iterators.
my $labelRows = 6;

#Total print area dimensions
my $xMin = 9;
my $xMax = 579;
my $xWidth = $xMax - $xMin;
my $yMin = 14;
my $yMax = 817;
my $yHeight = $yMax - $yMin;

my $firstColWidth = 256;
my $secondColWidth = 262;


#Label printing area dimensions
my $labelAreaXMin = 0;
#my $labelAreaXMax = 527;
my $labelAreaXMax = $xMin+$firstColWidth+$secondColWidth;
my $labelAreaXWidth = $labelAreaXMax-$labelAreaXMin;
my $labelAreaYMin = 20; #From bottom of the paper
my $labelAreaYMax = 805; #From bottom of the paper!
my $labelAreaYHeight = $labelAreaYMax-$labelAreaYMin;

my $labelHeight = $labelAreaYHeight / $labelRows;

#spine label area printing dimension
my $slAreaXWidth = 62; #Spine label column width
my $slAreaXMin = $labelAreaXMax;
my $slAreaXMax = $slAreaXMin+$slAreaXWidth;
my $slAreaYMin = $labelAreaYMin;
my $slAreaYMax = $labelAreaYMax;
my $slAreaYHeight = $labelAreaYHeight;

my $slHeight = $slAreaYHeight / (2 * $labelRows);

sub calculatePrintRegions {
    #$m == margins
    my ($m) = @_;

    $xMin += $m->{left};
    $xMax = 579;
    $xWidth = $xMax - $xMin;
    $yMin = 14;
    $yMax = 817;
    $yHeight = $yMax - $yMin;

    $firstColWidth = 256;
    $secondColWidth = 262;


    #Label printing area dimensions
    $labelAreaXMin = 0;
    #$labelAreaXMax = 527;
    $labelAreaXMax = $xMin+$firstColWidth+$secondColWidth;
    $labelAreaXWidth = $labelAreaXMax-$labelAreaXMin;
    $labelAreaYMin = 20; #From bottom of the paper
    $labelAreaYMax = 805; #From bottom of the paper!
    $labelAreaYHeight = $labelAreaYMax-$labelAreaYMin;

    $labelHeight = $labelAreaYHeight / $labelRows;

    #spine label area printing dimension
    $slAreaXWidth = 62; #Spine label column width
    $slAreaXMin = $labelAreaXMax;
    $slAreaXMax = $slAreaXMin+$slAreaXWidth;
    $slAreaYMin = $labelAreaYMin;
    $slAreaYMax = $labelAreaYMax;
    $slAreaYHeight = $labelAreaYHeight;

    $slHeight = $slAreaYHeight / (2 * $labelRows);
}

 # /\ /\ /\ /\ /\ /\ /\ /\
## Print regions defined ##
 # /\ /\ /\ /\ /\ /\ /\ /\

=head
    C4::Labels::OplibSheets::Sheet_6x1_1_2::create($labelsData, $filePathAndName, $debug);

    Creates a label sticker sheets pdf-document to the given $filePathAndName location based on
    the $labelsData array of hashes.
    $debug option prints sticker dimensions on sheets for aligning to real stickers.

    $labelsData array can contain undef elements. Those elements create an empty label on the spot
    the label would normally be printed

    The sticker page layout (A4-size) is as follows:
    +----+----+-+
    |AAAA|AAAA|B|
    +----+----+-+   * A = label area (via printLabel()) and
    |AAAA|AAAA|B|   * B = spine label area (via printSpineLabel())
    +----+----+-+
    |AAAA|AAAA|B|
    +----+----+-+
    |AAAA|AAAA|B|
    +----+----+-+
    |AAAA|AAAA|B|
    +----+----+-+
    |AAAA|AAAA|B|
    +----+----+-+
=cut
sub create {
    my ($labelsData, $filePathAndName, $margins, $debug) = @_;

    ## Set the margins if available
    if (defined $margins->{left}) {
        calculatePrintRegions($margins);
    }


    prFile($filePathAndName);
    #$fontSizeOld is used to store the real font size when data elements need to be split on two rows with a smaller font.
    ($fontSize, $fontSizeOld) = prFontSize(12);
    $fontName = prFont('Helvetica');


    #The total maximum printable dimensions.
    prAdd(_guide_box($xMin,$yMin,$xWidth,$yHeight)) if $debug;

    #Align the label position
    my ($x, $y, $slY);# = alignLabelPosition();

    my $firstRun = 1; #Used to prevent new page creation for the first label

    my $i = 0; #How many labels have already been printed?
    foreach(@$labelsData) {

        my $labelData = $_;

        ##A QUICK PANIC HACK TO REMOVE ACCENTS FROM utf8 BECAUSE PDF::REUSE DOESNT PLAY NICE WITH SOME OF THEM!
        foreach my $k (keys %$labelData) {
            require Unicode::Normalize;
            require Text::Unidecode;

            my $string = $labelData->{$k};
            my $decomposed = $string;
            $decomposed =~ s/([^åäöæâéèêøóòô])/Unicode::Normalize::NFKD($1)/gei; #Firstly preserve certain characters we know works for sure
            $decomposed =~ s/\p{NonspacingMark}//g;
            $decomposed =~ s/(\W)/Text::Unidecode::unidecode($1)/ge; #Then change all other characters to a more common variant
            $labelData->{$k} =  $decomposed;
        }

        if ($i % 12 == 0) { #Room for only 12 labels on each page.
            #Start a new page and re-align the label iterators.
            prPage() if ! $firstRun;
            ($x, $y, $slY) = alignLabelPosition();
        }

        if ($i % 2 == 0) { #Print the first label column and spine label
            if ($debug) {
                prAdd(_guide_box($x+$xMin,$y,$firstColWidth,$labelHeight));
                prAdd(_guide_box($slAreaXMin,$slY,$slAreaXWidth,$slHeight));
            }
            if ($labelData) {
                printLabel($x+$xMin,$y,$firstColWidth,$labelHeight,$labelData);
                printSpineLabel($slAreaXMin,$slY,$slAreaXWidth,$slHeight,$labelData);
            }
            $slY -= $slHeight; #Move to the next spine label position
        }
        else { #Print the second label column and spine label
            if ($debug) {
                prAdd(_guide_box($x+$xMin+$firstColWidth,$y,$secondColWidth,$labelHeight));
                prAdd(_guide_box($slAreaXMin,$slY,$slAreaXWidth,$slHeight));
            }
            if ($labelData) {
                printLabel($x+$xMin+$firstColWidth,$y,$secondColWidth,$labelHeight,$labelData);
                printSpineLabel($slAreaXMin,$slY,$slAreaXWidth,$slHeight,$labelData);
            }
            $slY -= $slHeight; #Move to the next spine label position

            #Move to the next row
            $y -= $labelHeight;
        }

        $firstRun = 0 if $firstRun;
        $i++;
    }

    prEnd();
}



 ##################################
## End of the scripting component ##
 ##################################


##Starting subroutine declarations##



=head
my ($x, $y, $slY) = alignLabelPosition();

Realigns the write coordinates to the start of page.
=cut
sub alignLabelPosition {
    my $x = $labelAreaXMin;
    my $y = $labelAreaYMax - $labelHeight;
    my $slY = $slAreaYMax - $slHeight;
    return ($x, $y, $slY);
}
##Stolen from Koha :)
sub _guide_box {
    my ( $llx, $lly, $width, $height ) = @_;
    return unless ( defined $llx and defined $lly and
                    defined $width and defined $height );
    my $obj_stream = "q\n";                            # save the graphic state
    $obj_stream .= "0.5 w\n";                          # border line width
    $obj_stream .= "1.0 0.0 0.0  RG\n";                # border color red
    $obj_stream .= "1.0 1.0 1.0  rg\n";                # fill color white
    $obj_stream .= "$llx $lly $width $height re\n";    # a rectangle
    $obj_stream .= "B\n";                              # fill (and a little more)
    $obj_stream .= "Q\n";                              # restore the graphic state
    return $obj_stream;
}


sub printLabel {
    my ($x, $y, $width, $height, $ld) = @_; #$ld == label data pulled from the D
    my $leftWriteStart = $x+$padding;
    my $topWriteStart = $y+$labelHeight-$padding;
    my $yP = $topWriteStart; #$tP == $Y write position, keeps track of the Y-coordinate position.
    my $leftWidth = $width-$slAreaXWidth;
    $width = $width - (2*$padding);

#$ld->{title} .= 'ja karho on ice ja mozart went home - Psykofallistinen eepos printtitulostuksen haasteista.';
#$ld->{content_description} .= '2 nuottikirjaa (17s) + viisi cd-levyä ja paljon kaikkea muuta mitä toivoa saattaa';

    my @callNumber = split / /, $ld->{itemcallnumber};

    ($fontSize, undef) = prFontSize(10);
        _printOneLiner(                $leftWriteStart+$leftWidth+4, $yP,   $slAreaXWidth, $ld->{location_code}  );
    $yP = _printOneLiner(              $leftWriteStart,              $yP,   $leftWidth, $ld->{branchname}  );
        _printOneLiner(                $leftWriteStart+$leftWidth+4, $yP,   $slAreaXWidth, $callNumber[1]  );
    $yP = _printOneLiner(              $leftWriteStart,              $yP,   $leftWidth, $ld->{location_name}  );
    ($fontSize, undef) = prFontSize(9);
    $yP = _printOneLiner(              $leftWriteStart,              $yP-6, $width, $ld->{author}  );
    $yP = _printTwoLiner(              $leftWriteStart,              $yP,   $width, $ld->{title}  );
    ($fontSize, undef) = prFontSize(8);
    $yP = _printYearAndItemtypeAndDescription($leftWriteStart,              $yP-8, $width, $ld->{copyrightdate}, $ld->{itemtype}, $ld->{content_description}  );
    $yP = _printOneLiner(              $leftWriteStart,              $yP-8, $width, $ld->{barcode}  );
}
sub _printOneLiner {
    my ($x, $y, $width, $text) = @_;

    $text = _fitText($width, $text);
    prText($x, $y-$fontSize, $text);

    return $y-$fontSize;
}
=head
    $newYCoordinate = _printTwoLiner($xPosition, $yPosition, $availableWidth, $text, $lineSeparation);

    Subroutine can print the given text two two lines with a smaller font or to one line with the global font.
    This depends whther or not the given text with in the given $availableWidth.
    $lineSeparation increses/decreases the space between the two possible written lines.

=cut
sub _printTwoLiner {
    #Set parameters and default values
    my ($x, $y, $width, $text, $lineSeparation, $shrinkText) = @_;
    $lineSeparation = 0 if ! $lineSeparation;
    my $secondRowText;

    #Make the initial measurement should we cut the given text
    my ($cuttingPos, $firstRowText) = _fitText($width, $text);

    if ($cuttingPos) { #We need to cut the text ot make it fit
        ($fontSize, $fontSizeOld) = prFontSize( $fontSize-3 ) if $shrinkText; #Shrink the font to take less space

        ($cuttingPos, $firstRowText) = _fitText($width, $text); #Make a new measurement with the new font size
        if ($cuttingPos) { #When the text is measured again in smaller font we might not have to cut it at all!
            $secondRowText = _fitText(  $width, substr($text, $cuttingPos)  ); #Cut the second row text
        }

        #Print texts if available
        prText($x, $y-$fontSize, $firstRowText);
        prText($x, $y-($fontSize*2)+$lineSeparation, $secondRowText) if $secondRowText;

        ($fontSize, $fontSizeOld) = prFontSize( $fontSizeOld ) if $shrinkText; #Revert the font to the old one.

        if ($secondRowText) {
            return $y-($fontSizeOld*2)+$lineSeparation; #Return the Y-coordinate below the recently written text.
        }
        return $y-$fontSizeOld; #Return the Y-coordinate below the recently written text, but only for the one written line.
    }
    else {
        prText($x, $y-$fontSize, $firstRowText);
        return $y-$fontSize;
    }
}
sub _printOneLinerShrinkToWidth {
    #Set parameters and default values
    my ($x, $y, $width, $text) = @_;

    #Make the initial measurement should we cut the given text
    my ($cuttingPos, $firstRowText) = _fitText($width, $text);
    if ($cuttingPos) {
        $fontSizeOld = $fontSize;
        my $i = 0; #Iteration counter to prevent an endless loop
        while($cuttingPos && ++$i < 10) {
            ($fontSize, undef) = prFontSize( $fontSize-1 ); #Shrink the font to take less space
            ($cuttingPos, $firstRowText) = _fitText($width, $text);
        }

        prText($x, $y-$fontSize, $firstRowText);

        ($fontSize, $fontSizeOld) = prFontSize( $fontSizeOld ); #Revert the font to the old one.
        return $y-$fontSizeOld;
    }
    else {
        prText($x, $y-$fontSize, $firstRowText);
        return $y-$fontSize;
    }
}
sub _printYearAndItemtypeAndDescription {
    my ($x, $y, $width, $year, $type, $description) = @_;
    my $text = '';

    if ($year) {
        $text .= $year . ' ; ';
    }

    $text .= $type;

    if ($description) {
        $text .= ' ; ' . $description;
    }

    return _printTwoLiner($x, $y, $width, $text,0, 'shrinkText');
}


sub printSpineLabel {
    my ($x, $y, $width, $height, $ld) = @_; #$ld == label data pulled from the D
    my $leftWriteStart = $x+$padding;
    my $topWriteStart = $y+$slHeight-$padding;
    my $yP = $topWriteStart; #$tP == $Y write position, keeps track of the Y-coordinate position.
    $width = $width - (2*$padding);

#$ld->{title} .= 'ja karho on ice ja mozart went home - Psykofallistinen eepos printtitulostuksen haasteista.';
#$ld->{content_description} .= '2 nuottikirjaa (17s) + viisi cd-levyä ja paljon kaikkea muuta mitä toivoa saattaa';

    my @callNumber = split( / /, $ld->{itemcallnumber});

    ($fontSize, undef) = prFontSize(12);
    $yP = _printOneLinerShrinkToWidth(  $leftWriteStart, $yP, $width, $callNumber[0]  );
    ($fontSize, undef) = prFontSize(10);
    $yP = _printOneLiner(  $leftWriteStart, $yP-4, $width, $callNumber[1]  );
    ($fontSize, undef) = prFontSize(14);
    $yP = _printOneLiner(  $leftWriteStart, $yP-4, $width, $callNumber[2]  );
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

    my $textWidth = sprintf(  '%1$d', prStrWidth( $text, 'Helvetica', $fontSize )  );
    $availableWidth = sprintf('%1$d', $availableWidth); #Making sure this is an integer so Perl wont go crazy during float comparisons.
    while ($textWidth > $availableWidth) {
        $text = substr( $text, 0, length($text)-1 );
        $textWidth = sprintf(  '%1$d', prStrWidth( $text )  );
        $tooLong = 1;
    }
    return (length $text, $text) if $tooLong;
    return (undef, $text);
}
