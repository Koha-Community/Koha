#!/usr/bin/perl
#
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

use Modern::Perl;

use File::Temp;
use File::Copy;
use CGI;
use GD;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Debug;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/picture-upload.tt",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => { tools => 'batch_upload_patron_images'},
					debug => 0,
					});

my $filetype       = $input->param('filetype');
my $cardnumber     = $input->param('cardnumber');
my $uploadfilename = $input->param('uploadfile');
my $uploadfile     = $input->upload('uploadfile');
my $borrowernumber = $input->param('borrowernumber');
my $op             = $input->param('op') || '';

#FIXME: This code is really in the rough. The variables need to be re-scoped as the two subs depend on global vars to operate.
#       Other parts of this code could be optimized as well, I think. Perhaps the file upload could be done with YUI's upload
#       coded. -fbcit

$debug and warn "Params are: filetype=$filetype, cardnumber=$cardnumber, borrowernumber=$borrowernumber, uploadfile=$uploadfilename";

=head1 NAME

picture-upload.pl - Script for handling uploading of both single and bulk patronimages and importing them into the database.

=head1 SYNOPSIS

picture-upload.pl

=head1 DESCRIPTION

This script is called and presents the user with an interface allowing him/her to upload a single patron image or bulk patron images via a zip file.
Files greater than 100K will be refused. Images should be 140x200 pixels. If they are larger they will be auto-resized to comply.

=cut

$debug and warn "Operation requested: $op";

my ( $total, $handled, @counts, $tempfile, $tfh, %errors );

# Case is important in these operational values as the template must use case to be visually pleasing!
if ( ( $op eq 'Upload' ) && $uploadfile ) {
    my $dirname = File::Temp::tempdir( CLEANUP => 1 );
    $debug and warn "dirname = $dirname";
    my $filesuffix;
    if ( $uploadfilename =~ m/(\..+)$/i ) {
        $filesuffix = $1;
    }
    ( $tfh, $tempfile ) =
      File::Temp::tempfile( SUFFIX => $filesuffix, UNLINK => 1 );
    $debug and warn "tempfile = $tempfile";
    my ( @directories, $results );

    $errors{'NOTZIP'} = 1
      if ( $uploadfilename !~ /\.zip$/i && $filetype =~ m/zip/i );
    $errors{'NOWRITETEMP'} = 1 unless ( -w $dirname );
    $errors{'EMPTYUPLOAD'} = 1 unless ( length($uploadfile) > 0 );

    if (%errors) {
        $template->param( ERRORS => [ \%errors ] );
        output_html_with_http_headers $input, $cookie, $template->output;
        exit;
    }
    while (<$uploadfile>) {
        print $tfh $_;
    }
    close $tfh;
    if ( $filetype eq 'zip' ) {
        unless ( system( "unzip", $tempfile, '-d', $dirname ) == 0 ) {
            $errors{'UZIPFAIL'} = $uploadfilename;
            $template->param( ERRORS => [ \%errors ] );
            # This error is fatal to the import, so bail out here
            output_html_with_http_headers $input, $cookie, $template->output;
            exit;
        }
        push @directories, "$dirname";
        foreach my $recursive_dir (@directories) {
            opendir RECDIR, $recursive_dir;
            while ( my $entry = readdir RECDIR ) {
                push @directories, "$recursive_dir/$entry"
                  if ( -d "$recursive_dir/$entry" and $entry !~ /^\./ );
                $debug and warn "$recursive_dir/$entry";
            }
            closedir RECDIR;
        }
        foreach my $dir (@directories) {
            $results = handle_dir( $dir, $filesuffix, $template );
            $handled++ if $results == 1;
        }
        $total = scalar @directories;
    }
    else {
        #if ($filetype eq 'zip' )
        $results = handle_dir( $dirname, $filesuffix, $template, $cardnumber,
            $tempfile );
        $handled++ if $results == 1;
        $total   = 1;
    }

    if ( $results!=1 || %errors ) {
        $template->param( ERRORS => [$results] );
    }
    else {
        my $filecount;
        map { $filecount += $_->{count} } @counts;
        $debug and warn "Total directories processed: $total";
        $debug and warn "Total files processed: $filecount";
        $template->param(
            TOTAL   => $total,
            HANDLED => $handled,
            COUNTS  => \@counts,
            TCOUNTS => ( $filecount > 0 ? $filecount : undef ),
        );
        $template->param( borrowernumber => $borrowernumber )
          if $borrowernumber;
    }
}
elsif ( ( $op eq 'Upload' ) && !$uploadfile ) {
    warn "Problem uploading file or no file uploaded.";
    $template->param( cardnumber => $cardnumber );
    $template->param( filetype   => $filetype );
}
elsif ( $op eq 'Delete' ) {
    my $dberror = RmPatronImage($cardnumber);
    $debug and warn "Patron image deleted for $cardnumber";
    warn "Database returned $dberror" if $dberror;
}
if ( $borrowernumber && !%errors && !$template->param('ERRORS') ) {
    print $input->redirect(
        "/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
}
else {
    output_html_with_http_headers $input, $cookie, $template->output;
}

sub handle_dir {
    my ( $dir, $suffix, $template, $cardnumber, $source ) = @_;
    my ( %counts, %direrrors );
    $debug and warn "Entering sub handle_dir; passed \$dir=$dir, \$suffix=$suffix";
    if ( $suffix =~ m/zip/i ) {
        # If we were sent a zip file, process any included data/idlink.txt files
        my ( $file, $filename );
        undef $cardnumber;
        $debug and warn "Passed a zip file.";
        opendir DIR, $dir;
        while ( my $filename = readdir DIR ) {
            $file = "$dir/$filename"
              if ( $filename =~ m/datalink\.txt/i
                || $filename =~ m/idlink\.txt/i );
        }
        unless ( open( FILE, $file ) ) {
            warn "Opening $dir/$file failed!";
            $direrrors{'OPNLINK'} = $file;
            # This error is fatal to the import of this directory contents
            # so bail and return the error to the caller
            return \%direrrors;
        }

        while ( my $line = <FILE> ) {
            $debug and warn "Reading contents of $file";
            chomp $line;
            $debug and warn "Examining line: $line";
            my $delim = ( $line =~ /\t/ ) ? "\t" : ( $line =~ /,/ ) ? "," : "";
            $debug and warn "Delimeter is \'$delim\'";
            unless ( $delim eq "," || $delim eq "\t" ) {
                warn "Unrecognized or missing field delimeter. Please verify that you are using either a ',' or a 'tab'";
                $direrrors{'DELERR'} = 1;
                # This error is fatal to the import of this directory contents
                # so bail and return the error to the caller
                return \%direrrors;
            }
            ( $cardnumber, $filename ) = split $delim, $line;
            $cardnumber =~ s/[\"\r\n]//g; # remove offensive characters
            $filename   =~ s/[\"\r\n\s]//g;
            $debug and warn "Cardnumber: $cardnumber Filename: $filename";
            $source = "$dir/$filename";
            %counts = handle_file( $cardnumber, $source, $template, %counts );
        }
        close FILE;
        closedir DIR;
    }
    else {
        %counts = handle_file( $cardnumber, $source, $template, %counts );
    }
    push @counts, \%counts;
    return 1;
}

sub handle_file {
    my ( $cardnumber, $source, $template, %count ) = @_;
    $debug and warn "Entering sub handle_file; passed \$cardnumber=$cardnumber, \$source=$source";
    $count{filenames} = ()      if !$count{filenames};
    $count{source}    = $source if !$count{source};
    $count{count}     = 0       unless exists $count{count};
    my %filerrors;
    my $filename;
    if ( $filetype eq 'image' ) {
        $filename = $uploadfilename;
    }
    else {
        $filename = $1 if ( $source && $source =~ /\/([^\/]+)$/ );
    }
    if ( $cardnumber && $source ) {
        # Now process any imagefiles
        $debug and warn "Source: $source";
        my $size = ( stat($source) )[7];
        if ( $size > 550000 ) {
            # This check is necessary even with image resizing to avoid possible security/performance issues...
            $filerrors{'OVRSIZ'} = 1;
            push my @filerrors, \%filerrors;
            push @{ $count{filenames} },
              {
                filerrors  => \@filerrors,
                source     => $filename,
                cardnumber => $cardnumber
              };
            $template->param( ERRORS => 1 );
            # this one is fatal so bail here...
            return %count;
        }
        my ( $srcimage, $image );
        if ( open( IMG, "$source" ) ) {
            $srcimage = GD::Image->new(*IMG);
            close(IMG);
            if ( defined $srcimage ) {
                my $imgfile;
                my $mimetype = 'image/png';
                # GD autodetects three basic image formats: PNG, JPEG, XPM
                # we will convert all to PNG which is lossless...
                # Check the pixel size of the image we are about to import...
                my ( $width, $height ) = $srcimage->getBounds();
                $debug and warn "$filename is $width pix X $height pix.";
                if ( $width > 200 || $height > 300 ) {
                    # MAX pixel dims are 200 X 300...
                    $debug and warn "$filename exceeds the maximum pixel dimensions of 200 X 300. Resizing...";
                    # Percent we will reduce the image dimensions by...
                    my $percent_reduce;
                    if ( $width > 200 ) {
                        # If the width is oversize, scale based on width overage...
                        $percent_reduce = sprintf( "%.5f", ( 140 / $width ) );
                    }
                    else {
                        # otherwise scale based on height overage.
                        $percent_reduce = sprintf( "%.5f", ( 200 / $height ) );
                    }
                    my $width_reduce =
                      sprintf( "%.0f", ( $width * $percent_reduce ) );
                    my $height_reduce =
                      sprintf( "%.0f", ( $height * $percent_reduce ) );
                    $debug
                      and warn "Reducing $filename by "
                      . ( $percent_reduce * 100 )
                      . "\% or to $width_reduce pix X $height_reduce pix";
                    #'1' creates true color image...
                    $image = GD::Image->new( $width_reduce, $height_reduce, 1 );
                    $image->copyResampled( $srcimage, 0, 0, 0, 0, $width_reduce,
                        $height_reduce, $width, $height );
                    $imgfile = $image->png();
                    $debug
                      and warn "$filename is "
                      . length($imgfile)
                      . " bytes after resizing.";
                    undef $image;
                    undef $srcimage; # This object can get big...
                }
                else {
                    $image   = $srcimage;
                    $imgfile = $image->png();
                    $debug
                      and warn "$filename is " . length($imgfile) . " bytes.";
                    undef $image;
                    undef $srcimage; # This object can get big...
                }
                $debug and warn "Image is of mimetype $mimetype";
                my $dberror;
                if ($mimetype) {
                    $dberror =
                      PutPatronImage( $cardnumber, $mimetype, $imgfile );
                }
                if ( !$dberror && $mimetype ) {
                    # Errors from here on are fatal only to the import of a particular image
                    #so don't bail, just note the error and keep going
                    $count{count}++;
                    push @{ $count{filenames} },
                      { source => $filename, cardnumber => $cardnumber };
                }
                elsif ($dberror) {
                    warn "Database returned error: $dberror";
                    ( $dberror =~ /patronimage_fk1/ )
                      ? $filerrors{'IMGEXISTS'} = 1
                      : $filerrors{'DBERR'} = 1;
                    push my @filerrors, \%filerrors;
                    push @{ $count{filenames} },
                      {
                        filerrors  => \@filerrors,
                        source     => $filename,
                        cardnumber => $cardnumber
                      };
                    $template->param( ERRORS => 1 );
                }
                elsif ( !$mimetype ) {
                    warn "Unable to determine mime type of $filename. Please verify mimetype.";
                    $filerrors{'MIMERR'} = 1;
                    push my @filerrors, \%filerrors;
                    push @{ $count{filenames} },
                      {
                        filerrors  => \@filerrors,
                        source     => $filename,
                        cardnumber => $cardnumber
                      };
                    $template->param( ERRORS => 1 );
                }
            }
            else {
                warn "Contents of $filename corrupted!";
                #$count{count}--;
                $filerrors{'CORERR'} = 1;
                push my @filerrors, \%filerrors;
                push @{ $count{filenames} },
                  {
                    filerrors  => \@filerrors,
                    source     => $filename,
                    cardnumber => $cardnumber
                  };
                $template->param( ERRORS => 1 );
            }
        }
        else {
            warn "Opening $source failed!";
            $filerrors{'OPNERR'} = 1;
            push my @filerrors, \%filerrors;
            push @{ $count{filenames} },
              {
                filerrors  => \@filerrors,
                source     => $filename,
                cardnumber => $cardnumber
              };
            $template->param( ERRORS => 1 );
        }
    }
    else {
        # The need for this seems a bit unlikely, however, to maximize error trapping it is included
        warn "Missing "
          . (
            $cardnumber
            ? "filename"
            : ( $filename ? "cardnumber" : "cardnumber and filename" )
          );
        $filerrors{'CRDFIL'} = (
            $cardnumber
            ? "filename"
            : ( $filename ? "cardnumber" : "cardnumber and filename" )
        );
        push my @filerrors, \%filerrors;
        push @{ $count{filenames} },
          {
            filerrors  => \@filerrors,
            source     => $filename,
            cardnumber => $cardnumber
          };
        $template->param( ERRORS => 1 );
    }
    return (%count);
}

=head1 AUTHORS

Original contributor(s) undocumented

Database storage, single patronimage upload option, and extensive error trapping contributed by Chris Nighswonger cnighswonger <at> foundations <dot> edu
Image scaling/resizing contributed by the same.

=cut
