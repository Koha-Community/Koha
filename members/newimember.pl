#!/usr/bin/perl
# Note: This file now uses standard 8-space tabs

# $Id$

#script to print confirmation screen,
#then if accepted calls itself to insert data
#modified 2002/12/16 by hdl@ifrance.com : Templating
#the "parent" is imemberentry.pl


# Copyright 2000-2003 Katipo Communications
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
use C4::Output;
use C4::Input;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Members;
use CGI;
use Date::Manip;
use HTML::Template;

my %env;
my $input = new CGI;
#get varibale that tells us whether to show confirmation page
#or insert data
my $insert=$input->param('insert');

my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name => "members/newimember.tmpl",
	query => $input,
	type => "intranet",
	authnotrequired => 0,
	flagsrequired => {borrowers => 1},
	debug => 1,
  });

#get rest of data
my %data;
my @names=$input->param;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}

my $missing=0;

my $string="The following compulsary fields have been left blank. Please push the back button
and try again<p>";
if ($data{'cardnumber_institution'} !~ /\S/){
  $string.="Cardnumber<br>";
  $missing=1;
}
if ($data{'institution_name'} !~ /\S/){
  $string.="Institution Name<br>";
  $missing=1;
}
if ($data{'address'} !~ /\S/){
  $string.="Postal Address<br>";
  $missing=1;
}
if ($data{'city'} !~ /\S/){
  $string.="City<br>";
  $missing=1;
}
if ($data{'contactname'} !~ /\S/){
  $string.="Contact Name";
  $missing=1;
}

$template->param( missingloop => ($missing==1));
$template->param( string => $string);
if ($missing !=1) {
    $data{'cardnumber_institution'} = C4::Members::fixup_cardnumber
	    ($data{'cardnumber_institution'});

    #check cardnumber is valid
    my $nounique;
    if ( $data{'type'} ne "Add" )    {
	$nounique = 0;
    } else {
	$nounique = 1;
    }
    my $valid=checkdigit(\%env,$data{'cardnumber'}, $nounique);

    $template->param( invalid => ($valid !=1));

    if ($valid) {
	my @inputs;
	while (my ($key, $value) = each %data) {
	    push(@inputs, { 'key'	=> $key,
			    'value'	=> CGI::escapeHTML($value) });
	}
    $template->param(institution_name => $data{institution_name},
		     bornum => $data{'borrowernumber'},
		     cardnumber_institution => $data{'cardnumber_institution'},
		     memcat => $data{'categorycode'},
		     branchcode => $data{'branchcode'},
		     sex => $data{sex},
		     postal => $data{postal},
		     home => $data{home},
			zipcode => $data{'zipcode'},
			homezipcode => $data{'homezipcode'},
		     phone => $data{'phone'},
		     phoneday => $data{'phoneday'},
		     faxnumber => $data{'faxnumber'},
		     emailaddress => $data{'emailaddress'},
			textmessaging => $data{'textmessaging'},
		     contactname => $data{'contactname'},
		     altphone => $data{'altphone'},
		     altrelationship => $data{'altrelationship'},
		     altnotes => $data{'altnotes'},
		     bornotes => $data{'borrowernotes'},
		     inputsloop => \@inputs);
    }
}
output_html_with_http_headers $input, $cookie, $template->output;


# Local Variables:
# tab-width: 8
# End:
