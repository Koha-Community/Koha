#!/usr/bin/perl

# Copyright 2010-2011 MASmedios.com y Ministerio de Cultura
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
use CGI qw ( -utf8 );
use CGI::Cookie;
use C4::Context;
use C4::Auth                  qw( check_cookie_auth );
use C4::ImportExportFramework qw( createODS ExportFramework ImportFramework );

my %cookies = CGI::Cookie->fetch();
my ($auth_status);
if ( exists $cookies{'CGISESSID'} ) {
    ( $auth_status, undef ) = check_cookie_auth(
        $cookies{'CGISESSID'}->value,
        { parameters => 'manage_marc_frameworks' },
    );
}

my $input = CGI->new;

unless ( $auth_status eq 'ok' ) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit 0;
}

my $frameworkcode = $input->param('frameworkcode') || 'default';
my $op            = $input->param('op')            || 'export';

## Exporting
if ( $op eq 'export' ) {
    my $strXml = '';
    my $format = $input->param( 'type_export_' . $frameworkcode );
    if ( $frameworkcode eq 'default' ) {
        ExportFramework( '', \$strXml, $format, 'biblio' );
    } else {
        ExportFramework( $frameworkcode, \$strXml, $format, 'biblio' );
    }

    if ( $format eq 'csv' ) {

        # CSV file

        # Correctly set the encoding to output plain text in UTF-8
        binmode( STDOUT, ':encoding(UTF-8)' );
        print $input->header( -type => 'application/vnd.ms-excel', -attachment => 'export_' . $frameworkcode . '.csv' );
        print $strXml;
    } else {

        # ODS file
        my $strODS = '';
        createODS( $strXml, 'en', \$strODS );
        print $input->header(
            -type       => 'application/vnd.oasis.opendocument.spreadsheet',
            -attachment => 'export_' . $frameworkcode . '.ods'
        );
        print $strODS;
    }
## Importing
} elsif ( $op eq 'cud-import' ) {
    my $ok        = -1;
    my $fieldname = 'file_import_' . $frameworkcode;
    my $filename  = $input->param($fieldname);

    # upload the input file
    if ( $filename && $filename =~ /\.(csv|ods)$/i ) {
        my $extension = $1;
        my $uploadFd  = $input->upload($fieldname);
        if ( $uploadFd && !$input->cgi_error ) {
            my $tmpfilename = $input->tmpFileName( scalar $input->param($fieldname) );
            $filename      = $tmpfilename . '.' . $extension;    # rename the tmp file with the extension
            $frameworkcode = ''                                             if $frameworkcode eq 'default';
            $ok = ImportFramework( $filename, $frameworkcode, 1, 'biblio' ) if ( rename( $tmpfilename, $filename ) );
        }
    }
    if ( $ok >= 0 ) {    # If everything went ok go to the framework marc structure
        print $input->redirect(
            -location => '/cgi-bin/koha/admin/marctagstructure.pl?frameworkcode=' . $frameworkcode );
    } else {

        # If something failed go to the list of frameworks and show message
        print $input->redirect(
            -location => '/cgi-bin/koha/admin/biblio_framework.pl?error_import_export=' . $frameworkcode );
    }
}
