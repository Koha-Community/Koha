#!/usr/bin/perl

#script to set or lift debarred status
#written 2/8/04
#by oleonard@athenscounty.lib.oh.us


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

use CGI;
use C4::Context;
use C4::Members;
use C4::Auth;


my $input = new CGI;

my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

my $destination = $input->param("destination");
my $cardnumber = $input->param("cardnumber");
my $borrowernumber=$input->param('borrowernumber');
my $status = $input->param('status');
my $reregistration = $input->param('reregistration');

my $dbh = C4::Context->dbh;
my $dateexpiry;

if ( $reregistration eq 'y' ) {
	# re-reregistration function to automatic calcul of date expiry
	$dateexpiry = ExtendMemberSubscriptionTo( $borrowernumber );
} else {
	my $sth=$dbh->prepare("Update borrowers set debarred = ? where borrowernumber = ?");
	$sth->execute($status,$borrowernumber);	
	$sth->finish;
	}

if($destination eq "circ"){
	if($dateexpiry){
		print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$cardnumber&dateexpiry=$dateexpiry");
	} else {
		print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$cardnumber");
	}
} else {
	if($dateexpiry){
		print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$borrowernumber&dateexpiry=$dateexpiry");
	} else {
		print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$borrowernumber");
	}
}
