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

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth qw( get_template_and_user get_session haspermission );
use Koha::BiblioFrameworks;
use Koha::Cash::Registers;
use Koha::Libraries;
use Koha::Desks;

my $query = CGI->new();

my ( $template, $borrowernumber, $cookie, $flags ) = get_template_and_user({
    template_name   => "circ/set-library.tt",
    query           => $query,
    type            => "intranet",
    flagsrequired   => { catalogue => 1, },
});

my $sessionID = $query->cookie("CGISESSID");
my $session = get_session($sessionID);

my $op                  = $query->param('op') || q{};
my $branch              = $query->param('branch');
my $desk_id             = $query->param('desk_id');
my $register_id         = $query->param('register_id');
my $userenv_branch      = C4::Context->userenv->{'branch'} || '';
my $userenv_desk        = C4::Context->userenv->{'desk_id'} || '';
my $userenv_register_id = C4::Context->userenv->{'register_id'} || '';
my $updated;

my $library = Koha::Libraries->find($branch);
# $session lines here are doing the updating
if (
       $op eq 'cud-set-library'
    && $library
    && (   C4::Auth::haspermission( C4::Context->userenv->{'id'}, { 'loggedinlibrary' => 1 } )
        or C4::Context::IsSuperLibrarian() )
    )
{
    if ( !$userenv_branch or $userenv_branch ne $branch ) {
        my $branchname = $library->branchname;
        $session->param( 'branchname', $branchname );    # update sesssion in DB
        $session->param( 'branch',     $branch );        # update sesssion in DB
        $updated = 1;
    }
} else {
    $branch = $userenv_branch;    # fallback value
}

if ( defined($desk_id) && ( !$userenv_desk || $userenv_desk ne $desk_id ) ) {
    if ($desk_id) {

        # A desk was selected
    my $desk          = Koha::Desks->find( { desk_id => $desk_id } );
    $session->param( desk_name => $desk->desk_name );
    $session->param( desk_id   => $desk->desk_id );
    } else {

        # "No desk" was explicitly selected - clear desk from session
        $session->clear( [ 'desk_name', 'desk_id' ] );
    }
    $updated = 1;
} else {
    $desk_id = $userenv_desk;
}

if ( defined($register_id)
    && ( !$userenv_register_id || $userenv_register_id ne $register_id ) )
{
    if ($register_id) {

        # A register was selected
    my $register          = Koha::Cash::Registers->find($register_id);
    $session->param( 'register_id',   $register_id );
    $session->param( 'register_name', $register ? $register->name : '' );
    } else {

        # "No register" was explicitly selected - clear register from session
        $session->clear( [ 'register_id', 'register_name' ] );
    }
    $updated = 1;
} else {
    $register_id = $userenv_register_id;
}

$session->flush();


my $referer =  $query->param('oldreferer') || $ENV{HTTP_REFERER} || '';
if ( $updated ) {
    print $query->redirect($referer || '/cgi-bin/koha/mainpage.pl');
}

$template->param(
    referer     => $referer,
    branch      => $branch,
    desk_id     => $desk_id,
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

output_html_with_http_headers $query, $cookie, $template->output;
