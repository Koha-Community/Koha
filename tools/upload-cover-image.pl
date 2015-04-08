#!/usr/bin/perl
#
# Copyright 2011 C & P Bibliography Services
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
#
#
#

=head1 NAME

upload-cover-image.pl - Script for handling uploading of both single and bulk coverimages and importing them into the database.

=head1 SYNOPSIS

upload-cover-image.pl

=head1 DESCRIPTION

This script is called and presents the user with an interface allowing him/her to upload a single cover image or bulk cover images via a zip file.
Images will be resized into thumbnails of 140x200 pixels and larger images of
800x600 pixels. If the images that are uploaded are larger, they will be
resized, maintaining aspect ratio.

=cut

use strict;
use warnings;

use File::Temp;
use CGI;
use GD;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Images;
use C4::UploadedFile;
use C4::Log;

my $debug = 1;

my $input = new CGI;

my $fileID = $input->param('uploadedfileid');
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/upload-images.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'upload_local_cover_images' },
        debug           => 0,
    }
);

my $filetype       = $input->param('filetype');
my $biblionumber   = $input->param('biblionumber');
my $uploadfilename = $input->param('uploadfile');
my $replace        = !C4::Context->preference("AllowMultipleCovers")
  || $input->param('replace');
my $op        = $input->param('op');
my %cookies   = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;

my $error;

$template->{VARS}->{'filetype'}     = $filetype;
$template->{VARS}->{'biblionumber'} = $biblionumber;

my $total = 0;

if ($fileID) {
    my $uploaded_file = C4::UploadedFile->fetch( $sessionID, $fileID );
    if ( $filetype eq 'image' ) {
        my $fh       = $uploaded_file->fh();
        my $srcimage = GD::Image->new($fh);
        if ( defined $srcimage ) {
            my $dberror = PutImage( $biblionumber, $srcimage, $replace );
            if ($dberror) {
                $error = 'DBERR';
            }
            else {
                $total = 1;
            }
        }
        else {
            $error = 'OPNIMG';
        }
        undef $srcimage;
    }
    else {
        my $filename = $uploaded_file->filename();
        my $dirname = File::Temp::tempdir( CLEANUP => 1 );
        unless ( system( "unzip", $filename, '-d', $dirname ) == 0 ) {
            $error = 'UZIPFAIL';
        }
        else {
            my @directories;
            push @directories, "$dirname";
            foreach my $recursive_dir (@directories) {
                my $dir;
                opendir $dir, $recursive_dir;
                while ( my $entry = readdir $dir ) {
                    push @directories, "$recursive_dir/$entry"
                      if ( -d "$recursive_dir/$entry" and $entry !~ /^[._]/ );
                }
                closedir $dir;
            }
            foreach my $dir (@directories) {
                my $file;
                if ( -e "$dir/idlink.txt" ) {
                    $file = "$dir/idlink.txt";
                }
                elsif ( -e "$dir/datalink.txt" ) {
                    $file = "$dir/datalink.txt";
                }
                else {
                    next;
                }
                if ( open( FILE, $file ) ) {
                    while ( my $line = <FILE> ) {
                        my $delim =
                            ( $line =~ /\t/ ) ? "\t"
                          : ( $line =~ /,/ )  ? ","
                          :                     "";

                        #$debug and warn "Delimeter is \'$delim\'";
                        unless ( $delim eq "," || $delim eq "\t" ) {
                            warn
"Unrecognized or missing field delimeter. Please verify that you are using either a ',' or a 'tab'";
                            $error = 'DELERR';
                        }
                        else {
                            ( $biblionumber, $filename ) = split $delim, $line, 2;
                            $biblionumber =~
                              s/[\"\r\n]//g;    # remove offensive characters
                            $filename =~ s/[\"\r\n]//g;
                            $filename =~ s/^\s+//;
                            $filename =~ s/\s+$//;
                            if (C4::Context->preference("CataloguingLog")) {
                                logaction('CATALOGUING', 'MODIFY', $biblionumber, "biblio cover image: $filename");
                            }
                            my $srcimage = GD::Image->new("$dir/$filename");
                            if ( defined $srcimage ) {
                                $total++;
                                my $dberror =
                                  PutImage( $biblionumber, $srcimage,
                                    $replace );
                                if ($dberror) {
                                    $error = 'DBERR';
                                }
                            }
                            else {
                                $error = 'OPNIMG';
                            }
                            undef $srcimage;
                        }
                    }
                    close(FILE);
                }
                else {
                    $error = 'OPNLINK';
                }
            }
        }
    }
    $template->{VARS}->{'total'}        = $total;
    $template->{VARS}->{'uploadimage'}  = 1;
    $template->{VARS}->{'error'}        = $error;
    $template->{VARS}->{'biblionumber'} = $biblionumber;
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

=head1 AUTHORS

Written by Jared Camins-Esakov of C & P Bibliography Services, in part based on
code by Koustubha Kale of Anant Corporation and Chris Nighswonger of Foundation
Bible College.

=cut
