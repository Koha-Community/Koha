#!/usr/bin/perl
#
# Copyright 2019 PTFS Europe
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use CGI;
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use Koha::Libraries;
use C4::Koha;
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Cash::Registers;

my $cgi = CGI->new();
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => 'admin/cash_registers.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { parameters => 'manage_cash_registers' },
    }
);

my $op         = $cgi->param('op') || 'list';
my $registerid = $cgi->param('id');             # update/archive
my $dbh        = C4::Context->dbh;
my @messages;
if ( $op eq 'add_form' ) {
    if ($registerid) {
        my $cash_register = Koha::Cash::Registers->find($registerid);
        $template->param( cash_register => $cash_register );
    }
    my $libraries =
        Koha::Libraries->search( {}, { order_by => ['branchcode'] }, );
    $template->param(
        branch_list => $libraries,
        add_form    => 1
    );
} elsif ( $op eq 'cud-add_validate' ) {
    my $name = $cgi->param('name');
    $name ||= q{};
    my $description = $cgi->param('description');
    $description ||= q{};
    my $branch = $cgi->param('branch');
    my $float  = $cgi->param('starting_float') // 0;
    if ($registerid) {
        try {
            my $cash_register = Koha::Cash::Registers->find($registerid);
            $cash_register->set(
                {
                    name           => $name,
                    description    => $description,
                    branch         => $branch,
                    starting_float => $float
                }
            )->store;
            push @messages, { code => 'success_on_update', type => 'message' };
        } catch {
            push @messages, { code => 'error_on_update', type => 'alert' };
        }
    } else {
        try {
            my $cash_register = Koha::Cash::Register->new(
                {
                    name           => $name,
                    description    => $description,
                    branch         => $branch,
                    starting_float => $float,
                }
            )->store;
            push @messages, { code => 'success_on_insert', type => 'message' };
        } catch {
            push @messages, { code => 'error_on_insert', type => 'alert' };
        }
    }
    $op = 'list';

} elsif ( $op eq 'cud-archive' ) {
    if ($registerid) {
        try {
            my $cash_register = Koha::Cash::Registers->find($registerid);
            $cash_register->archived(1)->store();
            push @messages, { code => 'success_on_archive', type => 'message' };
        } catch {
            push @messages, { code => 'error_on_archive', type => 'alert' };

        }
    }
    $op = 'list';
} elsif ( $op eq 'cud-unarchive' ) {
    if ($registerid) {
        try {
            my $cash_register = Koha::Cash::Registers->find($registerid);
            $cash_register->archived(0)->store();
            push @messages, { code => 'success_on_restore', type => 'message' };
        } catch {
            push @messages, { code => 'error_on_restore', type => 'alert' };
        }
    }
    $op = 'list';

} elsif ( $op eq 'cud-make_default' ) {
    if ($registerid) {
        try {
            my $cash_register = Koha::Cash::Registers->find($registerid);
            $cash_register->make_default;
            push @messages, { code => 'success_on_default', type => 'message' };
        } catch {
            push @messages, { code => 'error_on_default', type => 'alert' };
        }
    }
    $op = 'list';
} elsif ( $op eq 'cud-drop_default' ) {
    if ($registerid) {
        try {
            my $cash_register = Koha::Cash::Registers->find($registerid);
            $cash_register->drop_default;
            push @messages, { code => 'success_on_default', type => 'message' };
        } catch {
            push @messages, { code => 'error_on_default', type => 'alert' };
        }
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $cash_registers = Koha::Cash::Registers->search(
        {},
        { prefetch => 'branch', order_by => { -asc => [qw/branch name/] } }
    );
    $template->param( cash_registers => $cash_registers, );
}

$template->param( op => $op, messages => \@messages );

output_html_with_http_headers $cgi, $cookie, $template->output;
