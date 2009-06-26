#!/usr/bin/perl

#script to delete items
#written 2/5/00
#by chris@katipo.co.nz

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
# use warnings; # FIXME

use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Members;

my $input = new CGI;

my ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "members/deletemem.tmpl",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired => {borrowers => 1},
                                        debug => 1,
                                        });

#print $input->header;
my $member=$input->param('member');
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
}

if (C4::Context->preference("IndependantBranches")) {
    my $userenv = C4::Context->userenv;
    if (($userenv->{flags} % 2 != 1) && $bor->{'branchcode'}){
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
if ($countissues > 0 or $flags->{'CHARGES'}  or $data->{'borrowernumber'}){
    #   print $input->header;
    $template->param(borrowernumber => $member);
    if ($countissues >0) {
        $template->param(ItemsOnIssues => $countissues);
    }
    if ($flags->{'CHARGES'} ne '') {
        $template->param(charges => $flags->{'CHARGES'}->{'amount'});
    }
    if ($data) {
        $template->param(guarantees => 1);
    }
output_html_with_http_headers $input, $cookie, $template->output;

} else {
    MoveMemberToDeleted($member);
    DelMember($member);
    print $input->redirect("/cgi-bin/koha/members/members-home.pl");
}


