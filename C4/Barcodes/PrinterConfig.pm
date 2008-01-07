package C4::Barcodes::PrinterConfig;

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
use vars qw($VERSION @EXPORT);

use PDF::API2;
use PDF::API2::Page;

BEGIN {
	# set the version for version checking
	$VERSION = 0.02;
	require Exporter;
	@EXPORT = qw(&labelsPage &getLabelPosition setPositionsForX setPositionsForY);
}

=head1 NAME

C4::Barcodes::PrinterConfig - Koha module dealing with labels in a PDF.

=head1 SYNOPSIS

	use C4::Barcodes::PrinterConfig;

=head1 DESCRIPTION

This package is used to deal with labels in a pdf file. Giving some parameters,
this package contains several functions to handle every label considering the 
environment of the pdf file.

=head1 FUNCTIONS

=over 2

=cut

my @positionsForX; # Takes all the X positions of the pdf file.
my @positionsForY; # Takes all the Y positions of the pdf file.
my $firstLabel = 1; # Test if the label passed as a parameter is the first label to be printed into the pdf file.

=item setPositionsForX

	C4::Barcodes::PrinterConfig::setPositionsForX($marginLeft, $labelWidth, $columns, $pageType);

Calculate and stores all the X positions across the pdf page.

C<$marginLeft> Indicates how much left margin do you want in your page type.

C<$labelWidth> Indicates the width of the label that you are going to use.

C<$columns> Indicates how many columns do you want in your page type.

C<$pageType> Page type to print (eg: a4, legal, etc).

=cut
#'
sub setPositionsForX {
	my ($marginLeft, $labelWidth, $columns, $pageType) = @_;
	my $defaultDpi = 72/25.4; # By default we know 25.4 mm -> 1 inch -> 72 dots per inch
	my $whereToStart = ($marginLeft + ($labelWidth/2));
	my $firstLabel = $whereToStart*$defaultDpi;
	my $spaceBetweenLabels = $labelWidth*$defaultDpi;
	my @positions;
	for (my $i = 0; $i < $columns ; $i++) {
		push @positions, ($firstLabel+($spaceBetweenLabels*$i));
	}
	@positionsForX = @positions;
}

=item setPositionsForY

	C4::Barcodes::PrinterConfig::setPositionsForY($marginBottom, $labelHeigth, $rows, $pageType);

Calculate and stores all tha Y positions across the pdf page.

C<$marginBottom> Indicates how much bottom margin do you want in your page type.

C<$labelHeigth> Indicates the height of the label that you are going to use.

C<$rows> Indicates how many rows do you want in your page type.

C<$pageType> Page type to print (eg: a4, legal, etc).

=cut
#'
sub setPositionsForY {
	my ($marginBottom, $labelHeigth, $rows, $pageType) = @_;
	my $defaultDpi = 72/25.4; # By default we know 25.4 mm -> 1 inch -> 72 dots per inch
	my $whereToStart = ($marginBottom + ($labelHeigth/2));
	my $firstLabel = $whereToStart*$defaultDpi;
	my $spaceBetweenLabels = $labelHeigth*$defaultDpi;
	my @positions;
	for (my $i = 0; $i < $rows; $i++) {
		unshift @positions, ($firstLabel+($spaceBetweenLabels*$i));
	}
	@positionsForY = @positions;
}

=item getLabelPosition

	(my $x, my $y, $pdfObject, $pageObject, $gfxObject, $textObject, $coreObject, $labelPosition) = 
					C4::Barcodes::PrinterConfig::getLabelPosition($labelPosition, 
																  $pdfObject, 
																  $page,
																  $gfx,
																  $text,
																  $fontObject,
																  $pageType);	

Return the (x,y) position of the label that you are going to print considering the environment.

C<$labelPosition> Indicates which label positions do you want to place by x and y coordinates.

C<$pdfObject> The PDF object in use.

C<$page> The page in use.

C<$gfx> The gfx resource to handle with barcodes objects.

C<$text> The text resource to handle with text.

C<$fontObject> The font object

C<$pageType> Page type to print (eg: a4, legal, etc).

=cut
#'
sub getLabelPosition {
	my ($labelNum, $pdf, $page, $gfxObject, $textObject, $fontObject, $pageType) = @_;
	my $indexX = $labelNum % @positionsForX;
	my $indexY = int($labelNum / @positionsForX);
	# Calculates the next label position and return that label number
	my $nextIndexX = $labelNum % @positionsForX;
	my $nextIndexY = $labelNum % @positionsForY;
	if ($firstLabel) {
          $page = $pdf->page;
          $page->mediabox($pageType);
          $gfxObject = $page->gfx;
          $textObject = $page->text;
          $textObject->font($fontObject, 7);
		  $firstLabel = 0;
	} elsif (($nextIndexX == 0) && ($nextIndexY == 0)) {
          $page = $pdf->page;
          $page->mediabox($pageType);
          $gfxObject = $page->gfx;
          $textObject = $page->text;
          $textObject->font($fontObject, 7);
	}
	$labelNum = $labelNum + 1;	
	if ($labelNum == (@positionsForX*@positionsForY)) {
		$labelNum = 0;
	}
	return ($positionsForX[$indexX], $positionsForY[$indexY], $pdf, $page, $gfxObject, $textObject, $fontObject, $labelNum);
}

=item labelsPage

	my @labelTable = C4::Barcodes::PrinterConfig::labelsPage($rows, $columns);

This function will help you to build the labels panel, where you can choose
wich label position do you want to start the printer process.

C<$rows> Indicates how many rows do you want in your page type.

C<$columns> Indicates how many rows do you want in your page type.

=cut
#'
sub labelsPage{
	my ($rows, $columns) = @_;
	my @pageType;
	my $tagname = 0;
	my $labelname = 1;
	my $check;
	for (my $i = 1; $i <= $rows; $i++) {
		my @column;
		for (my $j = 1; $j <= $columns; $j++) {
			my %cell;
			if ($tagname == 0) {
				$check = 'checked';
			} else {
				$check = '';
			}		
			%cell = (check => $check,
					 tagname => $tagname,
			         labelname => $labelname);
			$tagname = $tagname + 1;	
			$labelname = $labelname + 1;	
			push @column, \%cell;
		}
		my %columns = (columns => \@column);
		push @pageType, \%columns;
	}
	return @pageType;
}

1;

__END__

=back

=head1 AUTHOR

Koha Physics Library UNLP <matias_veleda@hotmail.com>

=cut
