#!/usr/bin/perl
# WARNING: Not enough context to figure out the correct tabstop size
# WARNING: Assume that this file uses 4-character tabs

# $Id$

#written 11/1/2000 by chris@katipo.oc.nz
#part of the koha library system, script to facilitate paying off fines


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
use C4::Context;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::Date;
use C4::Members;
my $input=new CGI;

#print $input->header;
my $bornum=$input->param('bornum');

#get borrower details
my $data=borrdata('',$bornum);
#my $user=C4::Context->preference('defaultbranch');
my $amount=$input->param('amount');
my $accounttype=$input->param('accounttype');
my $desc=$input->param('desc');

if ($accounttype eq "FU"){
$accounttype="Overdue item";
}elsif ($accounttype eq "L"){
$accounttype="Very Overdue or Lost item";
}else{
$accounttype="Miscelenaous Fees";
}
	my($template, $loggedinuser, $cookie)
		= get_template_and_user ({ template_name => "members/payprint.tmpl",
					   query => $input,
					   type => "intranet",
					   authnotrequired => 0,
					   flagsrequired => {borrowers => 1},
					   debug => 1,
					 });
	my $user=borrdata('',$loggedinuser);
my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
	$template->param(firstname => $data->{'firstname'}, date=>format_date($todaysdate),
							surname => $data->{'surname'},
							cardnumber => $data->{'cardnumber'},
							street => $data->{'street'},
							city => $data->{'city'},
							phone => $data->{'phone'},
							email => $data->{'email'},
							amount=> $amount,
							desc=> $desc,
							accounttype=> $accounttype,
							bornum=>$bornum,
							loggeduser=>$user->{'firstname'}.' '.$user->{'surname'},
							);
	output_html_with_http_headers $input, $cookie, $template->output;



# Local Variables:
# tab-width: 4
# End:
