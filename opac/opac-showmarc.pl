#!/usr/bin/perl

# Copyright 2007 Liblime
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

use strict;
use warnings;

# standard or CPAN modules used
use CGI;
use Encode;

# Koha modules used
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Biblio;
use C4::ImportBatch;
use C4::XSLT ();

my $input       = new CGI;
my $biblionumber = $input->param('id');
$biblionumber   = int($biblionumber);
my $importid= $input->param('importid');
my $view= $input->param('viewas') || 'marc';

my $record;
if ($importid) {
    my ($marc) = GetImportRecordMarc($importid);
    $record = MARC::Record->new_from_usmarc($marc);
}
else {
    $record =GetMarcBiblio($biblionumber);
}
if(!ref $record) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if ($view eq 'card' || $view eq 'html') {
    my $xmlrecord= $importid? $record->as_xml(): GetXmlBiblio($biblionumber);
    my $xslfile;
    my $xslfilename;
    my $htdocs  = C4::Context->config('opachtdocs');
    my $theme   = C4::Context->preference("opacthemes");
    my $lang = C4::Templates::_current_language();

    if ($view eq 'card'){
        $xslfile = "compact.xsl";
    }
    else { # must be html
        $xslfile = 'plainMARC.xsl';
    }
    $xslfilename = "$htdocs/$theme/$lang/xslt/$xslfile";
    $xslfilename = "$htdocs/$theme/en/xslt/$xslfile" unless ( $lang ne 'en' && -f $xslfilename );
    $xslfilename = "$htdocs/prog/$lang/xslt/$xslfile" unless ( -f $xslfile );
    $xslfilename = "$htdocs/prog/en/xslt/$xslfile" unless ( $lang ne 'en' && -f $xslfilename );

    my $newxmlrecord = C4::XSLT::engine->transform($xmlrecord, $xslfilename);
    print $input->header(-charset => 'UTF-8'), Encode::encode_utf8($newxmlrecord);
}
else { #view eq marc
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "opac-showmarc.tmpl",
        query           => $input,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        debug           => 1,
    });
    $template->param( MARC_FORMATTED => $record->as_formatted );
    output_html_with_http_headers $input, $cookie, $template->output;
}
