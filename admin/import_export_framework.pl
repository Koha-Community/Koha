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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
use warnings;
use CGI;
use CGI::Cookie;
use C4::Context;
use C4::Auth qw/check_cookie_auth/;
use C4::ImportExportFramework;

my %cookies = CGI::Cookie->fetch();
my $authenticated = 0;
my ($auth_status, $sessionID);
if (exists $cookies{'CGISESSID'}) {
    ($auth_status, $sessionID) = check_cookie_auth(
        $cookies{'CGISESSID'}->value,
        { parameters => 'parameters_remaining_permissions' },
    );
}
if ($auth_status eq 'ok') {
    $authenticated = 1;
}

my $input = new CGI;

unless ($authenticated) {
    print $input->header(-type => 'text/plain', -status => '403 Forbidden');
    exit 0;
}

my $frameworkcode = $input->param('frameworkcode') || '';
my $action = $input->param('action') || 'export';

## Exporting
if ($action eq 'export' && $input->request_method() eq 'GET') {
    my $strXml = '';
    my $format = $input->param('type_export_' . $frameworkcode);
    ExportFramework($frameworkcode, \$strXml, $format);

    if ($format eq 'csv') {
        # CSV file

        # Correctly set the encoding to output plain text in UTF-8
        binmode(STDOUT,':encoding(UTF-8)');
        print $input->header(-type => 'application/vnd.ms-excel', -attachment => 'export_' . $frameworkcode . '.csv');
        print $strXml;
    } elsif ($format eq 'excel') {
        # Excel-xml file
        print $input->header(-type => 'application/excel', -attachment => 'export_' . $frameworkcode . '.xml');
        print $strXml;
    } else {
        # ODS file
        my $strODS = '';
        createODS($strXml, 'en', \$strODS);
        print $input->header(-type => 'application/vnd.oasis.opendocument.spreadsheet', -attachment => 'export_' . $frameworkcode . '.ods');
        print $strODS;
    }
## Importing
} elsif ($input->request_method() eq 'POST') {
    my $ok = -1;
    my $fieldname = 'file_import_' . $frameworkcode;
    my $filename = $input->param($fieldname);
    # upload the input file
    if ($filename && $filename =~ /\.(csv|ods|xml)$/i) {
        my $extension = $1;
        my $uploadFd = $input->upload($fieldname);
        if ($uploadFd && !$input->cgi_error) {
            my $tmpfilename = $input->tmpFileName($input->param($fieldname));
            $filename = $tmpfilename . '.' . $extension; # rename the tmp file with the extension
            $ok = ImportFramework($filename, $frameworkcode, 1) if (rename($tmpfilename, $filename));
        }
    }
    if ($ok >= 0) { # If everything went ok go to the framework marc structure
        print $input->redirect( -location => '/cgi-bin/koha/admin/marctagstructure.pl?frameworkcode=' . $frameworkcode);
    } else {
        # If something failed go to the list of frameworks and show message
        print $input->redirect( -location => '/cgi-bin/koha/admin/biblio_framework.pl?error_import_export=' . $frameworkcode);
    }
}
