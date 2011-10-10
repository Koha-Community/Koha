#!/usr/bin/perl

# Koha library project  www.koha-community.org

# Licensed under the GPL

# Copyright 2007 Liblime
# Parts copyright 2010 BibLibre
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
#use warnings; FIXME - Bug 2505

use open OUT=>':utf8', ':std';

# standard or CPAN modules used
use CGI qw(:standard);
use DBI;
use Encode;

# Koha modules used
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Biblio;
use C4::ImportBatch;
use XML::LibXSLT;
use XML::LibXML;

my $input       = new CGI;
my $biblionumber = $input->param('id');
my $importid		=	$input->param('importid');
my $view		= $input->param('viewas');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/showmarc.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1  },
        debug           => 1,
    }
);

$template->param( SCRIPT_NAME => $ENV{'SCRIPT_NAME'}, );
my ($record, $xmlrecord);
if($importid) {
	my ($marc,$encoding) = GetImportRecordMarc($importid);
		$record = MARC::Record->new_from_usmarc($marc) ;
 	if($view eq 'card') {
		$xmlrecord = $record->as_xml();
	} 
}
		
if($view eq 'card') {
$xmlrecord = GetXmlBiblio($biblionumber) unless $xmlrecord;

my $xslfile = C4::Context->config('intrahtdocs')."/prog/en/xslt/compact.xsl";
my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();
my $source = $parser->parse_string($xmlrecord);
my $style_doc = $parser->parse_file($xslfile);
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $results = $stylesheet->transform($source);
my $newxmlrecord = $stylesheet->output_string($results);
$newxmlrecord=Encode::decode_utf8($newxmlrecord) unless utf8::is_utf8($newxmlrecord); #decode only if not in perl internal format
print $input->header(-charset => 'UTF-8'), $newxmlrecord;

} else {

$record =GetMarcBiblio($biblionumber) unless $record; 

my $formatted = $record->as_formatted;
$template->param( MARC_FORMATTED => $formatted );

my $output= $template->output;
$output=Encode::decode_utf8($output) unless utf8::is_utf8($output);
output_html_with_http_headers $input, $cookie, $output;
}
