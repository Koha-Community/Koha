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

use strict;
use warnings;

use CGI;
use File::Basename;
use Encode;
use URI::Escape 'uri_escape_utf8';
#use Data::Dump 'pp';

use C4::Auth;
use C4::Context;
use C4::Branch;
use C4::Category;
use C4::ItemType;
use C4::ItemCirculationAlertPreference;
use C4::Output;

# shortcut for long package name
my $preferences = 'C4::ItemCirculationAlertPreference';

# common redirect code
sub redirect {
    my ($input) = @_;
    my $path = defined($input->param('redirect_to'))
        ? $input->param('redirect_to')
        : basename($0);
    print $input->redirect($path);
}

# utf8 filter
sub utf8 {
    my ($data, @keys) = @_;
    for (@keys) {
        $data->{$_} = decode('utf8', $data->{$_});
    }
    $data;
}

# add long category and itemtype descriptions to preferences
sub category_and_itemtype {
    my ($categories, $item_types, @prefs) = @_;
    my %c = map { $_->{categorycode} => $_->{description} } @$categories;
    my %i = map { $_->{itemtype}     => $_->{description} } @$item_types;
    for (@prefs) {
        $_->{category_description} = $c{$_->{categorycode}} || 'Default';
        $_->{item_type_description} = $i{$_->{item_type}} || 'Default';
    }
}

# display item circulation alerts
sub show {
    my ($input) = @_;
    my $dbh = C4::Context->dbh;
    my ($template, $user, $cookie) = get_template_and_user(
        {
            template_name   => "admin/item_circulation_alerts.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { admin => 1 },
            debug           => defined($input->param('debug')),
        }
    );

    my $br       = GetBranches;
    my $branch   = $input->param('branch') || '*';
    my @branches = map { utf8($_, 'branchname') } (
        {
            branchcode => '*',
            branchname => 'Default',
        },
        sort { $a->{branchname} cmp $b->{branchname} } values %$br,
    );
    for (@branches) {
        $_->{selected} = "selected" if ($branch eq $_->{branchcode});
    }
    my $branch_name = exists($br->{$branch}) && $br->{$branch}->{branchname};

    my @categories = map { utf8($_, 'description') }  (
        C4::Category->new({ categorycode => '*', description => 'Default' }),
        C4::Category->all
    );
    my @item_types = map { utf8($_, 'description') }  (
        C4::ItemType->new({ itemtype => '*', description => 'Default' }),
        C4::ItemType->all
    );
    my @default_prefs = $preferences->find({ branchcode => '*' });
    my @branch_prefs;
    my $redirect_to = "?branch=$branch";

    $template->param(redirect_to        => $redirect_to);
    $template->param(redirect_to_x      => uri_escape_utf8($redirect_to));
    $template->param(branch             => $branch);
    $template->param(branch_name        => $branch_name);
    $template->param(branches           => \@branches);
    $template->param(categories         => \@categories);
    $template->param(item_types         => \@item_types);
    $template->param(default_prefs      => \@default_prefs);
    if ($branch ne '*') {
        @branch_prefs = $preferences->find({ branchcode => $branch });
        $template->param(branch_prefs => \@branch_prefs);
    }
    category_and_itemtype(\@categories, \@item_types, (@default_prefs, @branch_prefs));
    output_html_with_http_headers $input, $cookie, $template->output;
}

# create item circulation alert preference and redirect
sub create {
    my ($input) = @_;
    my $branchcode   = $input->param('branchcode');
    my $categorycode = $input->param('categorycode');
    my $item_type    = $input->param('item_type');
    $preferences->create({
        branchcode   => $branchcode,
        categorycode => $categorycode,
        item_type    => $item_type,
    });
    redirect($input);
}

# delete preference and redirect
sub delete {
    my ($input) = @_;
    my $id = $input->param('id');
    $preferences->delete({ id => $id });
    redirect($input);
}

# dispatch to various actions based on CGI parameter 'action'
sub dispatch {
    my %handler = (
        show   => \&show,
        create => \&create,
        delete => \&delete,
    );
    my $input  = new CGI;
    my $action = $input->param('action') || 'show';
    if (not exists $handler{$action}) {
        my $status = 400;
        print $input->header(-status => $status);
        print $input->div(
            $input->h1($status),
            $input->p("$action is not supported.")
        );
    } else {
        $handler{$action}->($input);
    }
}

# main
dispatch if $ENV{REQUEST_URI};
1;


=head1 NAME

admin/item_circulation_alerts.pl - per-branch configuration for messaging

=head1 SYNOPSIS

L<http://intranet.mydomain.com:8080/cgi-bin/koha/admin/item_circulation_alerts.pl>

=head1 DESCRIPTION

This CGI script drives an interface for configuring item circulation alerts.
If you want to prevent alerts from going out for any combination of branch,
patron category, and item type, this is where that policy would be set.

=head2 URLs


=head3 ?action=show

Display a branches item circulation alert preferences.

Parameters:

=over 4

=item branch

What branch are we looking at.  If none is specified, the virtual default
branch '*' is used.

=back




=head3 ?action=create

Create an item circulation alert preference.

Parameters:

=over 4

=item branchcode

Branch code

=item categorycode

Patron category

=item item_type

Item type

=back




=head3 ?action=delete

Delete an item circulation alert preference.

Parameters:

=over 4

=item id

The id of the preference to delete.

=back




=cut

# Local Variables: ***
# mode: cperl ***
# indent-tabs-mode: nil ***
# cperl-close-paren-offset: -4 ***
# cperl-continued-statement-offset: 4 ***
# cperl-indent-level: 4 ***
# cperl-indent-parens-as-block: t ***
# cperl-tab-always-indent: nil ***
# End: ***
# vim:tabstop=8 softtabstop=4 shiftwidth=4 shiftround expandtab
