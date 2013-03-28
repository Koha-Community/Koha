#!/usr/bin/perl
# This script lets the users change their privacy rules
#
# copyright 2009, BibLibre, paul.poulain@biblibre.com
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use CGI;

use C4::Auth;    # checkauth, getborrowernumber.
use C4::Context;
use C4::Circulation;
use C4::Members;
use C4::Output;
use C4::Dates;

my $query = new CGI;
my $dbh   = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-privacy.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

my $op = $query->param("op");
my $privacy = $query->param("privacy");

if ($op eq "update_privacy")
{
    ModPrivacy($borrowernumber,$privacy);
    $template->param('privacy_updated' => 1);
}
if ($op eq "delete_record") {
    # delete all reading records for items returned
    # uses a hardcoded date ridiculously far in the future
    my ($rows,$err_history_not_deleted) = AnonymiseIssueHistory('2999-12-12',$borrowernumber);
    # confirm the user the deletion has been done
    if ( !$err_history_not_deleted ) {
        $template->param( 'deleted' => 1 );
    }
    else {
        $template->param( 'err_history_not_deleted' => 1 );
    }
}
# get borrower privacy ....
my ( $borr ) = GetMemberDetails( $borrowernumber );

$template->param( 'Ask_data'       => '1',
                    'privacy'.$borr->{'privacy'} => 1,
                    'firstname' => $borr->{'firstname'},
                    'surname' => $borr->{'surname'},
                    'privacyview' => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;
