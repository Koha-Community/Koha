#!/usr/bin/perl

# script to generate items barcodes
# written 07/04
# by Veleda Matias - matias_veleda@hotmail.com - Physics Library UNLP Argentina and
#    Castañeda Sebastian - seba3c@yahoo.com.ar - Physics Library UNLP Argentina and

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

require Exporter;

use strict;

use CGI;
use C4::Context;
use C4::Output;
use HTML::Template;
use PDF::API2;
use PDF::API2::Page;
use PDF::API2::PDF::Utils;
use C4::Barcodes::PrinterConfig;
use Time::localtime; 


# This function returns the path to deal with the correct files, considering
# templates set and language.
sub getPath {
	my $type = shift @_;
	my $templatesSet = C4::Context->preference('template');
	my $lang = C4::Context->preference('opaclanguages');
	if ($type eq "intranet") {
		return "$ENV{'DOCUMENT_ROOT'}/intranet-tmpl/$templatesSet/$lang";
	} else {
		return "$ENV{'DOCUMENT_ROOT'}/opac-tmpl/$templatesSet/$lang";
	}
}

# Load a configuration file. Before use this function, check if that file exists.
sub loadConfFromFile {
  my $fileName = shift @_;
	my %keyValues;
	open FILE, "<$fileName";
	while (<FILE>) {
		chomp;
		if (/\s*([\w_]*)\s*=\s*([\[\]\<\>\w_\s:@,\.-]*)\s*/) {
			$keyValues{$1} = $2;
		}
	}
	close FILE;
	return %keyValues;
}

# Save settings to a configuration file. It delete previous configuration settings.
sub saveConfToFile {
	my $fileName = shift @_;
	my %keyValues = %{shift @_};
	my $i;
	open FILE, ">$fileName";			
	my $i;
	foreach $i (keys(%keyValues)) {
    print FILE $i." = ".$keyValues{$i}."\n";
	}
	close FILE;
}

# Load the config file.
my $filenameConf = &getPath("intranet")."/includes/labelConfig/itemsLabelConfig.conf";
my %labelConfig = &loadConfFromFile($filenameConf);

# Creates a CGI object and take its parameters
my $cgi = new CGI;
my $from = $cgi->param('from');
my $to = $cgi->param('to');
my $individualCodes = $cgi->param('individualCodes');
my $rangeType = $cgi->param('rangeType');
my $pageType = $cgi->param('pages');
my $label = $cgi->param('label');
my $numbersystem = $cgi->param('numbersystem');
my $text_under_label = $cgi->param('text_under_label');

# Generate the checksum from an inventary code
sub checksum {

  sub calculateDigit {
    my $code = shift @_;
    my $sum = 0;
	  my $odd_parity = 1;
    my $i;
    for ($i = length($code) - 1; $i >= 0; $i--){
	   if ( $odd_parity ) {
		  $sum = $sum + ( 3 * substr($code, $i, 1) );
     } else {
			$sum = $sum + substr($code, $i, 1); }
		  $odd_parity = !$odd_parity;
	   }
    my $check_digit = 10 - ($sum%10);
	if ($check_digit==10) {
		$check_digit=0;
	}
	  return $code.$check_digit;
  }

  my $currentCode = shift @_;
  $currentCode = &calculateDigit($currentCode);
  return $currentCode;
}

# Assigns a temporary name to the PDF file
sub assingFilename {
	my ($from, $to) = @_;
	my $ip = $cgi->remote_addr();
	my $random = int(rand(1000000));
    my $timeObj = localtime();
	my ($day, $month, $year, $hour, $min, $sec) = ($timeObj->mday,
												   $timeObj->mon + 1,
												   $timeObj->year + 1900,
  												   $timeObj->hour,
												   $timeObj->min,
												   $timeObj->sec);
	my $tmpFileName = $random.'-'.$ip.'-(From '.$from.' to '.$to.')-['.$day.'.'.$month.'.'.$year.']-['.$hour.':'.$min.':'.$sec.'].pdf';
	return $tmpFileName;
}

# Takes inventary codes from database and if they are between
# the interval specify by parameters, it generates the correspond barcodes
sub barcodesGenerator {
	my ($from, $to, $rangeType, $individualCodes,$text_under_label) = @_;
	# Returns a database handler
	my $dbh = C4::Context->dbh;
	# Create the query to database
	# Assigns a temporary filename for the pdf file
	my $tmpFileName = &assingFilename($from, $to);
	if ($rangeType eq 'continuous2') {
		# Set the temp directory for pdf´s files
		if (!defined($ENV{'TEMP'})) {
			$ENV{'TEMP'} = '/tmp/';
		}	
		$tmpFileName = $ENV{'TEMP'}.$tmpFileName;
		# Creates a PDF object
		my $pdf = PDF::API2->new(-file => $tmpFileName);
		# Set the positions where barcodes are going to be placed
		C4::Barcodes::PrinterConfig::setPositionsForX($labelConfig{'marginLeft'}, $labelConfig{'labelWidth'}, $labelConfig{'columns'}, $labelConfig{'pageType'});
		C4::Barcodes::PrinterConfig::setPositionsForY($labelConfig{'marginBottom'}, $labelConfig{'labelHeigth'}, $labelConfig{'rows'}, $labelConfig{'pageType'});
		# Creates a font object
		my $tr = $pdf->corefont('Helvetica-Bold');
		# Barcode position
		my ($page, $gfx, $text);
		for (my $code=$from; $code<=$to; $code++) {
			# Generetase checksum
			my $codeC = &checksum($code);
			# Generate the corresponde barcode to $code
			my $barcode = $pdf->barcode(-font => $tr,	# The font object to use
										-type => 'ean13',	# Standard of codification
										-code => $codeC, # Text to codify
										-extn	=> '012345',	# Barcode extension (if it is aplicable)
										-umzn => 10,		# Top limit of the finished bar
										-lmzn => 10,		# Bottom limit of the finished bar
										-zone => 15,		# Bars size
										-quzn => 0,		# Space destinated for legend
										-ofwt => 0.01,	# Bars width
										-fnsz => 8,		# Font size
										-text => ''
										);
			
			(my $x, my $y, $pdf, $page, $gfx, $text, $tr, $label) = C4::Barcodes::PrinterConfig::getLabelPosition(
																						$label, 
																						$pdf, 
																						$page,
																						$gfx,
																						$text,
																						$tr,
																						$pageType);	
			# Assigns a barcodes to $gfx
			$gfx->barcode($barcode, $x, $y , (72/$labelConfig{'systemDpi'}));
			# Assigns the additional information to the barcode (Legend)
			$text->translate($x - 48, $y - 22);
			if ($text_under_label) {
				$text->text($text_under_label);
			}
		}
		# Writes the objects added in $gfx to $page
		$pdf->finishobjects($page,$gfx, $text);
		# Save changes to the PDF
		$pdf->saveas;
		# Close the conection with the PDF file
		$pdf->end;
		# Show the PDF file
		print $cgi->redirect("/cgi-bin/koha/barcodes/pdfViewer.pl?tmpFileName=$tmpFileName");
	} else {
		my $rangeCondition;
		if ($individualCodes ne "") {
			$rangeCondition = "AND (I.barcode IN " . $individualCodes . ")";
		} else {
			$rangeCondition =  "AND (I.barcode >= " . $from . " AND I.barcode <="  . $to . " )";
		}
			
		my $query = "SELECT CONCAT('$numbersystem',REPEAT('0',((12 - LENGTH('$numbersystem')) - LENGTH(I.barcode))), I.barcode) AS Codigo, B.title, B.author FROM biblio B, items I WHERE (I.biblionumber = B.biblioNumber ) " .$rangeCondition. " AND (I.barcode <> 'FALTA') ORDER BY Codigo";
		
		# Prepare the query
		my $sth = $dbh->prepare($query);
		# Executes the query
		$sth->execute;
		if ($sth->rows) { # There are inventary codes
			# Set the temp directory for pdf´s files
			if (!defined($ENV{'TEMP'})) {
				$ENV{'TEMP'} = '/tmp/';
			}	
			# Assigns a temporary filename for the pdf file
			my $tmpFileName = &assingFilename($from, $to);
			$tmpFileName = $ENV{'TEMP'}.$tmpFileName;
			# Creates a PDF object
			my $pdf = PDF::API2->new(-file => $tmpFileName);
			# Set the positions where barcodes are going to be placed
			C4::Barcodes::PrinterConfig::setPositionsForX($labelConfig{'marginLeft'}, $labelConfig{'labelWidth'}, $labelConfig{'columns'}, $labelConfig{'pageType'});
			C4::Barcodes::PrinterConfig::setPositionsForY($labelConfig{'marginBottom'}, $labelConfig{'labelHeigth'}, $labelConfig{'rows'}, $labelConfig{'pageType'});
			# Creates a font object
			my $tr = $pdf->corefont('Helvetica-Bold');
			# Barcode position
			my ($page, $gfx, $text);
			while (my ($code,$title,$author) = $sth->fetchrow_array) {
				# Generetase checksum
				$code = &checksum($code);
				# Generate the corresponde barcode to $code
				my $barcode = $pdf->barcode(-font => $tr,	# The font object to use
											-type => 'ean13',	# Standard of codification
											-code => $code, # Text to codify
											-extn	=> '012345',	# Barcode extension (if it is aplicable)
											-umzn => 10,		# Top limit of the finished bar
											-lmzn => 10,		# Bottom limit of the finished bar
											-zone => 15,		# Bars size
											-quzn => 0,		# Space destinated for legend
											-ofwt => 0.01,	# Bars width
											-fnsz => 8,		# Font size
											-text => ''
											);
				
				(my $x, my $y, $pdf, $page, $gfx, $text, $tr, $label) = C4::Barcodes::PrinterConfig::getLabelPosition(
																							$label, 
																							$pdf, 
																							$page,
																							$gfx,
																							$text,
																							$tr,
																							$pageType);	
				# Assigns a barcodes to $gfx
				$gfx->barcode($barcode, $x, $y , (72/$labelConfig{'systemDpi'}));
				# Assigns the additional information to the barcode (Legend)
				$text->translate($x - 48, $y - 22);
				if ($text_under_label) {
					$text->text($text_under_label);
				} else {
					$text->text(substr $title, 0, 30);
					$text->translate($x - 48, $y - 29);
					$text->text(substr $author, 0, 30);
				}
			}
			# Writes the objects added in $gfx to $page
			$pdf->finishobjects($page,$gfx, $text);
			# Save changes to the PDF
			$pdf->saveas;
			# Close the conection with the PDF file
			$pdf->end;
			# Show the PDF file
			print $cgi->redirect("/cgi-bin/koha/barcodes/pdfViewer.pl?tmpFileName=$tmpFileName");
		} else {
			# Rollback and shows the error legend
			print $cgi->redirect("/cgi-bin/koha/barcodes/barcodes.pl?error=1");
		}
	$sth->finish;
	}
}

barcodesGenerator($from, $to, $rangeType, $individualCodes,$text_under_label);