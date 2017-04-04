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

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Members;
use C4::Auth;
use Koha::Patrons;


my $input = new CGI;

my ( $loggedinuser ) = checkauth($input, 0, { borrowers => 'edit_borrowers' }, 'intranet');

my $destination = $input->param("destination") || '';
my $borrowernumber=$input->param('borrowernumber');
my $status = $input->param('status');
my $reregistration = $input->param('reregistration') || '';

my $dbh = C4::Context->dbh;
my $dateexpiry;

my $logged_in_user = Koha::Patrons->find( $loggedinuser ) or die "Not logged in";
my $patron         = Koha::Patrons->find( $borrowernumber );

# Ideally we should display a warning on the interface if the logged in user is
# not allowed to modify this patron.
# But a librarian is not supposed to hack the system
unless ( $logged_in_user->can_see_patron_infos($patron) ) {
    if ( $reregistration eq 'y' ) {
        # re-reregistration function to automatic calcul of date expiry
        $dateexpiry = $patron->renew_account;
    } else {
        my $sth = $dbh->prepare("UPDATE borrowers SET debarred = ?, debarredcomment = '' WHERE borrowernumber = ?");
        $sth->execute( $status, $borrowernumber );
        $sth->finish;
    }
}

if($destination eq "circ"){
    if($dateexpiry){
        print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber&was_renewed=1");
    } else {
        print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    }
} else {
    if($dateexpiry){
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber&was_renewed=1");
    } else {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
    }
}
