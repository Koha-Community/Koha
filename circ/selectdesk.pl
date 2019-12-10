#!/usr/bin/perl

# Copyright (C) 2020 BULAC
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
use C4::Auth qw/:DEFAULT get_session/;
use C4::Koha;
use Koha::Desks;

my $query = CGI->new();

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/selectdesk.tt",
        query           => $query,
        type            => "intranet",
        debug           => 1,
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1, },
    }
);

my $sessionID = $query->cookie("CGISESSID");
my $session   = get_session($sessionID);

my $branch = C4::Context->userenv->{'branch'};
my $searchfield = $query->param('searchfield');
my $desks_lists;
if ($branch) {
    $desks_lists = Koha::Desks->search( { branchcode => $branch } )->unblessed;
}
else {
    $desks_lists = Koha::Desks->search( )->unblessed;
}

my $desk_id = $query->param('desk_id');

my $userenv_desk = C4::Context->userenv->{'desk_id'} || '';
my $updated = '';

if ($desk_id) {
    if ( !$userenv_desk or $userenv_desk ne $desk_id ) {
        my $desk = Koha::Desks->find( { desk_id => $desk_id } );
        $template->param( LoginDeskname => $desk->desk_name );
        $template->param( LoginDeskid => $desk->desk_id );
        $session->param( desk_name => $desk->desk_name );
        $session->param( desk_id => $desk->desk_id );
        $updated = 1;
    }
}
else {
    $desk_id = $userenv_desk;
}

$template->param( updated => \$updated );

my $referer = $query->param('oldreferer') || $ENV{HTTP_REFERER};
if ($updated) {
    print $query->redirect( $referer || '/cgi-bin/koha/mainpage.pl' );
}

$template->param(
    referer    => $referer,
    desks_list => $desks_lists,
    desk_id     => $desk_id,
);

output_html_with_http_headers $query, $cookie, $template->output;
