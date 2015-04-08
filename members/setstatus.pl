#!/usr/bin/perl

#script to set or lift debarred status
#written 2/8/04
#by oleonard@athenscounty.lib.oh.us


# Copyright 2000-2002 Katipo Communications
# Parts copyright 2010 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use CGI;
use C4::Context;
use C4::Members;
use C4::Auth;


my $input = new CGI;

checkauth($input, 0, { borrowers => 1 }, 'intranet');

my $destination = $input->param("destination") || '';
my $cardnumber = $input->param("cardnumber");
my $borrowernumber=$input->param('borrowernumber');
my $status = $input->param('status');
my $reregistration = $input->param('reregistration') || '';

my $dbh = C4::Context->dbh;
my $dateexpiry;

if ( $reregistration eq 'y' ) {
	# re-reregistration function to automatic calcul of date expiry
	$dateexpiry = ExtendMemberSubscriptionTo( $borrowernumber );
} else {
    my $sth = $dbh->prepare("UPDATE borrowers SET debarred = ?, debarredcomment = '' WHERE borrowernumber = ?");
    $sth->execute( $status, $borrowernumber );
	$sth->finish;
	}

if($destination eq "circ"){
	if($dateexpiry){
        print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$cardnumber&was_renewed=1");
	} else {
		print $input->redirect("/cgi-bin/koha/circ/circulation.pl?findborrower=$cardnumber");
	}
} else {
	if($dateexpiry){
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber&was_renewed=1");
	} else {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
	}
}
