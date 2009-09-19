#!/usr/bin/perl

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

=head1 member-search.pl

Member Search.pl script used to search for members to add to a routing list

=cut

use strict;
use warnings;
use CGI;
use C4::Auth;       # get_template_and_user
use C4::Output;
use C4::Members;    # BornameSearch

my $query          = new CGI;
my $subscriptionid = $query->param('subscriptionid');
my $searchstring   = $query->param('member');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/member-search.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => 1 },
        debug           => 1,
    }
);

if ($searchstring) {
    my ( $count, $members ) = &SearchMember( $searchstring, "surname" );

    $template->param(
        subscriptionid => $subscriptionid,
        memberloop     => $members,
        member         => $searchstring,
    );
}
else {
    $template->param( subscriptionid => $subscriptionid, );
}
output_html_with_http_headers $query, $cookie, $template->output;
