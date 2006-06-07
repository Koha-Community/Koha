#!/usr/bin/perl
# NOTE: This file uses standard 8-space tabs
#       DO NOT SET TAB SIZE TO 4

# $Id$

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz


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
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::Members;
use C4::Koha;
use HTML::Template;
use Date::Manip;
use C4::Date;
use C4::Input;
use C4::Log;
my $input = new CGI;
my $dbh = C4::Context->dbh;
my %data;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/borrowers_details.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $data;
my $categorycode=$input->param('categorycode');
my $borrowernumber=$input->param('borrowernumber');
my $description=$input->param('description');
my $category_type=$input->param('category_type');

 if ( $data{'surname'} eq '') 
 	{
 		$data=borrdata('',$borrowernumber);
 		%data=%$data;
 	}
 my ($category_type,$description) = getcategorytype($data{'categorycode'});	

$template->param(		borrowernumber  => $borrowernumber,#register number
				#transform value  in capital or capital for first letter of the word
 				firstname       => ucfirst($data{'firstname'}),
 				surname         => uc($data{'surname'}),
 				categorycode 	=> $data{'categorycode'},
				title 		=> $data{'title'},
				category_type	=> $category_type,
	# # 			
 				"title_".$data{'title'} 	    => " SELECTED ",			
 				dateofbirth	=> format_date($data{'dateofbirth'}),
 				description	=>$description
# 				
				);
	$template->param(Institution => 1) if ($category_type eq "I");
	output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End: