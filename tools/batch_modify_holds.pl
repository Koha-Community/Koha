#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2024 Koha Development Team
#
# Koha is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General
# Public License along with Koha; if not, see
# <https://www.gnu.org/licenses>

use Modern::Perl;
use CGI;

use JSON qw( to_json );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;

my $input = CGI->new;
my $op    = $input->param('op') // q|cud-form|;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'tools/batch_modify_holds.tt',
        query         => $input,
        type          => "intranet",
        flagsrequired => { tools => 'batch_modify_holds', reserveforothers => 'place_holds' },
    }
);

my @hold_ids;

if ( $op eq 'cud-form' ) {
    my $reserve_ids_list = $input->param('reserve_ids_list') || undef;
    if ($reserve_ids_list) {
        my @reserve_ids = split /\n/, $reserve_ids_list;
        $template->param( reserve_ids_list => to_json( \@reserve_ids ), );
    }
    $template->param( view => 'cud-form', );
} elsif ( $op eq 'cud-modify' ) {
    my $new_expiration_date = $input->param('new_expiration_date');
    my $new_pickup_loc      = $input->param('new_pickup_loc');
    my $new_suspend_status  = $input->param('new_suspend_status');
    my $new_suspend_date    = $input->param('new_suspend_date');
    my $new_hold_note       = $input->param('new_hold_note');
    my $clear_hold_notes    = $input->param('clear_hold_notes');

    @hold_ids = $input->multi_param('hold_id');
    my @holds_data = ();

    my $holds_to_update =
        Koha::Holds->search( { reserve_id => { -in => \@hold_ids } }, { join => [ "item", "biblio" ] } );

    while ( my $hold = $holds_to_update->next ) {

        if ($new_expiration_date) {
            $hold->expirationdate($new_expiration_date)->store;
        }

        if ( $new_pickup_loc && ( $hold->branchcode ne $new_pickup_loc ) ) {
            $hold->branchcode($new_pickup_loc)->store;
        }

        if ( $new_suspend_status ne "" ) {
            if ( $new_suspend_status && !$hold->is_found ) {
                $hold->suspend(1)->store;
                if ($new_suspend_date) {
                    $hold->suspend_until($new_suspend_date)->store;
                } else {
                    $hold->suspend_until(undef)->store;
                }
            } elsif ( !$new_suspend_status && $new_suspend_date ) {
                $hold->suspend(1)->store;
                $hold->suspend_until($new_suspend_date)->store;
            } else {
                $hold->suspend(0)->store;
                $hold->suspend_until(undef)->store;
            }
        }

        if ($new_hold_note) {
            $hold->reservenotes($new_hold_note)->store;
        }

        if ($clear_hold_notes) {
            $hold->reservenotes(undef)->store;
        }
        push @holds_data, $hold;
    }

    $template->param(
        updated_holds     => to_json( \@hold_ids ),
        updated_holds_obj => \@holds_data,
        total_updated     => scalar @holds_data,
        view              => 'report',
    );

}

output_html_with_http_headers $input, $cookie, $template->output;
