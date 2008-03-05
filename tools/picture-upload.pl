#!/usr/bin/perl
#
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
#
#

use File::Temp;
use File::Copy;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
#use Data::Dumper;

my $DEBUG = ($ENV{DEBUG}) ? 1 : 0;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "tools/picture-upload.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {management => 1, tools => 1},
					debug => 0,
					});

my $filetype            = $input->param('filetype');
my $cardnumber          = $input->param('cardnumber');
my $uploadfilename      = $input->param('uploadfile');
my $uploadfile          = $input->upload('uploadfile');
my $borrowernumber      = $input->param('borrowernumber');

#FIXME: This code is really in the rough. The variables need to be re-scoped as the two subs depend on global vars to operate.
#       Other parts of this code could be optimized as well, I think. Perhaps the file upload could be done with YUI's upload
#       coded. -fbcit

warn "Params are: filetype=$filetype, cardnumber=$cardnumber, uploadfile=$uploadfilename" if $DEBUG;

=head1 NAME

picture-upload.p. - Script for handling uploading of both single and bulk patronimages and importing them into the database.

=head1 SYNOPSIS

picture-upload.pl

=head1 DESCRIPTION

THis script is called and presents the user with an interface allowing him/her to upload a single patron image or bulk patron images via a zip file.

=cut



my ( $total, $handled, @counts, $tempfile, $tfh );

if ( $uploadfile ) {
    my $dirname = File::Temp::tempdir( CLEANUP => 1);
    warn "dirname = $dirname" if $DEBUG;
    my $filesuffix = $1 if $uploadfilename =~ m/(\..+)$/i;
    ( $tfh, $tempfile ) = File::Temp::tempfile( SUFFIX => $filesuffix, UNLINK => 1 );
    warn "tempfile = $tempfile" if $DEBUG;
    my ( @directories, $errors );

    $errors{'NOTZIP'} = 1 if ( $uploadfilename !~ /\.zip$/i && $filetype =~ m/zip/i );
    $errors{'NOWRITETEMP'} = 1 unless ( -w $dirname );
    $errors{'EMPTYUPLOAD'} = 1 unless ( length( $uploadfile ) > 0 );

    if ( %errors ) {
	$template->param( ERRORS => [ \%errors ] );
    } else {
	while ( <$uploadfile> ) {
	    print $tfh $_;
        }

        close $tfh;
        if ( $filetype eq 'zip' ) {
            unless (system("unzip $tempfile -d $dirname") == 0) {
                $errors{'UZIPFAIL'} = $uploadfilename;
	        $template->param( ERRORS => [ \%errors ] );
                output_html_with_http_headers $input, $cookie, $template->output;   # This error is fatal to the import, so bail out here
                exit;
            }
            push @directories, "$dirname";
            foreach $recursive_dir ( @directories ) {
                opendir $dir, $recursive_dir;
                while ( my $entry = readdir $dir ) {
	        push @directories, "$recursive_dir/$entry" if ( -d "$recursive_dir/$entry" and $entry !~ /^\./ );
                warn "$recursive_dir/$entry" if $DEBUG;
                }   
                closedir $dir;
            }       
            my $results;
            foreach my $dir ( @directories ) {
                $results = handle_dir( $dir, $filesuffix );
                $handled++ if $results == 1;
            }
            $total = scalar @directories;
        } else {       #if ($filetype eq 'zip' )
            $result = handle_dir( $dirname, $filesuffix );
            $handled = 1;
            $total = 1;
        }

        if ( %$results || %errors ) {
            $template->param( ERRORS => [ \%$results ] );
        } else {
            warn "Total files processed: $total" if $DEBUG;
            warn "Errors in \$errors." if $errors;
            $template->param(
    		 TOTAL => $total,
		 HANDLED => $handled,
		 COUNTS => \@counts,
		 TCOUNTS => scalar(@counts),
            );
        }   
    }
} else {
	$template->param(cardnumber => $cardnumber );
	$template->param(filetype => $filetype );
}

if ( $borrowernumber ) {
    my $urlbase = $input->url(-base => 1 -rewrite => 1);
    print $input->redirect ("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
} else {
    output_html_with_http_headers $input, $cookie, $template->output;
}

sub handle_dir {
    my ( $dir, $suffix ) = @_;
    my $source;
    warn "Entering sub handle_dir; passed \$dir=$dir, \$suffix=$suffix" if $DEBUG;
    if ($suffix =~ m/zip/i) {     # If we were sent a zip file, process any included data/idlink.txt files 
        my ( $file, $filename, $cardnumber );
        warn "Passed a zip file." if $DEBUG;
        opendir my $dirhandle, $dir;
        while ( my $filename = readdir $dirhandle ) {
            $file = "$dir/$filename" if ($filename =~ m/datalink\.txt/i || $filename =~ m/idlink\.txt/i);
        }
        unless (open (FILE, $file)) { 
		warn "Opening $dir/$file failed!";
                $errors{'OPNLINK'} = $file;
		return $errors; # This error is fatal to the import of this directory contents, so bail and return the error to the caller
        };

        while (my $line = <FILE>) {
            warn "Reading contents of $file" if $DEBUG;
	    chomp $line;
            warn "Examining line: $line" if $DEBUG;
	    my $delim = ($line =~ /\t/) ? "\t" : ($line =~ /,/) ? "," : "";
            warn "Delimeter is \'$delim\'" if $DEBUG;
            unless ( $delim eq "," || $delim eq "\t" ) {
                warn "Unrecognized or missing field delimeter. Please verify that you are using either a ',' or a 'tab'";
                $errors{'DELERR'} = 1;      # This error is fatal to the import of this directory contents, so bail and return the error to the caller
                return $errors;
            }
	    ($cardnumber, $filename) = split $delim, $line;
	    $cardnumber =~ s/[\"\r\n]//g;  # remove offensive characters
	    $filename   =~ s/[\"\r\n\s]//g;
            warn "Cardnumber: $cardnumber Filename: $filename" if $DEBUG;
            $source = "$dir/$filename";
            %counts = handle_file($cardnumber, $source, %counts);
        }
        close FILE;
        closedir ($dirhandle);
    } else {
        $source = $tempfile;
        %counts = handle_file($cardnumber, $source, %counts);
    }
push @counts, \%counts;
return 1;
}

sub handle_file {
    my ($cardnumber, $source, %count) = @_;
    warn "Entering sub handle_file; passed \$cardnumber=$cardnumber, \$source=$source" if $DEBUG;
    my $mimemap = {
        "gif"   => "image/gif",
        "jpg"   => "image/jpeg",
        "jpeg"  => "image/jpeg",
        "png"   => "image/png"
    };
    $count{filenames} = () if !$count{filenames};
    $count{source} = $source if !$count{source};
    if ($cardnumber && $source) {     # Now process any imagefiles
        my %filerrors;
        warn "Source: $source" if $DEBUG;
        if (open (IMG, "$source")) {
            #binmode (IMG); # Not sure if we need this or not -fbcit
            my $imgfile;
            while (<IMG>) {
                $imgfile .= $_;
            }
            if ($filetype eq 'image') {
                $filename = $uploadfilename;
            } else {
                $filename = $1 if ($source =~ /\/([^\/]+)$/);
            }
            warn "\$filename=$filename";
            my $mimetype = $mimemap->{lc ($1)} if $filename =~ m/\.([^.]+)$/i;
            warn "$filename is mimetype \"$mimetype\"" if $DEBUG;
            my $dberror = PutPatronImage($cardnumber,$mimetype, $imgfile) if $mimetype;
            close (IMG);
	    if ( !$dberror && $mimetype ) { # Errors from here on are fatal only to the import of a particular image, so don't bail, just note the error and keep going
	        $count{count}++;
	        push @{ $count{filenames} }, { source => $filename, cardnumber => $cardnumber };
	    } elsif ( $dberror ) {
                warn "Database returned error: $dberror";
                ($dberror =~ /patronimage_fk1/) ? $filerrors{'IMGEXISTS'} = 1 : $filerrors{'DBERR'} = 1;
                push my @filerrors, \%filerrors;
	        push @{ $count{filenames} }, { filerrors => \@filerrors, source => $filename, cardnumber => $cardnumber };
                $template->param( ERRORS => 1 );
            } elsif ( !$mimetype ) {
                warn "Unable to determine mime type of $filename. Please verify mimetype and add to \%mimemap if necessary.";
                $filerrors{'MIMERR'} = 1;
                push my @filerrors, \%filerrors;
	        push @{ $count{filenames} }, { filerrors => \@filerrors, source => $filename, cardnumber => $cardnumber };
                $template->param( ERRORS => 1 );
            }
        } else {
            warn "Opening $dir/$filename failed!";
            $filerrors{'OPNERR'} = 1;
            push my @filerrors, \%filerrors;
	    push @{ $count{filenames} }, { filerrors => \@filerrors, source => $filename, cardnumber => $cardnumber };
            $template->param( ERRORS => 1 );
        }
    } else {    # The need for this seems a bit unlikely, however, to maximize error trapping it is included
        warn "Missing " . ($cardnumber ? "filename" : ($filename ? "cardnumber" : "cardnumber and filename"));
        $filerrors{'CRDFIL'} = ($cardnumber ? "filename" : ($filename ? "cardnumber" : "cardnumber and filename")); 
        push my @filerrors, \%filerrors;
	push @{ $count{filenames} }, { filerrors => \@filerrors, source => $filename, cardnumber => $cardnumber };
        $template->param( ERRORS => 1 );
    }
    return %count;
}

=back

=head1 AUTHORS

Original contributor(s) undocumented

Database storage, single patronimage upload option, and extensive error trapping contributed by Chris Nighswonger cnighswonger <at> foundations <dot> edu

=cut
