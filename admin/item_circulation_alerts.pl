#!/usr/bin/perl

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

use strict;
use warnings;

use CGI;
use File::Basename;
use Encode;
use JSON;
#use Data::Dump 'pp';

use C4::Auth;
use C4::Context;
use C4::Branch;
use C4::Category;
use C4::ItemType;
use C4::ItemCirculationAlertPreference;
use C4::Output;

# shortcut for long package name
our $preferences = 'C4::ItemCirculationAlertPreference';

# utf8 filter
sub utf8 {
    my ($data, @keys) = @_;
    for (@keys) {
        $data->{$_} = decode('utf8', $data->{$_});
    }
    $data;
}

# prepend "br_" to column name and replace spaces with "<br/>"
sub br {
    my ($data, @keys) = @_;
    for (@keys) {
        my $br = $data->{$_};
        $br =~ s{\s+}{<br/>}g;
        $data->{'br_'.$_} = $br;
    }
    $data;
}

# display item circulation alerts
sub show {
    my ($input) = @_;
    my $dbh = C4::Context->dbh;
    my ($template, $user, $cookie) = get_template_and_user(
        {
            template_name   => "admin/item_circulation_alerts.tt",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { parameters => 'parameters_remaining_permissions' },
            debug           => defined($input->param('debug')),
        }
    );

    my $br       = GetBranches;
    my $branch   = $input->param('branch') || '*';
    my @branches = (
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

    my @categories = (
        C4::Category->all
    );
    my @item_types = map { br($_, 'description') }  (
        C4::ItemType->all
    );
    my $grid_checkout = $preferences->grid({ branchcode => $branch, notification => 'CHECKOUT' });
    my $grid_checkin  = $preferences->grid({ branchcode => $branch, notification => 'CHECKIN' });

    $template->param(branch             => $branch);
    $template->param(branch_name        => $branch_name || 'Default');
    $template->param(branches           => \@branches);
    $template->param(categories         => \@categories);
    $template->param(item_types         => \@item_types);
    $template->param(grid_checkout      => $grid_checkout);
    $template->param(grid_checkin       => $grid_checkin);

    output_html_with_http_headers $input, $cookie, $template->output;
}

# toggle a preference via ajax
sub toggle {
    my ($input) = @_;
    my $id = $input->param('id');
    my $branch = $input->param('branch');
    my ($category, $item_type, $notification) = split('-', $id);
    $category  =~ s/_/*/;
    $item_type =~ s/_/*/;

    my $settings = {
        branchcode   => $branch,
        categorycode => $category,
        item_type    => $item_type,
        notification => $notification,
    };

    my $restrictions = $preferences;  # all the same thing...
    my $notifications = $preferences; #
    if ($notifications->is_enabled_for($settings)) {
        # toggle by adding a restriction
        $restrictions->create($settings);
    } else {
        # toggle by removing the restriction
        $restrictions->delete($settings);
    }

    my $response = { success => 1 };
    my @reasons  = $notifications->is_disabled_for($settings);
    if (@reasons == 0) {
        $response->{classes} = '';
    } else {
        my $default_exists   = grep { $_->{branchcode} eq '*' } @reasons;
        my $non_default_also = grep { $_->{branchcode} ne '*' } @reasons;
        my @classes;
        push @classes, 'default'  if $default_exists;
        push @classes, 'disabled' if $non_default_also;
        $response->{classes} = join(' ', @classes);
    }
    print $input->header;
    print encode_json($response);
}

# dispatch to various actions based on CGI parameter 'action'
sub dispatch {
    my %handler = (
        show   => \&show,
        toggle => \&toggle,
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

=over 2

=item branch

What branch are we looking at.  If none is specified, the virtual default
branch '*' is used.

=back



=head3 ?action=toggle

Toggle a preference via AJAX

Parameters:

=over 2

=item id

The id should be string that can be split on "-" which contains:
"$categorycode-$item_type-$notification".

=item branch

Branch code to apply this preference to

=back

=cut
