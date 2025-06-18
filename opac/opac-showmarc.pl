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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

# standard or CPAN modules used
use CGI qw ( -utf8 );
use Encode;

# Koha modules used
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use C4::ImportBatch;
use C4::XSLT;
use C4::Templates;
use Koha::RecordProcessor;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-showmarc.tt",
        query           => $input,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $biblionumber = $input->param('id');

unless ($biblionumber) {
    print $input->redirect("/cgi-bin/koha/errors/400.pl");
    exit;
}

my $biblio;
$biblio = Koha::Biblios->find( $biblionumber, { prefetch => ['metadata'] } );

unless ($biblio) {
    print $input->redirect('/cgi-bin/koha/errors/404.pl');
    exit;
}

my $view = $input->param('viewas') || 'marc';

my $record_processor = Koha::RecordProcessor->new(
    {
        filters => 'ViewPolicy',
        options => {
            interface     => 'opac',
            frameworkcode => $biblio->frameworkcode
        }
    }
);

my $record = $biblio->metadata->record;

if ( !ref $record ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

$record_processor->process($record);

if ( $view eq 'card' || $view eq 'html' ) {
    my $xml    = $record->as_xml;
    my $xsl    = $view eq 'card' ? 'compact.xsl' : 'plainMARC.xsl';
    my $htdocs = C4::Context->config('opachtdocs');
    my ( $theme, $lang ) = C4::Templates::themelanguage( $htdocs, $xsl, 'opac', $input );
    $xsl = "$htdocs/$theme/$lang/xslt/$xsl";
    output_html_with_http_headers $input, undef, Encode::encode_utf8( C4::XSLT::engine->transform( $xml, $xsl ) );
} else {    #view eq marc
    $template->param( MARC_FORMATTED => $record->as_formatted );
    output_html_with_http_headers $input, $cookie, $template->output;
}
