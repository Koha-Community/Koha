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

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Members;
use Module::Load;
use Koha::Patrons;
use Koha::Token;

if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
    load Koha::NorwegianPatronDB, qw( NLMarkForDeletion NLSync );
}

my $input = new CGI;

my ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "members/deletemem.tt",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired => {borrowers => 'edit_borrowers'},
                                        debug => 1,
                                        });

#print $input->header;
my $member       = $input->param('member');

#Do not delete yourself...
if ($borrowernumber == $member ) {
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_YOURSELF");
    exit 0; # Exit without error
}

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

my $patron = Koha::Patrons->find( $member );
unless ( $patron ) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$member");
    exit;
}
my $flags = C4::Members::patronflags( $patron->unblessed );
my $userenv = C4::Context->userenv;

 

if ($patron->category->category_type eq "S") {
    unless(C4::Auth::haspermission($userenv->{'id'},{'staffaccess'=>1})) {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_STAFF");
        exit 0; # Exit without error
    }
} else {
    unless(C4::Auth::haspermission($userenv->{'id'},{'borrowers'=>'edit_borrowers'})) {
	print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE");
        exit 0; # Exit without error
    }
}

if (C4::Context->preference("IndependentBranches")) {
    my $userenv = C4::Context->userenv;
    if ( !C4::Context->IsSuperLibrarian() && $patron->branchcode){
        unless ($userenv->{branch} eq $patron->branchcode){
            print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_OTHERLIBRARY");
            exit 0; # Exit without error
        }
    }
}

my $op = $input->param('op') || 'delete_confirm';
my $dbh = C4::Context->dbh;
my $is_guarantor = $dbh->selectrow_array("SELECT COUNT(*) FROM borrowers WHERE guarantorid=?", undef, $member);
if ( $op eq 'delete_confirm' or $countissues > 0 or $flags->{'CHARGES'}  or $is_guarantor or $deletelocal == 0) {
    $template->param( picture => 1 ) if $patron->image;

    $template->param( adultborrower => 1 ) if $patron->category->category_type =~ /^(A|I)$/;

    $template->param(
        # FIXME The patron object should be passed to the template
        borrowernumber => $patron->borrowernumber,
        surname => $patron->surname,
        title => $patron->title,
        cardnumber => $patron->cardnumber,
        firstname => $patron->firstname,
        categorycode => $patron->categorycode,
        category_type => $patron->category->category_type,
        categoryname  => $patron->category->description,
        address => $patron->address,
        address2 => $patron->address2,
        city => $patron->city,
        zipcode => $patron->zipcode,
        country => $patron->country,
        phone => $patron->phone,
        email => $patron->email,
        branchcode => $patron->branchcode,
    );
    if ($countissues >0) {
        $template->param(ItemsOnIssues => $countissues);
    }
    if ($flags->{'CHARGES'} ne '') {
        $template->param(charges => $flags->{'CHARGES'}->{'amount'});
    }
    if ($is_guarantor) {
        $template->param(guarantees => 1);
    }
    if ($deletelocal == 0) {
        $template->param(keeplocal => 1);
    }
    # This is silly written but reflect the same conditions as above
    if ( not $countissues > 0 and not $flags->{CHARGES} ne '' and not $is_guarantor and not $deletelocal == 0 ) {
        $template->param(
            op         => 'delete_confirm',
            csrf_token => Koha::Token->new->generate_csrf({ session_id => scalar $input->cookie('CGISESSID') }),
        );
    }
} elsif ( $op eq 'delete_confirmed' ) {

    die "Wrong CSRF token"
        unless Koha::Token->new->check_csrf( {
            session_id => $input->cookie('CGISESSID'),
            token  => scalar $input->param('csrf_token'),
        });
    my $patron = Koha::Patrons->find( $member );
    $patron->move_to_deleted;
    $patron->delete;
    # TODO Tell the user everything went ok
    print $input->redirect("/cgi-bin/koha/members/members-home.pl");
    exit 0; # Exit without error
}

output_html_with_http_headers $input, $cookie, $template->output;
