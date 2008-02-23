#!/usr/bin/perl

use File::Temp;
use File::Copy;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;

my $DEBUG = ($ENV{DEBUG}) ? 1 : 0;

#my $destdir = "/usr/local/koha/intranet/htdocs/intranet-tmpl/images/patronpictures";
#my $uploadfile = shift @ARGV;
my $input = new CGI;
my $destdir = C4::Context->config('intrahtdocs') . "/patronimages";

warn "DEST : $destdir";
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "tools/picture-upload.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {management => 1, tools => 1},
					debug => 0,
					});

unless (-d $destdir) {
	$errors{'NODIR'} = 1;
	warn "patronimages directory not present";
}
if ( %errors ) {
    $template->param( ERRORS => [ \%errors ] );
}
my $uploadfilename = $input->param( 'uploadfile' );
my $uploadfile = $input->upload( 'uploadfile' );
my ( $total, $handled, @counts );

if ( $uploadfile ) {
    my $dirname = File::Temp::tempdir( CLEANUP => 1);
    warn "dirname = $dirname" if $DEBUG;
    my ( $tfh, $tempfile ) = File::Temp::tempfile( SUFFIX => '.zip', UNLINK => 1 );
    warn "tempfile = $tempfile" if $DEBUG;
    my ( @directories, %errors );

    $errors{'NOTZIP'} = 1 unless ( $uploadfilename =~ /\.zip$/i );
    $errors{'NOWRITETEMP'} = 1 unless ( -w $dirname );
    $errors{'NOWRITEDEST'} = 1 unless ( -w $destdir );
    $errors{'EMPTYUPLOAD'} = 1 unless ( length( $uploadfile ) > 0 );

    if ( %errors ) {
	$template->param( ERRORS => [ \%errors ] );
    } else {
	while ( <$uploadfile> ) {
	    print $tfh $_;
	}

	close $tfh;

	system("unzip $tempfile -d $dirname");

	push @directories, "$dirname";
	foreach $recursive_dir ( @directories ) {
	    opendir $dir, $recursive_dir;
	    while ( my $entry = readdir $dir ) {
			push @directories, "$recursive_dir/$entry" if ( -d "$recursive_dir/$entry" and $entry !~ /^\./ );
                        warn "$recursive_dir/$entry" if $DEBUG;
	    }
	    closedir $dir;
	}

	foreach my $dir ( @directories ) {
	    $handled += handle_dir( $dir );
	}

	$total = scalar @directories;
        warn "Total files processed: $total" if $DEBUG;
	$template->param(
			 TOTAL => $total,
			 HANDLED => $handled,
			 COUNTS => \@counts,
			 TCOUNTS => scalar(@counts),
			 );
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
		warn "Opening $dir/$file failed!" if $DEBUG;
		return 0;
	};

    while (my $line = <FILE>) {
        warn "Reading contents of $file" if $DEBUG;
	chomp $line;
        warn "Examining line: $line" if $DEBUG;
        my ( $filename, $cardnumber );
	my $delim = ($line =~ /\t/) ? "\t" : ",";
        warn "Delimeter is \'$delim\'" if $DEBUG;
	($cardnumber, $filename) = split $delim, $line;
	$cardnumber =~ s/[\"\r\n]//g;  # remove offensive characters
	$filename   =~ s/[\"\r\n\s]//g;
        warn "Cardnumber: $cardnumber Filename: $filename" if $DEBUG;
	if ($cardnumber && $filename) {
            warn "Source: $dir/$filename" if $DEBUG;
            open (IMG, "$dir/$filename") or warn "Could not open $dir/$filename";
            #binmode (IMG); # Not sure if we need this or not -fbcit
            my $imgfile;
            while (<IMG>) {
                $imgfile .= $_;
            }
            my $mimetype = $mimemap->{lc ($1)} if $filename =~ m/\.([^.]+)$/i;
            warn "$filename is mimetype \"$mimetype\"" if $DEBUG;
            my $dberror = PutPatronImage($cardnumber,$mimetype, $imgfile) if $mimetype;
#            warn "Database says: $dberror" if $dberror;
            close (IMG);
	    unless ( $dberror || !$mimetype ) {
	        $count{count}++;
	        push @{ $count{filenames} }, { source => $filename, dest => $cardnumber };
	    }
	}
    }
    $count{source} = $dir;
    $count{dest} = $destdir;
    push @counts, \%count;
    close FILE;
    return 1;
}
