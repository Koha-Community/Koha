#! /usr/bin/perl

# Copyright 2016 ByWater Solutions
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
use C4::Auth;
use C4::Output;

use Koha::Libraries;
use Koha::Library::Group;
use Koha::Library::Groups;

my $cgi = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/library_groups.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

my $action = $cgi->param('action') || q{};

if ( $action eq 'add' ) {
    my $parent_id   = $cgi->param('parent_id')   || undef;
    my $title       = $cgi->param('title')       || undef;
    my $description = $cgi->param('description') || undef;
    my $ft_hide_patron_info = $cgi->param('ft_hide_patron_info') || 0;
    my $branchcode  = $cgi->param('branchcode')  || undef;

    if ( !$branchcode && Koha::Library::Groups->search( { title => $title } )->count() ) {
        $template->param( error_duplicate_title => $title );
    }
    else {
        my $group = Koha::Library::Group->new(
            {
                parent_id   => $parent_id,
                title       => $title,
                description => $description,
                ft_hide_patron_info => $ft_hide_patron_info,
                branchcode  => $branchcode,
            }
        )->store();

        $template->param( added => $group );
    }
}
elsif ( $action eq 'edit' ) {
    my $id          = $cgi->param('id')          || undef;
    my $title       = $cgi->param('title')       || undef;
    my $description = $cgi->param('description') || undef;
    my $ft_hide_patron_info = $cgi->param('ft_hide_patron_info') || 0;

    if ($id) {
        my $group = Koha::Library::Groups->find($id);

        $group->set(
            {
                title       => $title,
                description => $description,
                ft_hide_patron_info => $ft_hide_patron_info,
            }
        )->store();

        $template->param( edited => $group );
    }
}
elsif ( $action eq 'delete' ) {
    my $id = $cgi->param('id');

    my $group = Koha::Library::Groups->find($id);

    if ($group) {
        $group->delete();
        $template->param(
            deleted => {
                title   => $group->title(),
                library => $group->library()
                ? $group->library()->branchname
                : undef
            }
        );
    }
}

my $root_groups = Koha::Library::Groups->get_root_groups();

$template->param( root_groups => $root_groups, );

output_html_with_http_headers $cgi, $cookie, $template->output;
