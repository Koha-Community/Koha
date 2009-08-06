#!/usr/bin/perl
# WARNING: 4-character tab stops here

# Copyright 2009 Biblibre

use warnings;

use CGI;
use C4::Output;
use C4::Auth;
use C4::Context;
use C4::Branch;

my $query        = new CGI;
my $upload_dir = "/home/koha/bdp/"; 

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "biblibre/import_bdp.tmpl",
            query           => $query,
            type            => 'intranet',
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
        }
    );


my $branches=GetBranches();
my @branchloop;
foreach (keys %$branches) {
	my %row = (
	    branchcode => $_,
		branchname => $branches->{$_}->{'branchname'},
	);
	push @branchloop, \%row;
}


$template->param(
    branches => \@branchloop,
);


my $test = $query->param('test');
my $log;
my $filename;

if ( $query->param("import") ) {
    $filename   = $query->param("bdpfile");
    my $branchcode = $query->param('branchcode');
    
	my $upload_filehandle = $query->upload("bdpfile");
	
	open UPLOADFILE, ">$upload_dir/$filename";
	binmode UPLOADFILE;
	while ( <$upload_filehandle> )
	{
		print UPLOADFILE;
	}
	close UPLOADFILE;
	
	my $importscript = C4::Context->preference('BDPImportScript');
	if($importscript && $importscript =~ /^$upload_dir/){
        my @command;
        push @command, $importscript;
        push @command, "-s";
        push @command, $branchcode;
        push @command, "-file";
        push @command, "$upload_dir/$filename";
        
        push @command, "-t " if ($test);
        $log = qx(@command);
    
        $log =~ s/\n/<br \/>/g;
        
        $template->param(
            filename => $filename,
            uploaded => 1,
            log => $log, 
        );
	}
}elsif($query->param("retour")){
    $filename = $query->param("retourbdpfile");
    my $upload_filehandle = $query->upload("retourbdpfile");
	
	open UPLOADFILE, ">$upload_dir/$filename";
	binmode UPLOADFILE;
	while ( <$upload_filehandle> )
	{
		print UPLOADFILE;
	}
	close UPLOADFILE;
	
	my $retourscript = C4::Context->preference('BDPRetourScript');
	if($retourscript && $retourscript =~ /^$upload_dir/){
        my @command;
        push @command, $retourscript;
        push @command, "-file";
        push @command, "$upload_dir/$filename";
    	
        push @command, "-t" if ($test);
        push @command, "-v";
        
        $log = qx(@command);
    
        $log =~ s/\n/<br \/>/g;
        
        $template->param(
            filename => $filename,
            uploaded => 1,
            log => $log, 
        );	
	}
}
# Print the page
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
