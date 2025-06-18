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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use Try::Tiny qw( catch try );

use C4::Context;
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use Koha::Patrons;
use Koha::Token;
use Koha::Patron::Categories;
use Koha::Suggestions;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/deletemem.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { borrowers => 'delete_borrowers' },
    }
);

#print $input->header;
my $member = $input->param('member');

#Do not delete yourself...
if ( $loggedinuser == $member ) {
    print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_YOURSELF");
    exit 0;    # Exit without error
}

my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $patron         = Koha::Patrons->find($member);
output_and_exit_if_error(
    $input, $cookie, $template,
    { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron }
);

my $debits      = $patron->account->outstanding_debits->total_outstanding;
my $credits     = abs $patron->account->outstanding_credits->total_outstanding;
my $countissues = $patron->checkouts->count;
my $userenv     = C4::Context->userenv;

if ( $patron->category->category_type eq "S" ) {
    unless ( C4::Auth::haspermission( $userenv->{'id'}, { 'staffaccess' => 1 } ) ) {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_STAFF");
        exit 0;    # Exit without error
    }
} else {
    unless ( C4::Auth::haspermission( $userenv->{'id'}, { 'borrowers' => 'delete_borrowers' } ) ) {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE");
        exit 0;    # Exit without error
    }
}

if ( C4::Context->preference("IndependentBranches") ) {
    my $userenv = C4::Context->userenv;
    if ( !C4::Context->IsSuperLibrarian() && $patron->branchcode ) {
        unless ( $userenv->{branch} eq $patron->branchcode ) {
            print $input->redirect(
                "/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_OTHERLIBRARY");
            exit 0;    # Exit without error
        }
    }
}

if ( my $anonymous_patron = C4::Context->preference("AnonymousPatron") ) {
    if ( $patron->id eq $anonymous_patron ) {
        print $input->redirect(
            "/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_ANONYMOUS_PATRON");
        exit 0;    # Exit without error
    }
}

my $op           = $input->param('op') || 'delete_confirm';
my $dbh          = C4::Context->dbh;
my $is_guarantor = $patron->guarantee_relationships->count;
my $countholds   = $dbh->selectrow_array( "SELECT COUNT(*) FROM reserves WHERE borrowernumber=?", undef, $member );

# Add warning if patron has pending suggestions
$template->param(
    pending_suggestions => Koha::Suggestions->search( { suggestedby => $member, STATUS => 'ASKED' } )->count,
);

$template->param(
    patron        => $patron,
    ItemsOnIssues => $countissues,
    debits        => $debits,
    credits       => $credits,
    is_guarantor  => $is_guarantor,
    ItemsOnHold   => $countholds,
);

if ( $op eq 'delete_confirm' or $countissues > 0 or $debits or $is_guarantor ) {
    $template->param(
        op => 'delete_confirm',
    );

} elsif ( $op eq 'cud-delete_confirmed' ) {

    my $patron = Koha::Patrons->find($member);

    try {
        my $schema = Koha::Database->new->schema;
        $schema->txn_do(
            sub {
                $patron->move_to_deleted;
                $patron->delete;
                print $input->redirect("/cgi-bin/koha/members/members-home.pl");
            }
        );
    } catch {
        if ( $_->isa('Koha::Exceptions::Patron::FailedDeleteAnonymousPatron') ) {
            print $input->redirect(
                "/cgi-bin/koha/members/moremember.pl?borrowernumber=$member&error=CANT_DELETE_ANONYMOUS_PATRON");
        } else {
            $_->rethrow;
        }
    };

    # TODO Tell the user everything went ok
    exit 0;    # Exit without error
}

output_html_with_http_headers $input, $cookie, $template->output;
