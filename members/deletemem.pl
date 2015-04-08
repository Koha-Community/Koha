#!/usr/bin/perl

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz

# Copyright 2000-2002 Katipo Communications
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
#use warnings; FIXME - Bug 2505

use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Members;
use C4::Branch; # GetBranches
use C4::VirtualShelves (); #no import
use Module::Load;
if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
    load Koha::NorwegianPatronDB, qw( NLMarkForDeletion NLSync );
}

my $input = new CGI;

my ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "members/deletemem.tt",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired => {borrowers => 1},
                                        debug => 1,
                                        });

#print $input->header;
my $member       = $input->param('member');

# Handle deletion from the Norwegian national patron database, if it is enabled
# If the "deletelocal" parameter is set to "false", the regular deletion will be
# short circuited, and only a deletion from the national database can be carried
# out. If "deletelocal" is set to "true", or not set to anything normal
# deletion will be done.
my $deletelocal  = $input->param('deletelocal')  eq 'false' ? 0 : 1; # Deleting locally is the default
if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
    if ( $input->param('deleteremote') eq 'true' ) {
        # Mark for deletion, then try a live sync
        NLMarkForDeletion( $member );
        NLSync({ 'borrowernumber' => $member });
    }
}

my $issues = GetPendingIssues($member);     # FIXME: wasteful call when really, we only want the count
my $countissues = scalar(@$issues);

my ($bor)=GetMemberDetails($member,'');
my $flags=$bor->{flags};
my $userenv = C4::Context->userenv;

 

if ($bor->{category_type} eq "S") {
    unless(C4::Auth::haspermission($userenv->{'id'},{'staffaccess'=>1})) {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_STAFF");
        exit 1;
    }
} else {
    unless(C4::Auth::haspermission($userenv->{'id'},{'borrowers'=>1})) {
	print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE");
	exit 1;
    }
}

if (C4::Context->preference("IndependentBranches")) {
    my $userenv = C4::Context->userenv;
    if ( !C4::Context->IsSuperLibrarian() && $bor->{'branchcode'}){
        unless ($userenv->{branch} eq $bor->{'branchcode'}){
            print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_OTHERLIBRARY");
            exit;
        }
    }
}

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("Select * from borrowers where guarantorid=?");
$sth->execute($member);
my $data=$sth->fetchrow_hashref;
if ($countissues > 0 or $flags->{'CHARGES'}  or $data->{'borrowernumber'} or $deletelocal == 0){
    #   print $input->header;

    my ($picture, $dberror) = GetPatronImage($bor->{'borrowernumber'});
    $template->param( picture => 1 ) if $picture;

    $template->param(borrowernumber => $member,
        surname => $bor->{'surname'},
        title => $bor->{'title'},
        cardnumber => $bor->{'cardnumber'},
        firstname => $bor->{'firstname'},
        categorycode => $bor->{'categorycode'},
        category_type => $bor->{'category_type'},
        categoryname  => $bor->{'description'},
        address => $bor->{'address'},
        address2 => $bor->{'address2'},
        city => $bor->{'city'},
        zipcode => $bor->{'zipcode'},
        country => $bor->{'country'},
        phone => $bor->{'phone'},
        email => $bor->{'email'},
        branchcode => $bor->{'branchcode'},
        branchname => GetBranchName($bor->{'branchcode'}),
		activeBorrowerRelationship => (C4::Context->preference('borrowerRelationship') ne ''),
        RoutingSerials => C4::Context->preference('RoutingSerials'),
    );
    if ($countissues >0) {
        $template->param(ItemsOnIssues => $countissues);
    }
    if ($flags->{'CHARGES'} ne '') {
        $template->param(charges => $flags->{'CHARGES'}->{'amount'});
    }
    if ($data->{'borrowernumber'}) {
        $template->param(guarantees => 1);
    }
    if ($deletelocal == 0) {
        $template->param(keeplocal => 1);
    }
output_html_with_http_headers $input, $cookie, $template->output;

} else {
    MoveMemberToDeleted($member);
    C4::VirtualShelves::HandleDelBorrower($member);
    DelMember($member);
    print $input->redirect("/cgi-bin/koha/members/members-home.pl");
}


