#!/usr/bin/perl

# script to set the labels configuration for the printer process.
# written 07/04
# by Veleda Matias - matias_veleda@hotmail.com - Physics Library UNLP Argentina and

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
use C4::Auth;
use HTML::Template;
use PDF::API2;
use PDF::API2::Page;
use PDF::API2::PDF::Utils;
use C4::Interface::CGI::Output;

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

# Load a configuration file.
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

# Save settings to a configuration file.
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

# Creates a CGI object and take his parameters
my $input = new CGI;

if ($input->param('saveSettings')) {
	my $labelConf = &getPath("intranet")."/includes/labelConfig/itemsLabelConfig.conf";
	my %newConfiguration = (pageType => $input->param('pageType'), 	
							columns => $input->param('columns'), 		
							rows => $input->param('rows'), 	
							systemDpi => $input->param('systemDpi'), 	
							labelWidth => $input->param('labelWidth'), 	
							labelHeigth => $input->param('labelHeigth'),	
							marginBottom => $input->param('marginBottom'), 	
							marginLeft => $input->param('marginLeft')); 	
	saveConfToFile($labelConf, \%newConfiguration);
	print $input->redirect('/cgi-bin/koha/barcodes/barcodes.pl')
}

# Get the template to use
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "barcodes/printerConfig.tmpl",
			                 type => "intranet",
			                 query => $input,
			                 authnotrequired => 0,
			                 flagsrequired => {parameters => 1},
					         debug => 1,
			               });

my $filenameConf = &getPath("intranet")."/includes/labelConfig/itemsLabelConfig.conf";
my %labelConfig = &loadConfFromFile($filenameConf);

$template->param(COLUMNS => $labelConfig{'columns'});
$template->param(ROWS => $labelConfig{'rows'});
$template->param(SYSTEM_DPI => $labelConfig{'systemDpi'});
$template->param(LABEL_WIDTH => $labelConfig{'labelWidth'});
$template->param(LABEL_HEIGTH => $labelConfig{'labelHeigth'});
$template->param(MARGIN_TOP => $labelConfig{'marginBottom'});
$template->param(MARGIN_LEFT => $labelConfig{'marginLeft'});
$template->param(SCRIPT_NAME => '/cgi-bin/koha/barcodes/printerConfig.pl');
$template->param("$labelConfig{'pageType'}" => 1);
output_html_with_http_headers $input, $cookie, $template->output;