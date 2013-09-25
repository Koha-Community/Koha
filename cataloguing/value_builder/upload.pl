#!/usr/bin/perl

# Copyright 2011-2012 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
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
use CGI qw/-utf8/;
use File::Basename;

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::UploadedFiles;

sub plugin_parameters {
    my ( $dbh, $record, $tagslib, $i, $tabloop ) = @_;
    return "";
}

sub plugin_javascript {
    my ( $dbh, $record, $tagslib, $field_number, $tabloop ) = @_;
    my $function_name = $field_number;
    my $res           = "
    <script type=\"text/javascript\">
        function Focus$function_name(subfield_managed) {
            return 1;
        }

        function Blur$function_name(subfield_managed) {
            return 1;
        }

        function Clic$function_name(index) {
            var id = document.getElementById(index).value;
            if(id.match(/id=([0-9a-f]+)/)){
                id = RegExp.\$1;
            }
            window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=upload.pl&index=\"+index+\"&id=\"+id, 'upload', 'width=600,height=400,toolbar=false,scrollbars=no');

        }
    </script>
";

    return ( $function_name, $res );
}

sub plugin {
    my ($input) = @_;
    my $index = $input->param('index');
    my $id = $input->param('id');
    my $delete = $input->param('delete');
    my $uploaded_file = $input->param('uploaded_file');

    my $template_name = ($id || $delete)
                    ? "upload_delete_file.tt"
                    : "upload.tt";

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/$template_name",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );

    # Dealing with the uploaded file
    if ($uploaded_file) {
        my $fh = $input->upload('uploaded_file');
        my $dir = $input->param('dir');

        $id = C4::UploadedFiles::UploadFile($uploaded_file, $dir, $fh->handle);
        if($id) {
            my $OPACBaseURL = C4::Context->preference('OPACBaseURL');
            $OPACBaseURL =~ s#/$##;
            my $return = "$OPACBaseURL/cgi-bin/koha/opac-retrieve-file.pl?id=$id";
            $template->param(
                success => 1,
                return => $return,
                uploaded_file => $uploaded_file,
            );
        } else {
            $template->param(error => 1);
        }
    } elsif ($delete || $id) {
        # If there's already a file uploaded for this field,
        # We handle its deletion
        if ($delete) {
            if(C4::UploadedFiles::DelUploadedFile($id)) {;
                $template->param(success => 1);
            } else {
                $template->param(error => 1);
            }
        }
    } else {
        my $upload_path = C4::Context->config('upload_path');
        if ($upload_path) {
            my $filefield = CGI::filefield(
                -name => 'uploaded_file',
                -size => 50,
            );

            my $dirs_tree = [ {
                name => '/',
                value => '/',
                dirs => finddirs($upload_path)
            } ];

            $template->param(
                dirs_tree => $dirs_tree,
                filefield => $filefield
            );
        } else {
            $template->param( error_upload_path_not_configured => 1 );
        }
    }

    $template->param(
        index => $index,
        id => $id
    );

    output_html_with_http_headers $input, $cookie, $template->output;
}

# Build a hierarchy of directories
sub finddirs {
    my $base = shift;
    my $upload_path = C4::Context->config('upload_path');
    my $found = 0;
    my @dirs;
    my @files = glob("$base/*");
    foreach (@files) {
        if (-d $_ and -w $_) {
            my $lastdirname = basename($_);
            my $dirname =  $_;
            $dirname =~ s/^$upload_path//g;
            push @dirs, {
                value => $dirname,
                name => $lastdirname,
                dirs => finddirs($_)
            };
            $found = 1;
        };
    }
    return \@dirs;
}

1;


__END__

=head1 upload.pl

This plugin allow to upload files on the server and reference it in a marc
field.

Two system preference are used:

=over 4

=item * upload_path: the real absolute path where files will be stored

=item * OPACBaseURL: for building URLs to be stored in MARC

=back
