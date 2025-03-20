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

use Modern::Perl;
use Cwd;

use File::Temp;
use CGI qw ( -utf8 );
use GD;
use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Biblios;
use Koha::CoverImages;
use Koha::Items;
use Koha::UploadedFiles;
use C4::Log qw( logaction );

my $input = CGI->new;

my $fileID = $input->param('uploadedfileid');
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "tools/upload-images.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'upload_local_cover_images' },
    }
);

my $filetype     = $input->param('filetype');
my $biblionumber = $input->param('biblionumber');
my $itemnumber   = $input->param('itemnumber');
my $replace      = !C4::Context->preference("AllowMultipleCovers")
    || $input->param('replace');
my $op = $input->param('op') // q{};

my $error;

my $biblio;
my $cover_images;
my $item;

if ($itemnumber) {
    $item         = Koha::Items->find($itemnumber);
    $biblionumber = $item->biblionumber;
    $biblio       = Koha::Biblios->find($biblionumber);
    $cover_images = $item->cover_images->as_list;
} elsif ($biblionumber) {
    $biblio       = Koha::Biblios->find($biblionumber);
    $cover_images = $biblio->cover_images->as_list;
}

$template->param(
    filetype     => $filetype,
    biblio       => $biblio,
    biblionumber => $biblionumber,
    itemnumber   => $itemnumber,
    cover_images => $cover_images,
);

my $total = 0;
my @results;

if ( $op eq 'cud-process' && $fileID ) {
    my $upload = Koha::UploadedFiles->find($fileID);
    if ( $filetype eq 'image' ) {
        my $fh       = $upload->file_handle;
        my $srcimage = GD::Image->new($fh);
        $fh->close if $fh;
        if ( defined $srcimage ) {
            eval {
                if ($replace) {
                    if ($itemnumber) {
                        Koha::Items->find($itemnumber)->cover_images->delete;
                    } elsif ($biblionumber) {
                        Koha::Biblios->find($biblionumber)->cover_images->search( { itemnumber => undef } )->delete;
                    }
                }

                Koha::CoverImage->new(
                    {
                        biblionumber => $biblionumber,
                        itemnumber   => $itemnumber,
                        src_image    => $srcimage
                    }
                )->store;
            };

            if ($@) {
                warn $@;
                $error = 'DBERR';
            } else {
                $total = 1;
            }
        } else {
            $error = 'OPNIMG';
        }
        undef $srcimage;
    } else {
        my $filename = $upload->full_path;
        my $dirname  = File::Temp::tempdir( CLEANUP => 1 );
        qx/unzip $filename -d $dirname/;
        my $exit_code = $?;
        unless ( $exit_code == 0 ) {
            $error = 'UZIPFAIL';
        } else {
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
                my $idlink   = "$dir/idlink.txt";
                my $datalink = "$dir/datalink.txt";
                if ( -e $idlink && !-l $idlink ) {
                    $file = $idlink;
                } elsif ( -e $datalink && !-l $datalink ) {
                    $file = $datalink;
                } else {
                    next;
                }
                if ( open( my $fh, '<', $file ) ) {
                    while ( my $line = <$fh> ) {
                        my $delim =
                              ( $line =~ /\t/ ) ? "\t"
                            : ( $line =~ /,/ )  ? ","
                            :                     "";

                        unless ( $delim eq "," || $delim eq "\t" ) {
                            warn
                                "Unrecognized or missing field delimiter. Please verify that you are using either a ',' or a 'tab'";
                            $error = 'DELERR';
                            next;
                        } else {
                            ( $biblionumber, $filename ) = split $delim, $line, 2;
                            $biblionumber =~ s/[\"\r\n]//g;    # remove offensive characters
                            $filename     =~ s/[\"\r\n]//g;
                            $filename     =~ s/^\s+//;
                            $filename     =~ s/\s+$//;
                            my $full_filename =
                                Cwd::abs_path("$dir/$filename");    #Resolve any relative filepath references
                            my $srcimage;
                            if ( $full_filename =~ /^\Q$dir\E/ ) {
                                $srcimage = GD::Image->new($full_filename);
                            }
                            my $biblio;
                            my $item;
                            if ( defined $srcimage ) {
                                $total++;
                                eval {
                                    if ($replace) {
                                        if ($biblionumber) {
                                            $biblio = Koha::Biblios->find($biblionumber);
                                            $biblio->cover_images->delete;
                                        } elsif ($itemnumber) {
                                            $item = Koha::Items->find($itemnumber);
                                            $item->cover_images->delete;
                                            $biblio = Koha::Biblios->find( $item->{biblionumber} );
                                        }
                                    } else {
                                        if ($biblionumber) {
                                            $biblio = Koha::Biblios->find($biblionumber);
                                        } elsif ($itemnumber) {
                                            $item   = Koha::Items->find($itemnumber);
                                            $biblio = Koha::Biblios->find( $item->{biblionumber} );
                                        } else {
                                            warn "Problem.";
                                        }
                                    }

                                    push @results, {
                                        biblionumber => $biblionumber,
                                        itemnumber   => $itemnumber,
                                        title        => $biblio->title
                                    };

                                    Koha::CoverImage->new(
                                        {
                                            biblionumber => $biblionumber,
                                            itemnumber   => $itemnumber,
                                            src_image    => $srcimage
                                        }
                                    )->store;
                                };

                                if ($@) {
                                    $error = 'DBERR';
                                }
                            } else {
                                $error = 'OPNIMG';
                            }
                            undef $srcimage;

                            if ( !$error && C4::Context->preference("CataloguingLog") ) {
                                logaction( 'CATALOGUING', 'MODIFY', $biblionumber, "biblio cover image: $filename" );
                            }

                        }
                    }
                    close($fh);
                } else {
                    $error = 'OPNLINK';
                }
            }
        }
    }
    if ($error) {
        $template->param(
            total        => $total,
            uploadimage  => 1,
            error        => $error,
            biblionumber => $biblionumber || Koha::Items->find($itemnumber)->biblionumber,
            itemnumber   => $itemnumber,
        );
    } elsif (@results) {
        $template->param(
            total       => $total,
            uploadimage => 1,
            results     => \@results
        );
    } else {
        print $input->redirect(
            "/cgi-bin/koha/tools/upload-cover-image.pl?biblionumber=$biblionumber&itemnumber=$itemnumber");
    }
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

=head1 AUTHORS

Written by Jared Camins-Esakov of C & P Bibliography Services, in part based on
code by Koustubha Kale of Anant Corporation and Chris Nighswonger of Foundation
Bible College.

=cut
