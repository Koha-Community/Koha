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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::RestrictionTypes;

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
        existing => scalar Koha::RestrictionTypes->search()
    );
    if ($code) {
        $template->param(
            restriction => scalar Koha::RestrictionTypes->find($code)
        );
    }
} elsif ( $op eq 'add_validate' ) {

    my $display_text = $input->param('display_text');
    my $can_be_added_manually = $input->param('can_be_added_manually') || 0;
    my $is_a_modif = $input->param("is_a_modif");

    if ($is_a_modif) {
        # Check whether another restriction already has this display text
        my $dupe = Koha::RestrictionTypes->find({
            display_text => $display_text
        });
        if ($dupe) {
            push @messages, {
                type => 'error', code => 'duplicate_display_text'
            };
        } else {
            my $restriction = Koha::RestrictionTypes->find($code);
            $restriction->display_text($display_text);
            unless ($restriction->is_system) {
                $restriction->can_be_added_manually($can_be_added_manually);
            }
            $restriction->store;
        }
    } else {
        # Check whether another restriction already has this code
        my $dupe = Koha::RestrictionTypes->find($code);
        if ($dupe) {
            push @messages, {
                type => 'error', code => 'duplicate_code'
            };
        } else {
            my $restriction = Koha::RestrictionType->new({
                code => $code,
                display_text => $display_text,
                can_be_added_manually => $can_be_added_manually
            });
            $restriction->store;
        }
    }
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    $template->param(
        restriction => scalar Koha::RestrictionTypes->find($code)
    );
} elsif ( $op eq 'delete_confirmed' ) {
    Koha::RestrictionTypes->find($code)->delete;
    $op = 'list';
}

$template->param(
    messages => \@messages,
    op       => $op
);

if ( $op eq 'list' ) {
    my $restrictions = Koha::RestrictionTypes->search();
    $template->param(
        restrictions => $restrictions,
    )
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;
