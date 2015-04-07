#!/usr/bin/perl

# Koha library project  www.koha-community.org

# Copyright 2011 Libéo
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

use Modern::Perl;

# standard or CPAN modules used
use CGI qw(:standard);
use DBI;

# Koha modules used
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Biblio;
use C4::ImportBatch;
use XML::LibXSLT;
use XML::LibXML;


# Input params
my $input        = new CGI;
my $biblionumber = $input->param('id');
my $importid     = $input->param('importid');
my $batchid      = $input->param('batchid');


if ( not $biblionumber or not $importid ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

# Init vars
my ($recordBiblionumber, $recordImportid, $biblioTitle, $importTitle, $formatted1, $formatted2,
    $errorFormatted1, $errorFormatted2);


# Prepare template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/showdiffmarc.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'manage_staged_marc' },
        debug           => 1,
    }
);


$recordBiblionumber = GetMarcBiblio($biblionumber, 'embed_items');
if( $recordBiblionumber ) {
    $formatted1 = $recordBiblionumber->as_formatted;
    my $data = GetBiblioData($biblionumber);
    $biblioTitle = $data->{title};
} else {
    $errorFormatted1 = 1;
}

if( $importid ) {
    $recordImportid = C4::ImportBatch::GetRecordFromImportBiblio( $importid, 'embed_items' );
    $formatted2 = $recordImportid->as_formatted;
    my $biblio = GetImportBiblios($importid);
    $importTitle = $biblio->[0]->{'title'};
} else {
    $errorFormatted2 = 1;
}


$template->param(
    SCRIPT_NAME      => $ENV{'SCRIPT_NAME'},
    BIBLIONUMBER     => $biblionumber,
    IMPORTID         => $importid,
    BIBLIOTITLE      => $biblioTitle,
    IMPORTTITLE      => $importTitle,
    MARC_FORMATTED1  => $formatted1,
    MARC_FORMATTED2  => $formatted2,
    ERROR_FORMATTED1 => $errorFormatted1,
    ERROR_FORMATTED2 => $errorFormatted2,
    batchid          => $batchid
);

output_html_with_http_headers $input, $cookie, $template->output;
