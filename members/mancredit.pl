#!/usr/bin/perl

#wrriten 18/09/2005 by TG
#script to display borrowers account details


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
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;

use C4::Search;
use C4::Accounts2;
use C4::Members;
my $input=new CGI;
  my $accounttype=$input->param('accounttype');
 my $accountid=$input->param('accountid');
my $amount=$input->param('amount');
my $itemnum=$input->param('itemnum');
my $error=0;
my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my $user=$data->{firstname}.",".$data->{surname}."-".$data->{cardnumber};
my $add=$input->param('add');
# $error=$input->param('error');
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "members/mancredit.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {borrowers => 1},
					debug => 1,
					});
	$template->param(user => $user);
	$template->param( bornum => $bornum);
	$template->param( itemnum => $itemnum);
	$template->param( amount => $amount);
	$template->param( accounttype => $accounttype);
	$template->param( accountid => $accountid);
if ($add){
if ($accounttype eq "F" || $accounttype eq "FU"){
$accounttype="CF";
}else{
$accounttype="C".$accounttype;
}
	
  my $desc=$input->param('desc');
  my $amount=$input->param('amount');
  $amount = -$amount;
my $loggeduser=$input->param('loggedinuser');
my   $error=manualcredit($bornum,$accountid,$desc,$accounttype,$amount,$loggeduser);
	if ($error>0 ) {
	$template->param( error => "1");
	$template->param(user => $user);
	$template->param( bornum => $bornum);
	$template->param( itemnum => $itemnum);
	$template->param( amount => $amount);
	$template->param( accounttype => $accounttype);
	$template->param( accountid => $accountid);
	} else {
	print $input->redirect("/cgi-bin/koha/members/boraccount.pl?bornum=$bornum");
	}
} 
	

output_html_with_http_headers $input, $cookie, $template->output;
