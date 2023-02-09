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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Desks;

my $input       = CGI->new;
my $searchfield = $input->param('desk_name') // q||;
my $desk_id      = $input->param('desk_id') || '';
my $op          = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "admin/desks.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'manage_libraries' },
    }
);

my $branches = Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;

if ( $op eq 'add_form' ) {
    my $desk;
    if ($desk_id) {
        $desk = Koha::Desks->find($desk_id);
    }

    $template->param( desk => $desk, );
} elsif ( $op eq 'add_validate' ) {
    my $desk_id       = $input->param('desk_id');
    my $desk_name    = $input->param('desk_name');
    my $branchcode   = $input->param('branchcode');

    if (Koha::Desks->find($desk_id)) {
        my $desk = Koha::Desks->find($desk_id);
        $desk->desk_name($desk_name);
        $desk->branchcode($branchcode);
        eval { $desk->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $desk = Koha::Desk->new(
            {
                desk_id       => $desk_id,
                desk_name    => $desk_name,
                branchcode   => $branchcode,
            }
        );
        eval { $desk->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }
    $searchfield = q||;
    $op          = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $desk = Koha::Desks->find($desk_id);
    $template->param( desk => $desk, );
} elsif ( $op eq 'delete_confirmed' ) {
    my $desk = Koha::Desks->find($desk_id);
    my $deleted = eval { $desk->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' || ! $op) {
    my $desks = Koha::Desks->search( { desk_name => { -like => "%$searchfield%" } } );
    $template->param( desks => $desks, );
}

$template->param(
    desk_id      => $desk_id,
    searchfield => $searchfield,
    messages    => \@messages,
    op          => $op,
    branches    => $branches,
);

output_html_with_http_headers $input, $cookie, $template->output;
