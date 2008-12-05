#!/usr/bin/perl

# $Id: showmarc.pl,v 1.1.2.1 2007/06/18 21:57:23 rangi Exp $


# Koha library project  www.koha.org

# Licensed under the GPL

# Copyright 2007 Liblime
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

# standard or CPAN modules used
use CGI;

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
my $importid	= $input->param('importid');
my $view		= $input->param('viewas');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "opac-showmarc.tmpl",
        query           => $input,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
});

$template->param( SCRIPT_NAME => $ENV{'SCRIPT_NAME'}, );
my ($record, $xmlrecord);
if ($importid) {
	my ($marc,$encoding) = GetImportRecordMarc($importid);
	$record = MARC::Record->new_from_usmarc($marc) ;
 	if($view eq 'card') {
		$xmlrecord = $record->as_xml();
	} 
}
		
if ($view eq 'card') {
$xmlrecord = GetXmlBiblio($biblionumber) unless $xmlrecord;
my $xslfile = C4::Context->config('intranetdir')."/koha-tmpl/intranet-tmpl/prog/en/xslt/compact.xsl";
my $parser = XML::LibXML->new();
my $xslt   = XML::LibXSLT->new();
my $source = $parser->parse_string($xmlrecord);
my $style_doc = $parser->parse_file($xslfile);
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $results = $stylesheet->transform($source);
my $newxmlrecord = $stylesheet->output_string($results);
#warn $newxmlrecord;
print $input->header(), $newxmlrecord;
    exit;
} else {
    $record =GetMarcBiblio($biblionumber) unless $record; 
    $template->param( MARC_FORMATTED => $record->as_formatted );
    output_html_with_http_headers $input, $cookie, $template->output;
}
