#!/usr/bin/perl

use Modern::Perl;

use CGI qw ( -utf8 );
use Graphics::Magick;

use C4::Context;
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers );
use C4::Creators    qw( html_table );
use C4::Patroncards qw( get_image put_image rm_image );

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "patroncards/image-manage.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { tools => 'label_creator' },
    }
);

my $file_name   = $cgi->param('uploadfile')  || '';
my $image_name  = $cgi->param('image_name')  || $file_name;
my $upload_file = $cgi->upload('uploadfile') || '';
my $op          = $cgi->param('op')          || 'none';
my @image_ids   = $cgi->multi_param('image_id');

my @errors = ( 'pdferr', 'errnocards', 'errba', 'errpl', 'errpt', 'errlo', 'errtpl', );
foreach my $param (@errors) {
    my $error = $cgi->param($param) ? 1 : 0;
    $template->param( 'error_' . $param => $error )
        if $error;
}

my $source_file = "$file_name"
    ;    # otherwise we end up with what amounts to a pointer to a filehandle rather than a user-friendly filename

my $display_columns = {
    image => [    #{db column      => {label => 'col label', is link?          }},
        { image_id   => { label => 'ID',     link_field => 0 } },
        { image_name => { label => 'Name',   link_field => 0 } },
        { _delete    => { label => 'Delete', link_field => 0 } },
        { select     => { label => 'Select', value      => 'image_id' } },
    ],
};
my $table = html_table( $display_columns->{'image'}, get_image( undef, "image_id, image_name" ) );

my $image_limit = C4::Context->preference('ImageLimit') || '';
my $errstr      = '';                                            # NOTE: For error codes see error-messages.inc

if ( $op eq 'cud-upload' ) {

    # Checking for duplicate image name
    my $dbh      = C4::Context->dbh;
    my $query    = "SELECT COUNT(*) FROM creator_images WHERE image_name=?";
    my ($exists) = $dbh->selectrow_array( $query, undef, $image_name );
    if ($exists) {
        $errstr = 304;
        $template->param(
            IMPORT_SUCCESSFUL => 0,
            SOURCE_FILE       => $source_file,
            IMAGE_NAME        => $image_name,
            TABLE             => $table,
            error             => $errstr,
        );
    } else {
        if ( !$upload_file ) {
            warn sprintf( 'An error occurred while attempting to upload file %s.', $source_file );
            $errstr = 301;
            $template->param(
                IMPORT_SUCCESSFUL => 0,
                SOURCE_FILE       => $source_file,
                IMAGE_NAME        => $image_name,
                TABLE             => $table,
                error             => $errstr,
            );
        } else {
            my $image = Graphics::Magick->new;
            eval { $image->Read( $cgi->tmpFileName($file_name) ); };
            if ($@) {
                warn sprintf( 'An error occurred while creating the image object: %s', $@ );
                $errstr = 202;
                $template->param(
                    IMPORT_SUCCESSFUL => 0,
                    SOURCE_FILE       => $source_file,
                    IMAGE_NAME        => $image_name,
                    TABLE             => $table,
                    error             => $errstr,
                );
            } else {
                my $errstr = '';
                my $size   = $image->Get('filesize');
                $errstr = 302 if $size > 2097152;
                $image->Set( magick => 'png' )
                    ; # convert all images to png as this is a lossless format which is important for resizing operations later on
                my $err = put_image( $image_name, $image->ImageToBlob() ) || '0';
                $errstr = 101 if $err == 1;
                $errstr = 303 if $err == 202;
                if ($errstr) {
                    $template->param(
                        IMPORT_SUCCESSFUL => 0,
                        SOURCE_FILE       => $source_file,
                        IMAGE_NAME        => $image_name,
                        TABLE             => $table,
                        error             => $errstr,
                        image_limit       => $image_limit,
                    );
                } else {
                    $table = html_table( $display_columns->{'image'}, get_image( undef, "image_id, image_name" ) )
                        ;    # refresh table data after successfully performing save operation
                    $template->param(
                        IMPORT_SUCCESSFUL => 1,
                        SOURCE_FILE       => $source_file,
                        IMAGE_NAME        => $image_name,
                        TABLE             => $table,
                    );
                }
            }
        }
    }
} elsif ( $op eq 'cud-delete' ) {
    my $err    = '';
    my $errstr = '';
    if (@image_ids) {
        $err    = rm_image( \@image_ids );
        $errstr = 102 if $err;
    } else {
        warn sprintf('No image ids passed in to delete.');
        $errstr = 202;
    }
    if ($errstr) {
        $template->param(
            DELETE_SUCCESSFULL => 0,
            IMAGE_IDS          => join( ', ', @image_ids ),
            TABLE              => $table,
            error              => $errstr,
            image_ids          => join( ',', @image_ids ),
        );
    } else {
        $table = html_table( $display_columns->{'image'}, get_image( undef, "image_id, image_name" ) )
            ;    # refresh table data after successfully performing delete operation
        $template->param(
            DELETE_SUCCESSFULL => 1,
            TABLE              => $table,
        );
    }
} elsif ( $op eq 'none' ) {
    $template->param(
        IMPORT_SUCCESSFUL => 0,
        SOURCE_FILE       => $source_file,
        IMAGE_NAME        => $image_name,
        TABLE             => $table,
    );
} else {    # to trap unsupported operations
    warn sprintf( 'Image upload interface called an unsupported operation: %s', $op );
    $errstr = 201;
    $template->param(
        IMPORT_SUCCESSFUL => 0,
        SOURCE_FILE       => $source_file,
        IMAGE_NAME        => $image_name,
        TABLE             => $table,
        error             => $errstr,
    );
}

output_html_with_http_headers $cgi, $cookie, $template->output;

__END__

=head1 NAME

image-upload.pl - Script for handling uploading of single images and importing them into the database.

=head1 SYNOPSIS

image-upload.pl

=head1 DESCRIPTION

This script is called and presents the user with an interface allowing him/her to upload a single image file. Files greater than 500K will be refused.

=head1 AUTHOR

Chris Nighswonger <cnighswonger AT foundations DOT edu>

=head1 COPYRIGHT

Copyright 2009 Foundations Bible College.

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 DISCLAIMER OF WARRANTY

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

=cut
