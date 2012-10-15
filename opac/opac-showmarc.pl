#!/usr/bin/perl

# $Id: showmarc.pl,v 1.1.2.1 2007/06/18 21:57:23 rangi Exp $


# Koha library project  www.koha-community.org

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use open OUT=> ":encoding(UTF-8)", ':std';

# standard or CPAN modules used
use CGI;
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
$biblionumber   = int($biblionumber);
my $importid	= $input->param('importid');
my $view		= $input->param('viewas') || 'marc';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "opac-showmarc.tmpl",
        query           => $input,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
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

if ($view eq 'card' || $view eq 'html') {
    $xmlrecord = GetXmlBiblio($biblionumber) unless $xmlrecord;
    my $xslfile;
    my $themelang = '/' . C4::Context->preference("opacthemes") .  '/' . C4::Templates::_current_language();

    if ($view eq 'card'){
        $xslfile = C4::Context->config('opachtdocs').$themelang."/xslt/compact.xsl";
    }
    else { # must be html
        $xslfile = C4::Context->config('opachtdocs').$themelang."/xslt/MARC21slim2OPACMARCdetail.xsl";
    }
    my $parser = XML::LibXML->new();
    my $xslt   = XML::LibXSLT->new();
    my $source = $parser->parse_string($xmlrecord);
    my $style_doc = $parser->parse_file($xslfile);
    my $stylesheet = $xslt->parse_stylesheet($style_doc);
    my $results = $stylesheet->transform($source);
    my $newxmlrecord = $stylesheet->output_string($results);
    $newxmlrecord = Encode::decode_utf8($newxmlrecord) unless utf8::is_utf8($newxmlrecord);
    print $input->header(-charset => 'UTF-8'), $newxmlrecord;
} else {
    $record =GetMarcBiblio($biblionumber) unless $record; 
    $template->param( MARC_FORMATTED => $record->as_formatted );
    output_html_with_http_headers $input, $cookie, $template->output;
}
