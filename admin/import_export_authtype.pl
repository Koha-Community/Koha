#!/usr/bin/perl

# Copyright 2016 Aleisha Amohia <aleisha@catalyst.net.nz>
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
use C4::Auth                  qw/check_cookie_auth/;
use C4::ImportExportFramework qw( ExportFramework ImportFramework createODS );

my %cookies = CGI::Cookie->fetch();
my ( $auth_status, $sessionID );
if ( exists $cookies{'CGISESSID'} ) {
    ( $auth_status, $sessionID ) = check_cookie_auth(
        $cookies{'CGISESSID'}->value,
        { parameters => 'parameters_remaining_permissions' },
    );
}

my $input = CGI->new;

unless ( $auth_status eq 'ok' ) {
    print $input->header( -type => 'text/plain', -status => '403 Forbidden' );
    exit 0;
}

my $authtypecode = $input->param('authtypecode') || 'default';
my $op           = $input->param('op')           || 'export';

## Exporting
if ( $op eq 'export' ) {    # GET operation for downloading
    my $strXml = '';
    my $format = $input->param( 'type_export_' . $authtypecode );
    if ( $authtypecode eq 'default' ) {
        $format = $input->param('type_export_');
        ExportFramework( '', \$strXml, $format, 'authority' );
    } else {
        ExportFramework( $authtypecode, \$strXml, $format, 'authority' );
    }

    if ( $format eq 'csv' ) {

        # CSV file

        # Correctly set the encoding to output plain text in UTF-8
        binmode( STDOUT, ':encoding(UTF-8)' );
        print $input->header( -type => 'application/vnd.ms-excel', -attachment => 'export_' . $authtypecode . '.csv' );
        print $strXml;
    } else {

        # ODS file
        my $strODS = '';
        createODS( $strXml, 'en', \$strODS );
        print $input->header(
            -type       => 'application/vnd.oasis.opendocument.spreadsheet',
            -attachment => 'export_' . $authtypecode . '.ods'
        );
        print $strODS;
    }
} elsif ( $op eq 'cud-import' ) {    # POST for importing
    my $ok        = -1;
    my $fieldname = 'file_import_' . $authtypecode;
    if ( $authtypecode eq 'default' ) {
        $fieldname = 'file_import_';
    }
    my $filename = $input->param($fieldname);

    # upload the input file
    if ( $filename && $filename =~ /\.(csv|ods)$/i ) {
        my $extension = $1;
        my $uploadFd  = $input->upload($fieldname);
        if ( $uploadFd && !$input->cgi_error ) {
            my $tmpfilename = $input->tmpFileName( scalar $input->param($fieldname) );
            $filename = $tmpfilename . '.' . $extension;    # rename the tmp file with the extension
            if ( $authtypecode eq 'default' ) {
                $ok = ImportFramework( $filename, '', 1, 'authority' ) if ( rename( $tmpfilename, $filename ) );
            } else {
                $ok = ImportFramework( $filename, $authtypecode, 1, 'authority' )
                    if ( rename( $tmpfilename, $filename ) );
            }
        }
    }
    if ( $ok >= 0 ) {    # If everything went ok go to the authority type marc structure
        if ( $authtypecode eq 'default' ) {
            print $input->redirect( -location => '/cgi-bin/koha/admin/auth_tag_structure.pl?authtypecode=' );
        } else {
            print $input->redirect(
                -location => '/cgi-bin/koha/admin/auth_tag_structure.pl?authtypecode=' . $authtypecode );
        }
    } else {

        # If something failed go to the list of authority types and show message
        print $input->redirect( -location => '/cgi-bin/koha/admin/authtypes.pl?error_import_export=' . $authtypecode );
    }
}
