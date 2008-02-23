#!/usr/bin/perl

use File::Temp;
use File::Copy;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use Data::Dumper;

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

my $uploadfilename = $input->param( 'uploadfile' );
my $uploadfile = $input->upload( 'uploadfile' );
my ( $total, $handled, @counts );

if ( $uploadfile ) {
    my $dirname = File::Temp::tempdir( CLEANUP => 1);
    warn "dirname = $dirname" if $DEBUG;
    my ( $tfh, $tempfile ) = File::Temp::tempfile( SUFFIX => '.zip', UNLINK => 1 );
    warn "tempfile = $tempfile" if $DEBUG;
    my ( @directories, $errors );

    $errors{'NOTZIP'} = 1 unless ( $uploadfilename =~ /\.zip$/i );
    $errors{'NOWRITETEMP'} = 1 unless ( -w $dirname );
    $errors{'EMPTYUPLOAD'} = 1 unless ( length( $uploadfile ) > 0 );

    if ( %errors ) {
	$template->param( ERRORS => [ \%errors ] );
    } else {
	while ( <$uploadfile> ) {
	    print $tfh $_;
        }

        close $tfh;

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
            $results = handle_dir( $dir );
            $handled++ if $results == 1;
        }

        if ( %$results || %errors ) {
            $template->param( ERRORS => [ \%$results ] );
        } else {
            $total = scalar @directories;
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
}

output_html_with_http_headers $input, $cookie, $template->output;

sub handle_dir {
    warn "Entering sub handle_dir" if $DEBUG;
    my ( $dir ) = @_;
    my ( %count );
    my $file;
    $count{filenames} = ();

    my $mimemap = {
        "gif"   => "image/gif",
        "jpg"   => "image/jpeg",
        "jpeg"  => "image/jpeg",
        "png"   => "image/png"
    };
    
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
        my ( $filename, $cardnumber );
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
	if ($cardnumber && $filename) {
            my %filerrors;
            warn "Source: $dir/$filename" if $DEBUG;
            if (open (IMG, "$dir/$filename")) {
                #binmode (IMG); # Not sure if we need this or not -fbcit
                my $imgfile;
                while (<IMG>) {
                    $imgfile .= $_;
                }
                my $mimetype = $mimemap->{lc ($1)} if $filename =~ m/\.([^.]+)$/i;
                warn "$filename is mimetype \"$mimetype\"" if $DEBUG;
                my $dberror = PutPatronImage($cardnumber,$mimetype, $imgfile) if $mimetype;
                close (IMG);
	        if ( !$dberror && $mimetype ) { # Errors from here on are fatal only to the import of a particular image, so don't bail, just note the error and keep going
	            $count{count}++;
	            push @{ $count{filenames} }, { source => $filename, cardnumber => $cardnumber };
	        } elsif ( $dberror ) {
                    warn "Database returned error. We're not logging it because it most likely contains binary data which does unpleasent things to terminal windows and logs.";
                    $filerrors{'DBERR'} = 1;
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
	}
    }
    $count{source} = $dir;
    push @counts, \%count;
    close FILE;
    closedir ( $dirhandle );
    return 1;
}
