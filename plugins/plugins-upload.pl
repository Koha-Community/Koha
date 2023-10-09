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

use Modern::Perl;

use Archive::Extract;
use CGI qw ( -utf8 );
use List::Util qw( any );
use Mojo::UserAgent;
use File::Temp;

use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Members;
use Koha::Logger;
use Koha::Plugins;

my $plugins_enabled    = C4::Context->config("enable_plugins");
my $plugins_restricted = C4::Context->config("plugins_restricted");

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => $plugins_enabled ? "plugins/plugins-upload.tt" : "plugins/plugins-disabled.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { plugins => 'manage' },
    }
);

my $uploadlocation = $input->param('uploadlocation');

# Early exists if uploads are not enabled direct upload attempted when uploads are restricted
if (!$plugins_enabled) {
    output_html_with_http_headers $input, $cookie, $template->output;
} elsif ( $plugins_restricted && !$uploadlocation ) {
    $template->param( plugins_restricted => $plugins_restricted );
    output_html_with_http_headers $input, $cookie, $template->output;
}

my $uploadfilename = $input->param('uploadfile');
my $uploadfile     = $input->upload('uploadfile');
my $op             = $input->param('op') || q{};

my ( $tempfile, $tfh );

my %errors;

if ( ( $op eq 'Upload' ) && ( $uploadfile || $uploadlocation ) ) {
    my $plugins_dir = C4::Context->config("pluginsdir");
    $plugins_dir = ref($plugins_dir) eq 'ARRAY' ? $plugins_dir->[0] : $plugins_dir;

    my $dirname = File::Temp::tempdir( CLEANUP => 1 );

    my $filesuffix;
    $filesuffix = $1 if $uploadfilename =~ m/(\..+)$/i;
    ( $tfh, $tempfile ) = File::Temp::tempfile( SUFFIX => $filesuffix, UNLINK => 1 );

    $errors{'NOTKPZ'}         = 1 if ( $uploadfilename !~ /\.kpz$/i );
    $errors{'NOWRITETEMP'}    = 1 unless ( -w $dirname );
    $errors{'NOWRITEPLUGINS'} = 1 unless ( -w $plugins_dir );

    if ($uploadlocation) {
        my $do_get = 1;
        if ($plugins_restricted) {
            my $repos = C4::Context->config('plugin_repos');

            # Fix data structure if only one repo defined
            if ( ref( $repos->{repo} ) eq 'HASH' ) {
                $repos = { repo => [ $repos->{repo} ] };
            }

            $do_get = any { index( $uploadlocation, $_->{org_name} ) != -1 } @{ $repos->{repo} };
        }

        if ($do_get) {
            my $ua = Mojo::UserAgent->new( max_redirects => 5 );
            my $tx = $ua->get($uploadlocation);
            $tx->result->content->asset->move_to($tempfile);
        } else {
            $errors{'RESTRICTED'} = 1;
        }
    } else {
        $errors{'RESTRICTED'}  = 1 unless ( !$plugins_restricted );
        $errors{'EMPTYUPLOAD'} = 1 unless ( length($uploadfile) > 0 );
    }

    if (%errors) {
        $template->param( ERRORS => [ \%errors ] );
    } else {
        if ( $uploadfile && !$plugins_restricted ) {
            while (<$uploadfile>) {
                print $tfh $_;
            }
            close $tfh;
        }

        my $ae = Archive::Extract->new( archive => $tempfile, type => 'zip' );
        unless ( $ae->extract( to => $plugins_dir ) ) {
            warn "ERROR: " . $ae->error;
            $errors{'UZIPFAIL'} = $uploadfilename;
            $template->param( ERRORS => [ \%errors ] );
            output_html_with_http_headers $input, $cookie, $template->output;
            exit;
        }

        Koha::Plugins->new()->InstallPlugins();
    }
} elsif ( ( $op eq 'Upload' ) && !$uploadfile && !$uploadlocation ) {
    warn "Problem uploading file or no file uploaded.";
}

if ( ( $uploadfile || $uploadlocation ) && !%errors && !$template->param('ERRORS') ) {
    print $input->redirect("/cgi-bin/koha/plugins/plugins-home.pl");
} else {
    output_html_with_http_headers $input, $cookie, $template->output;
}
