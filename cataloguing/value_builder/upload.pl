#!/usr/bin/perl

# Converted to new plugin style (Bug 6874/See also 13437)

# This file is part of Koha.
#
# Copyright (C) 2011-2012 BibLibre
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
use CGI qw/-utf8/;

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::UploadedFiles;

my $builder = sub {
    my ( $params ) = @_;
    my $function_name = $params->{id};
    my $res           = "
    <script type=\"text/javascript\">
        function Click$function_name(event) {
            var index = event.data.id;
            var id = document.getElementById(index).value;
            var IsFileUploadUrl=0;
            if (id.match(/opac-retrieve-file/)) {
                IsFileUploadUrl=1;
            }
            if(id.match(/id=([0-9a-f]+)/)){
                id = RegExp.\$1;
            }
            var newin=window.open(\"../cataloguing/plugin_launcher.pl?plugin_name=upload.pl&index=\"+index+\"&id=\"+id+\"&from_popup=0\"+\"&IsFileUploadUrl=\"+IsFileUploadUrl, 'upload', 'width=600,height=400,toolbar=false,scrollbars=no');
            newin.focus();
        }
    </script>
";
    return $res;
};

my $launcher = sub {
    my ( $params ) = @_;
    my $input = $params->{cgi};
    my $index = $input->param('index');
    my $id = $input->param('id');
    my $delete = $input->param('delete');
    my $uploaded_file = $input->param('uploaded_file');
    my $from_popup = $input->param('from_popup');
    my $isfileuploadurl = $input->param('IsFileUploadUrl');
    my $dangling = C4::UploadedFiles::DanglingEntry($id,$isfileuploadurl);
    my $template_name;
    if ($delete || ($id && ($dangling==0 || $dangling==1))) {
        $template_name = "upload_delete_file.tt";
    }
    else {
        $template_name = "upload.tt";
    }

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {   template_name   => "cataloguing/value_builder/$template_name",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { editcatalogue => '*' },
            debug           => 1,
        }
    );

    if ($dangling==2) {
        $template->param( dangling => 1 );
    }

    # Dealing with the uploaded file
    my $dir = $input->param('uploadcategory');
    if ($uploaded_file and $dir) {
        my $fh = $input->upload('uploaded_file');

        $id = C4::UploadedFiles::UploadFile($uploaded_file, $dir, $fh->handle);
        my $OPACBaseURL = C4::Context->preference('OPACBaseURL') // '';
        $OPACBaseURL =~ s#/$##;
        if (!$OPACBaseURL) {
            $template->param(MissingURL => 1);
        }
        if($id && $OPACBaseURL) {
            my $return = "$OPACBaseURL/cgi-bin/koha/opac-retrieve-file.pl?id=$id";
            $template->param(
                success => 1,
                return => $return,
                uploaded_file => $uploaded_file,
            );
        } else {
            $template->param(error => 1);
        }
    } elsif ($delete || ($id && ($dangling==0 || $dangling==1))) {
        # If there's already a file uploaded for this field,
        # We handle its deletion
        if ($delete) {
            if(C4::UploadedFiles::DelUploadedFile($id)==0) {;
                $template->param(error => 1);
            } else {
                $template->param(success => 1);
            }
        }
    } else {
        my $upload_path = C4::Context->config('upload_path');
        if ($upload_path) {
            my $filefield = CGI::filefield(
                -name => 'uploaded_file',
                -size => 50,
            );
            $template->param(
                filefield => $filefield,
                uploadcategories => C4::UploadedFiles::getCategories(),
            );
        } else {
            $template->param( error_upload_path_not_configured => 1 );
        }

        if (!$uploaded_file && !$dir && $from_popup) {
            $template->param(error_nothing_selected => 1);
        }
        elsif (!$uploaded_file && $dir) {
            $template->param(error_no_file_selected => 1);
        }
        if ($uploaded_file and not $dir) {
            $template->param(error_no_dir_selected => 1);
        }

    }

    $template->param(
        index => $index,
        id => $id,
    );

    output_html_with_http_headers $input, $cookie, $template->output;
};

return { builder => $builder, launcher => $launcher };

1;

__END__

=head1 upload.pl

This plugin allows to upload files on the server and reference it in a marc
field.

It uses config variable upload_path and pref OPACBaseURL.

=cut
