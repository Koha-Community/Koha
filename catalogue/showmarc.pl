#!/usr/bin/perl

# Koha library project  www.koha-community.org

# Copyright 2007 Liblime
# Parts copyright 2010 BibLibre
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

# standard or CPAN modules used
use CGI qw(:standard -utf8);
use Encode;

# Koha modules used
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use C4::Biblio qw( GetXmlBiblio );
use C4::XSLT;

use Koha::Biblios;
use Koha::Import::Records;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/showmarc.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $biblionumber = $input->param('id');
my $importid     = $input->param('importid');
my $view         = $input->param('viewas') || '';

my $marcflavour = C4::Context->preference('marcflavour');

my $record;
my $record_type = 'biblio';
my $format      = $marcflavour eq 'UNIMARC' ? 'UNIMARC' : 'USMARC';
if ($importid) {
    my $import_record = Koha::Import::Records->find($importid);
    if ($import_record) {
        if ( $marcflavour eq 'UNIMARC' && $import_record->record_type eq 'auth' ) {
            $format = 'UNIMARCAUTH';
        }

        $record = $import_record->get_marc_record();
    }
} else {
    my $biblio = Koha::Biblios->find($biblionumber);
    $record = $biblio->metadata->record;
}
if ( !ref $record ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

if ( $view eq 'card' || $view eq 'html' ) {
    my $xml = $importid ? $record->as_xml($format) : GetXmlBiblio($biblionumber);
    my $xsl;
    if ( $view eq 'card' ) {
        $xsl = $marcflavour eq 'UNIMARC' ? 'UNIMARC_compact.xsl' : 'compact.xsl';
    } else {
        $xsl = 'plainMARC.xsl';
    }
    my $htdocs = C4::Context->config('intrahtdocs');
    my ( $theme, $lang ) = C4::Templates::themelanguage( $htdocs, $xsl, 'intranet', $input );
    $xsl = "$htdocs/$theme/$lang/xslt/$xsl";
    print $input->header( -charset => 'UTF-8' ),
        Encode::encode_utf8( C4::XSLT::engine->transform( $xml, $xsl ) );
} else {
    $template->param( MARC_FORMATTED => $record->as_formatted );
    output_html_with_http_headers $input, $cookie, $template->output;
}
