#! /usr/bin/perl

# Copyright 2019 Koha Development Team
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
use CGI       qw ( -utf8 );
use Try::Tiny qw( catch try );

use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::IllbatchStatus;
use Koha::IllbatchStatuses;

my $input = CGI->new;
my $code  = $input->param('code');
my $op    = $input->param('op') || 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/ill_batch_statuses.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'ill' },
    }
);

my $status;
if ($code) {
    $status = Koha::IllbatchStatuses->find( { code => $code } );
}

if ( $op eq 'add_form' ) {
    if ($status) {
        $template->param( status => $status );
    }
} elsif ( $op eq 'add_validate' ) {
    my $name = $input->param('name');
    my $code = $input->param('code');

    if ( not defined $status ) {
        $status = Koha::IllbatchStatus->new(
            {
                name => $name,
                code => $code
            }
        );
    }

    try {
        if ( $status->id ) {
            $status->update_and_log( { name => $name } );
        } else {
            $status->create_and_log;
        }
        push @messages, { type => 'message', code => 'success_on_saving' };
    } catch {
        push @messages, { type => 'error', code => 'error_on_saving' };
    };
    $op = 'list';
} elsif ( $op eq 'delete' ) {
    try {
        $status->delete_and_log;
        push @messages, { code => 'success_on_delete', type => 'message' };
    } catch {
        push @messages, { code => 'error_on_delete', type => 'alert' };

    };
    $op = 'list';
}
if ( $op eq 'list' ) {
    my $statuses = Koha::IllbatchStatuses->search();
    $template->param( statuses => $statuses );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
