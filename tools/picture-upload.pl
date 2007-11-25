#!/usr/bin/perl

use File::Temp;
use File::Copy;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;

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

my $uploadfilename = $input->param( 'uploadfile' );
my $uploadfile = $input->upload( 'uploadfile' );
my ( $total, $handled, @counts );

if ( $uploadfile ) {
    my $dirname = File::Temp::tempdir( CLEANUP => 1);
    my ( $tfh, $tempfile ) = File::Temp::tempfile( SUFFIX => '.zip', UNLINK => 1 );
    my ( @directories, %errors );

    $errors{'NOTZIP'} = 1 unless ( $uploadfilename =~ /\.zip$/i );
    $errors{'NOWRITETEMP'} = 1 unless ( -w "$dirname" );
    $errors{'NOWRITEDEST'} = 1 unless ( -w "$destdir" );
    $errors{'EMPTYUPLOAD'} = 1 unless ( length( $uploadfile ) > 0 );

    if ( %errors ) {
	$template->param( ERRORS => [ \%errors ] );
    } else {
	while ( <$uploadfile> ) {
	    print $tfh $_;
	}

	close $tfh;

	`unzip $tempfile -d $dirname`;

	push @directories, "$dirname";
	foreach $recursive_dir ( @directories ) {
	    opendir $dir, $recursive_dir;
	    while ( my $entry = readdir $dir ) {
		push @directories, "$recursive_dir/$entry" if ( -d "$recursive_dir/$entry" and $entry !~ /^\./ );
	    }
	    closedir $dir;
	}

	foreach my $dir ( @directories ) {
	    $handled += handle_dir( $dir );
	}

	$total = scalar @directories;

	$template->param(
			 TOTAL => $total,
			 HANDLED => $handled,
			 COUNTS => \@counts,
			 );
    }
}

output_html_with_http_headers $input, $cookie, $template->output;


sub handle_dir {
    my ( $dir ) = @_;
    my ( %count );
    $count{filenames} = ();

    return 0 unless ( -r "$dir/IDLINK.TXT" or -r "$dir/DATALINK.TXT" );

    my $file = ( -r "$dir/IDLINK.TXT" ) ? "$dir/IDLINK.TXT" : "$dir/DATALINK.TXT";

    open $fh, $file or { print "Openning $dir/$filename failed!\n" and return 0 };

    while (my $line = <$fh>) {
	chomp $line;

	my ( $filename, $cardnumber );

	my $delim = ($line =~ /\t/) ? "\t" : ",";

	($cardnumber, $filename) = split $delim, $line;
	$cardnumber =~ s/[\"\r\n]//g;  # remove offensive characters
	$filename =~ s/[\"\r\n]//g;

	if ($cardnumber && $filename) {
	    my $result = move ( "$dir/$filename", "$destdir/$cardnumber.jpg" );
	    if ( $result ) {
		$count{count}++;
		push @{ $count{filenames} }, { source => $filename, dest => $cardnumber .".jpg" };
	    }
	}
    }
    $count{source} = $dir;
    $count{dest} = $destdir;
    push @counts, \%count;

    close $fh;

    return 1;
}
