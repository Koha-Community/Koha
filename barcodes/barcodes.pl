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

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Context;
use C4::Barcodes::PrinterConfig;



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

my $input = new CGI;
# Defines type of page to use in the printer process
my @labelTable = C4::Barcodes::PrinterConfig::labelsPage($labelConfig{'rows'}, $labelConfig{'columns'});

# It creates a list of posible intervals to choose codes to generate
my %list = ('continuous' => 'Continuous Range', 'individuals' => 'Individual Codes');
my @listValues = keys(%list);
my $rangeType = CGI::scrolling_list(-name => 'rangeType',
                              		-values => \@listValues,
			                        -labels => \%list,
			                        -size => 1,
									-default => ['continuous'],
			                        -multiple => 0,
									-id => "rangeType",
									-onChange => "changeRange(this)");
# It creates a list of posible standard codifications. First checks if the user has just added a new code.
if ($input->param('addCode')) {
	my $newCountryName = $input->param('countryName');
	my $newCountryCode = $input->param('countryCode'); 

	my $countryCodesFilename = &getPath("intranet")."/includes/countryCodes/countryCodes.dat";
	open COUNTRY_CODES, ">>$countryCodesFilename";			
    print COUNTRY_CODES $newCountryCode." = ".$newCountryName."\n";
	close COUNTRY_CODES;
}

# Takes the country codes from a file and use them to set the country list.
my $countryCodes = &getPath("intranet")."/includes/countryCodes/countryCodes.dat";
my %list = &loadConfFromFile($countryCodes);
@listValues = keys(%list);
my $number_system = CGI::scrolling_list(-name => 'numbersystem',
                              		    -values => \@listValues,
			                            -labels   => \%list,
			                            -size     => 1,
			                            -multiple => 0);

# Set the script name
my $script_name = "/cgi-bin/koha/barcodes/barcodesGenerator.pl";


# Get the template to use
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "barcodes/barcodes.tmpl",
			                 type => "intranet",
			                 query => $input,
			                 authnotrequired => 0,
			                 flagsrequired => {parameters => 1},
					         debug => 1,
			               });

# Replace the template values with the real ones
$template->param(SCRIPT_NAME => $script_name);
$template->param(NUMBER_SYSTEM => $number_system);
$template->param(PAGES => $labelConfig{'pageType'});
$template->param(RANGE_TYPE => $rangeType);
$template->param(LABEL_TABLE => \@labelTable);
$template->param(COL_SPAN => $labelConfig{'columns'});
if ($input->param('error')) {
	$template->param(ERROR => 1);
} else {
	$template->param(ERROR => 0);
}
# Shows the template with the real values replaced
output_html_with_http_headers $input, $cookie, $template->output;