#!/usr/bin/perl

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

use Archive::Extract;
use File::Temp;
use File::Copy;
use CGI;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Debug;
use Koha::Plugins;

my $plugins_enabled = C4::Context->preference('UseKohaPlugins') && C4::Context->config("enable_plugins");

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name => ($plugins_enabled) ? "plugins/plugins-upload.tt" : "plugins/plugins-disabled.tt",
        query         => $input,
        type          => "intranet",
        authnotrequired => 0,
        flagsrequired   => { plugins => 'manage' },
        debug           => 1,
    }
);

my $uploadfilename = $input->param('uploadfile');
my $uploadfile     = $input->upload('uploadfile');
my $op             = $input->param('op');

my ( $total, $handled, @counts, $tempfile, $tfh );

my %errors;

if ($plugins_enabled) {
    if ( ( $op eq 'Upload' ) && $uploadfile ) {
        my $plugins_dir = C4::Context->config("pluginsdir");

        my $dirname = File::Temp::tempdir( CLEANUP => 1 );
        $debug and warn "dirname = $dirname";

        my $filesuffix;
        $filesuffix = $1 if $uploadfilename =~ m/(\..+)$/i;
        ( $tfh, $tempfile ) = File::Temp::tempfile( SUFFIX => $filesuffix, UNLINK => 1 );

        $debug and warn "tempfile = $tempfile";

        $errors{'NOTKPZ'} = 1 if ( $uploadfilename !~ /\.kpz$/i );
        $errors{'NOWRITETEMP'}    = 1 unless ( -w $dirname );
        $errors{'NOWRITEPLUGINS'} = 1 unless ( -w $plugins_dir );
        $errors{'EMPTYUPLOAD'}    = 1 unless ( length($uploadfile) > 0 );

        if (%errors) {
            $template->param( ERRORS => [ \%errors ] );
        } else {
            while (<$uploadfile>) {
                print $tfh $_;
            }
            close $tfh;

            my $ae = Archive::Extract->new( archive => $tempfile, type => 'zip' );
            unless ( $ae->extract( to => $plugins_dir ) ) {
                warn "ERROR: " . $ae->error;
                $errors{'UZIPFAIL'} = $uploadfilename;
                $template->param( ERRORS => [ \%errors ] );
                output_html_with_http_headers $input, $cookie, $template->output;
                exit;
            }
        }
    } elsif ( ( $op eq 'Upload' ) && !$uploadfile ) {
        warn "Problem uploading file or no file uploaded.";
    }

    if ( $uploadfile && !%errors && !$template->param('ERRORS') ) {
        print $input->redirect("/cgi-bin/koha/plugins/plugins-home.pl");
    } else {
        output_html_with_http_headers $input, $cookie, $template->output;
    }

} else {
    output_html_with_http_headers $input, $cookie, $template->output;
}
