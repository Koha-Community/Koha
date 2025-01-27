#!/usr/bin/perl

# Koha library project  www.koha-community.org

# Copyright 2011 Libéo
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
use CGI qw(:standard -utf8);

# Koha modules used
use C4::Context;
use C4::Output          qw( output_html_with_http_headers );
use C4::Auth            qw( get_template_and_user );
use C4::Auth            qw( get_template_and_user );
use C4::ImportBatch     qw( GetImportBiblios );
use C4::AuthoritiesMarc qw( GetAuthority );

use Koha::Biblios;
use Koha::Import::Records;

# Input params
my $input    = CGI->new;
my $recordid = $input->param('id');
my $importid = $input->param('importid');
my $batchid  = $input->param('batchid');
my $type     = $input->param('type');

if ( not $recordid or not $importid ) {
    print $input->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

# Init vars
my (
    $record, $recordImportid, $recordTitle, $importTitle, $formatted1, $formatted2, $errorFormatted1,
    $errorFormatted2
);

# Prepare template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/showdiffmarc.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'manage_staged_marc' },
    }
);

if ( $type eq 'biblio' ) {
    my $biblio = Koha::Biblios->find($recordid);
    $record      = $biblio->metadata_record( { embed_items => 1 } );
    $recordTitle = $biblio->title;
} elsif ( $type eq 'auth' ) {
    $record      = GetAuthority($recordid);
    $recordTitle = "Authority number " . $recordid;    #FIXME we should get the main heading
}
if ($record) {
    $formatted1 = $record->as_formatted;
} else {
    $errorFormatted1 = 1;
}

if ($importid) {
    my $import_record  = Koha::Import::Records->find($importid);
    my $recordImportid = $import_record->get_marc_record();
    $formatted2 = $recordImportid->as_formatted;
    my $biblio = GetImportBiblios($importid);
    $importTitle = $biblio->[0]->{'title'};
} else {
    $errorFormatted2 = 1;
}

$template->param(
    RECORDID         => $recordid,
    IMPORTID         => $importid,
    RECORDTITLE      => $recordTitle,
    IMPORTTITLE      => $importTitle,
    MARC_FORMATTED1  => $formatted1,
    MARC_FORMATTED2  => $formatted2,
    ERROR_FORMATTED1 => $errorFormatted1,
    ERROR_FORMATTED2 => $errorFormatted2,
    batchid          => $batchid
);

output_html_with_http_headers $input, $cookie, $template->output;
