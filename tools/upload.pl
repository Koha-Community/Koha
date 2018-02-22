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
use Koha::UploadedFiles;

use constant ERR_READING     => 'UPLERR_FILE_NOT_READ';
use constant ALERT_DELETED   => 'UPL_FILE_DELETED'; # alert, no error
use constant ERR_NOT_DELETED => 'UPLERR_FILE_NOT_DELETED';

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
    uploadcategories => Koha::UploadedFiles->getCategories,
);

if ( $op eq 'new' ) {
    $template->param(
        mode             => 'new',
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'search' ) {
    my $uploads;
    if( $id ) { # might be a comma separated list
        my @id = split /,/, $id;
        foreach my $recid (@id) {
            my $rec = Koha::UploadedFiles->find( $recid );
            push @$uploads, $rec->unblessed
                if $rec && ( $rec->public || !$plugin );
                # Do not show private uploads in the plugin mode (:editor)
        }
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
    my $rec = Koha::UploadedFiles->find($id);
    undef $rec if $rec && $plugin && !$rec->public;
    my $fn = $rec ? $rec->filename : '';
    my $delete = $rec ? $rec->delete : undef;
    #TODO Improve error handling
    my $msg = $delete
        ? JSON::to_json({ $fn => { code => ALERT_DELETED }})
        : $id
        ? JSON::to_json({ $fn || $id, { code => ERR_NOT_DELETED }})
        : '';
    $template->param(
        mode             => 'deleted',
        msg              => $msg,
    );
    output_html_with_http_headers $input, $cookie, $template->output;

} elsif ( $op eq 'download' ) {
    my $rec = Koha::UploadedFiles->find( $id );
    undef $rec if $rec && $plugin && !$rec->public;
    my $fh  = $rec? $rec->file_handle:  undef;
    if ( !$rec || !$fh ) {
        $template->param(
            mode             => 'new',
            msg              => JSON::to_json({ $id => { code => ERR_READING }}),
        );
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
        print Encode::encode_utf8( $input->header( $rec->httpheaders ) );
        while (<$fh>) {
            print $_;
        }
        $fh->close;
    }
}
