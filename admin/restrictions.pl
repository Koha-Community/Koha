#!/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use Try::Tiny qw( try catch );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Patron::Restriction::Types;

my $input = CGI->new;
my $op    = $input->param('op') // 'list';
my $code  = uc $input->param('code');
my @messages = ();

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/restrictions.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_patron_restrictions' },
        debug           => 1,
    }
);

if ( $op eq 'add_form') {
    # Get all existing restrictions, so we can do client-side validation
    $template->param(
        existing => scalar Koha::Patron::Restriction::Types->search()
    );
    if ($code) {
        $template->param(
            restriction => scalar Koha::Patron::Restriction::Types->find($code)
        );
    }
} elsif ( $op eq 'add_validate' ) {

    my $display_text = $input->param('display_text');
    my $is_a_modif = $input->param("is_a_modif");

    if ($is_a_modif) {
        # Check whether another restriction already has this display text
        my $dupe = Koha::Patron::Restriction::Types->search(
            {
                code         => { '!=' => $code },
                display_text => $display_text,
            }
        );
        if ($dupe->count) {
            push @messages, {
                type => 'error', code => 'duplicate_display_text'
            };
        } else {
            my $restriction = Koha::Patron::Restriction::Types->find($code);
            $restriction->display_text($display_text);
            $restriction->store;
            push @messages, { type => 'message', code => 'update_success' };
        }
    } else {
        # Check whether another restriction already has this code
        my $dupe = Koha::Patron::Restriction::Types->find($code);
        if ($dupe) {
            push @messages, {
                type => 'error', code => 'duplicate_code'
            };
        } else {
            my $restriction = Koha::Patron::Restriction::Type->new({
                code => $code,
                display_text => $display_text
            });
            $restriction->store;
            push @messages, { type => 'message', code => 'add_success' };
        }
    }
    $op = 'list';
} elsif ( $op eq 'make_default' ) {
    my $restriction = Koha::Patron::Restriction::Types->find($code);
    $restriction->make_default;
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    $template->param(
        restriction => scalar Koha::Patron::Restriction::Types->find($code)
    );
} elsif ( $op eq 'delete_confirmed' ) {
    try {
        Koha::Patron::Restriction::Types->find($code)->delete;
        push @messages, { type => 'message', code => 'delete_success' };
    }
    catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::CannotDeleteDefault') ) {
                push @messages, { type => 'error', code => 'delete_default' };
            }
            elsif ( $_->isa('Koha::Exceptions::CannotDeleteSystem') ) {
                push @messages, { type => 'error', code => 'delete_system' };
            }
        }
    };
    $op = 'list';
}

$template->param(
    messages => \@messages,
    op       => $op
);

if ( $op eq 'list' ) {
    my $restrictions = Koha::Patron::Restriction::Types->search();
    $template->param(
        restrictions => $restrictions,
    )
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;
