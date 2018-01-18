#!/usr/bin/perl

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

=head1 updatechild.pl

    script to update a child member to (usually) an adult member category

    - if called with op=multi, will return all available non child categories, for selection.
    - if called with op=update, script will update member record via  ModMember().

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use Koha::Patrons;
use Koha::Patron::Categories;

# use Smart::Comments;

my $dbh   = C4::Context->dbh;
my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "members/update-child.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);

my $borrowernumber = $input->param('borrowernumber');
my $catcode        = $input->param('catcode');
my $cattype        = $input->param('cattype');
my $catcode_multi = $input->param('catcode_multi');
my $op             = $input->param('op');

if ( $op eq 'multi' ) {
    # FIXME - what are the possible upgrade paths?  C -> A , C -> S ...
    #   currently just allowing C -> A
    my $patron_categories = Koha::Patron::Categories->search_limited({ category_type => 'A' }, {order_by => ['categorycode']});
    $template->param(
        MULTI             => 1,
        CATCODE_MULTI     => 1,
        borrowernumber    => $borrowernumber,
        patron_categories => $patron_categories,
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}

elsif ( $op eq 'update' ) {
    my $patron = Koha::Patrons->find( $borrowernumber );
    unless ( $patron ) {
        print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
        exit;
    }
    my $member = $patron->unblessed;
    $member->{'guarantorid'}  = 0;
    $member->{'categorycode'} = $catcode;
    my $borcat = Koha::Patron::Categories->find($catcode);
    $member->{'category_type'} = $borcat->category_type;
    $member->{'description'}   = $borcat->description;
    delete $member->{password};
    ModMember(%$member);

    if (  $catcode_multi ) {
        $template->param(
                SUCCESS        => 1,
                borrowernumber => $borrowernumber,
                );
        output_html_with_http_headers $input, $cookie, $template->output;
    } else {
        print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrowernumber");
    }
}

