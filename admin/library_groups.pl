#!/usr/bin/perl

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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Libraries;
use Koha::Library::Group;
use Koha::Library::Groups;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/library_groups.tt",
        query           => $cgi,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_libraries' },
    }
);

my $action = $cgi->param('action') || q{};
my @messages;

if ( $action eq 'add' ) {
    my $parent_id   = $cgi->param('parent_id')   || undef;
    my $title       = $cgi->param('title')       || undef;
    my $description = $cgi->param('description') || undef;
    my $branchcode  = $cgi->param('branchcode')  || undef;
    my $ft_hide_patron_info    = $cgi->param('ft_hide_patron_info')    || 0;
    my $ft_limit_item_editing  = $cgi->param('ft_limit_item_editing')  || 0;
    my $ft_search_groups_opac  = $cgi->param('ft_search_groups_opac')  || 0;
    my $ft_search_groups_staff = $cgi->param('ft_search_groups_staff') || 0;
    my $ft_local_hold_group    = $cgi->param('ft_local_hold_group')    || 0;
    my $ft_local_float_group   = $cgi->param('ft_local_float_group')   || 0;

    if ( !$branchcode && Koha::Library::Groups->search( { title => $title } )->count() ) {
        $template->param( error_duplicate_title => $title );
    }
    else {
        my $group = eval {
            Koha::Library::Group->new(
                {
                    parent_id              => $parent_id,
                    title                  => $title,
                    description            => $description,
                    ft_hide_patron_info    => $ft_hide_patron_info,
                    ft_search_groups_opac  => $ft_search_groups_opac,
                    ft_search_groups_staff => $ft_search_groups_staff,
                    ft_local_hold_group    => $ft_local_hold_group,
                    ft_limit_item_editing  => $ft_limit_item_editing,
                    ft_local_float_group   => $ft_local_float_group,
                    branchcode             => $branchcode,
                }
            )->store();
        };
        if ($@) {
            push @messages, { type => 'alert', code => 'error_on_insert' };
        }
        else {
            $template->param( added => $group );
        }
    }
}
elsif ( $action eq 'edit' ) {
    my $id          = $cgi->param('id')          || undef;
    my $title       = $cgi->param('title')       || undef;
    my $description = $cgi->param('description') || undef;
    my $ft_hide_patron_info    = $cgi->param('ft_hide_patron_info')    || 0;
    my $ft_limit_item_editing  = $cgi->param('ft_limit_item_editing')  || 0;
    my $ft_search_groups_opac  = $cgi->param('ft_search_groups_opac')  || 0;
    my $ft_search_groups_staff = $cgi->param('ft_search_groups_staff') || 0;
    my $ft_local_hold_group    = $cgi->param('ft_local_hold_group')    || 0;
    my $ft_local_float_group   = $cgi->param('ft_local_float_group')   || 0;

    if ($id) {
        my $group = Koha::Library::Groups->find($id);

        $group->set(
            {
                title                  => $title,
                description            => $description,
                ft_hide_patron_info    => $ft_hide_patron_info,
                ft_limit_item_editing  => $ft_limit_item_editing,
                ft_search_groups_opac  => $ft_search_groups_opac,
                ft_search_groups_staff => $ft_search_groups_staff,
                ft_local_hold_group    => $ft_local_hold_group,
                ft_local_float_group   => $ft_local_float_group,
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

$template->param( root_groups => $root_groups, messages => \@messages, );

output_html_with_http_headers $cgi, $cookie, $template->output;
