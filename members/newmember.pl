#!/usr/bin/perl

# $Id$

#script to print confirmation screen, then if accepted calls itself to insert data
# FIXME - Yes, but what does it _do_?
# 2002/12/18 hdl@ifrance.com templating

# 2003/01/20 acli@ada.dhs.org XXX it seems to do the following:
# * "insert" seems to do nothing; in 1.2.2 the script just returns a blank
#   page (with the headers etc.) if "insert" has anything in it
# * $ok has the opposite meaning of what one expects; $ok == 1 means "not ok"
# * if ($ok == 0) considers the "ok" case; it displays a confirmation page
#   for the user to "click to confirm that everything is entered correctly"
# * The "else" case for ($ok == 0) handles the "not ok" case; $string is the
#   error message to display

# FIXME - What is the correct value of "flagsrequired"?

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
use C4::Input;
use C4::Interface::CGI::Output;
use CGI;
use Date::Manip;
use HTML::Template;
use C4::Date;
my %env;
my $input = new CGI;

#get rest of data
my %data;
my @names=$input->param;
foreach my $key (@names){
  $data{$key}=$input->param($key);
}

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "newmember.tmpl",
			     query => $input,
                             type => "intranet",
                             authnotrequired => 0,
                             flagsrequired => {parameters => 1},
                         });

#Get the database handle
my $dbh = C4::Context->dbh;

# Check that all compulsary fields are entered
# If everything is ok, set $ok = 0
# Otherwise set $ok = 1 and $string to the error message to display.

my $ok=0;
my $string = "The following compulsary fields have been left blank. "
	. "Please push the back button and try again<p>";
my @errors;
if ($data{'cardnumber'} eq ''){
	push @errors,"cardnumber";
    $ok=1;
} else {
    #check cardnumber is valid
    my $nounique;
    if ( $data{'type'} eq "Add" )    {
	$nounique = 0;
    } else {
	$nounique = 1;
    }
    my $valid=checkdigit(\%env,$data{'cardnumber'}, $nounique);
    if ($valid != 1){
        $ok=1;
    	push @errors, "invalid_cardnumber";
    }
}
if ($data{'sex'} eq ''){
    push @errors, "gender";
    $ok=1;
}
if ($data{'firstname'} eq ''){
    push @errors,"firstname";
    $ok=1;
}
if ($data{'surname'} eq ''){
    push @errors,"surname";
    $ok=1;
}
if ($data{'address'} eq ''){
    push @errors, "address";
    $ok=1;
}
if ($data{'city'} eq ''){
    push @errors, "city";
    $ok=1;
}

# Pass the ok/not ok status and the error message to the template
$template->param(	OK=> ($ok==0));
foreach my $error (@errors) {
	$template->param( $error => 1);
}

# If things are ok, display the confirmation page
if ($ok == 0) {
    my $name=$data{'title'}." ";
    if ($data{'othernames'} ne ''){
	$name.=$data{'othernames'}." ";
    } else {
	$name.=$data{'firstname'}." ";
    }
    $name.="$data{'surname'} ( $data{'firstname'}, $data{'initials'})";
    my $sex;
    if ($data{'sex'} eq 'M'){
	$sex=1;
    } else {
	$sex=0;
    }
    if ($data{'joining'} eq ''){
	$data{'joining'}=ParseDate('today');
	$data{'joining'}=format_date($data{'joining'});
    }
    if ($data{'expiry'} eq ''){
    	my $get_enrolmentperiod = $dbh->prepare(q{SELECT enrolmentperiod FROM categories WHERE categorycode = ?});
	$get_enrolmentperiod->execute($data{'categorycode'});
	my ( $period ) = $get_enrolmentperiod->fetchrow;
	if ( ($period)  && ($period != 1))
	{
		$data{'expiry'}=ParseDate("in $period years");
		$data{'expiry'}=format_date($data{'expiry'});
	}
	else
	{
		$data{'expiry'}=ParseDate('in 1 year');
		$data{'expiry'}=format_date($data{'expiry'});
	}
    }
    my $ethnic=$data{'ethnicity'}." ".$data{'ethnicnotes'};
    my $postal=$data{'address'}."<br>".$data{'city'};
    my $home;
    if ($data{'streetaddress'} ne ''){
	$home=$data{'streetaddress'}."<br>".$data{'streetcity'};
    } else {
	$home=$postal;
    }
    my @inputsloop;
    while (my ($key, $value) = each %data) {
	$value=~ s/\"/%22/g;
	my %line;
	$line{'key'}=$key;
	$line{'value'}=$value;
	push(@inputsloop, \%line);
    }

    #Get the fee
    my $sth = $dbh->prepare("SELECT enrolmentfee FROM categories WHERE categorycode = ?");
    $sth->execute($data{'categorycode'});
    my ($fee) = $sth->fetchrow;
    $sth->finish;

    $template->param(name => $name,
		     bornum => $data{'borrowernumber'},
		     cardnum => $data{'cardnumber'},
		     memcat => $data{'categorycode'},
		     fee => $fee,
		     joindate => format_date($data{'joining'}),
		     expdate => format_date($data{'expiry'}),
		     branchcode => $data{'branchcode'},
		     ethnic => $ethnic,
		     dob => format_date($data{'dateofbirth'}),
		     sex => $sex,
		     postal => $postal,
		     home => $home,
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
		     inputsloop => \@inputsloop);

# If things are not ok, display the error message
} else {
    # Nothing to do; the "OK" and "string" variables have already been set
    ;
}

output_html_with_http_headers $input, $cookie, $template->output;


