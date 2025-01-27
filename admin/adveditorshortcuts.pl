#!/usr/bin/perl

# Copyright 2018 Koha Development Team
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

=head1 NAME

adveditorshortcuts.pl : Define keyboard shortcuts for the advanced cataloging editor (rancor)

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script allows the user to redefine the keyboard shortcuts for the advacned cataloging editor

=head1 FUNCTIONS

=cut

use Modern::Perl;

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use CGI        qw ( -utf8 );
use Koha::KeyboardShortcuts;

my $input = CGI->new;
my $op    = $input->param('op') || 'list';

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/adveditorshortcuts.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_keyboard_shortcuts' },
    }
);

my $shortcuts = Koha::KeyboardShortcuts->search();

if ( $op eq 'cud-save' ) {
    my @shortcut_names = $input->multi_param('shortcut_name');
    my @shortcut_keys  = $input->multi_param('shortcut_keys');
    my %updated_shortcuts;
    @updated_shortcuts{@shortcut_names} = @shortcut_keys;

    while ( my $shortcut = $shortcuts->next() ) {
        $shortcut->shortcut_keys( $updated_shortcuts{ $shortcut->shortcut_name } );
        $shortcut->store();
    }
}

$template->param(
    shortcuts => $shortcuts,
);

output_html_with_http_headers $input, $cookie, $template->output;
