#!/usr/bin/perl


# script to upload a picture to a borrowerimages directory.
# checks to see if its either displaying the upload form
# or doing the actual upload.
# written by Waylon Robertson (genjimoto@sourceforge) 2005/08/22


# Copyright 2000-2002 Katipo Communications
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

use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;


my $input = new CGI;
my $name = $input->param('name');
my $borrowernumber = $input->param('borrowernumber');
my $photo = $input->param('photo');

my $template_name;
my $htdocs = C4::Context->config('intrahtdocs');
my $upload_dir = $htdocs."/borrowerimages";
if($photo eq  ""){
	$template_name = "members/member-picupload.tmpl";
} else {
	$template_name = "members/moremember.tmpl";
}

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => $template_name,
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });
if ($photo){

	my $filename=$borrowernumber.'.jpg';
	my $upload_filehandle = $input->upload("photo");
	open UPLOADFILE, ">$upload_dir/$filename";
	binmode UPLOADFILE;
	while ( <$upload_filehandle> )
	{
		print UPLOADFILE;
	}
	close UPLOADFILE;
}
else {
	$template->param(
		 borrowernumber => $borrowernumber,
		 name => $name
		 );
	output_html_with_http_headers $input, $cookie, $template->output;
}
print $input->redirect("http://intranet/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
