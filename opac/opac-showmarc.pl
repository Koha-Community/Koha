#!/usr/bin/perl

# Copyright 2007 Liblime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

# standard or CPAN modules used
use CGI qw ( -utf8 );
use Encode;

# Koha modules used
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Biblio;
use C4::ImportBatch;
use C4::XSLT ();
use C4::Templates;
use Koha::RecordProcessor;

my $input       = new CGI;
my $biblionumber = $input->param('id');
$biblionumber   = int($biblionumber);
my $importid= $input->param('importid');
my $view= $input->param('viewas') || 'marc';

my $record_unfiltered;
if ($importid) {
    my ($marc) = GetImportRecordMarc($importid);
    $record_unfiltered = MARC::Record->new_from_usmarc($marc);
}
else {
    $record_unfiltered = GetMarcBiblio($biblionumber);
}
if(!ref $record_unfiltered) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my $record_processor = Koha::RecordProcessor->new({ filters => 'ViewPolicy' });
my $record_filtered  = $record_unfiltered->clone();
my $record           = $record_processor->process($record_filtered);

if ($view eq 'card' || $view eq 'html') {
    # FIXME: GetXmlBiblio needs filtering later.
    my $xml = $importid ? $record->as_xml(): GetXmlBiblio($biblionumber);
    if (!$importid && $view eq 'html') {
        my $unfiltered_record = MARC::Record->new_from_xml($xml);
        my $frameworkcode = GetFrameworkCode($biblionumber);
        $record_processor->options({ frameworkcode => $frameworkcode});
        my $filtered_record = $record_processor->process($unfiltered_record);
        $xml = $filtered_record->as_xml();
    }
    my $xsl =  $view eq 'card' ? 'compact.xsl' : 'plainMARC.xsl';
    my $htdocs = C4::Context->config('opachtdocs');
    my ($theme, $lang) = C4::Templates::themelanguage($htdocs, $xsl, 'opac', $input);
    $xsl = "$htdocs/$theme/$lang/xslt/$xsl";
    print $input->header(-charset => 'UTF-8'),
          Encode::encode_utf8(C4::XSLT::engine->transform($xml, $xsl));
}
else { #view eq marc
    my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "opac-showmarc.tt",
        query           => $input,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
        debug           => 1,
    });
    $template->param( MARC_FORMATTED => $record->as_formatted );
    output_html_with_http_headers $input, $cookie, $template->output;
}
