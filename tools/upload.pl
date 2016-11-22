#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2015 Rijksmuseum
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
use JSON;

use C4::Auth;
use C4::Output;
use Koha::Upload;
use Koha::UploadedFiles;

my $input  = CGI::->new;
my $op     = $input->param('op') // 'new';
my $plugin = $input->param('plugin');
my $index  = $input->param('index');         # MARC editor input field id
my $term   = $input->param('term');
my $id     = $input->param('id');
my $msg    = $input->param('msg');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "tools/upload.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'upload_general_files' },
    }
);

$template->param(
    index      => $index,
    owner      => $loggedinuser,
    plugin     => $plugin,
);

if ( $op eq 'new' ) {
    $template->param(
        mode             => 'new',
        uploadcategories => Koha::Upload->getCategories,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'search' ) {
    my $uploads;
    if( $id ) {
        my $rec = Koha::UploadedFiles->search({
            id => $id,
            $plugin? ( public => 1 ) : (),
        })->next;
        push @$uploads, $rec->unblessed if $rec;
    } else {
        $uploads = Koha::UploadedFiles->search_term({
            term => $term,
            $plugin? (): ( include_private => 1 ),
        })->unblessed;
    }

    $template->param(
        mode    => 'report',
        msg     => $msg,
        uploads => $uploads,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'delete' ) {
    # delete only takes the id parameter
    my $upload = $plugin?
         Koha::UploadedFiles->search({ public => 1, id => $id })->next:
         Koha::UploadedFiles->find($id);
    my $fn = $upload? $upload->delete: undef;
    #TODO Improve error handling
    my $msg = $fn?
        JSON::to_json({ $fn => 6 }):
        JSON::to_json({
            $upload? $upload->filename: ( $id? "id $id": '[No id]' ), 7,
        });
    $template->param(
        mode             => 'deleted',
        msg              => $msg,
        uploadcategories => Koha::Upload->getCategories,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'download' ) {
    my $rec = Koha::UploadedFiles->search({
        id => $id,
        $plugin? ( public => 1 ) : (),
    })->next;
    my $fh  = $rec? $rec->file_handle:  undef;
    if ( !$rec || !$fh ) {
        $template->param(
            mode             => 'new',
            msg              => JSON::to_json( { $id => 5 } ),
            uploadcategories => Koha::Upload->getCategories,
        );
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
        my @hdr = Koha::Upload->httpheaders( $rec->filename );
        print Encode::encode_utf8( $input->header(@hdr) );
        while (<$fh>) {
            print $_;
        }
        $fh->close;
    }
}
