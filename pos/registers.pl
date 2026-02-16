#!/usr/bin/perl
#
# c 2020 PTFS-Europe Ltd
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

use Modern::Perl;
use CGI;
use URI::Escape qw( uri_escape uri_unescape );
use C4::Auth    qw( get_template_and_user );
use C4::Output  qw( output_html_with_http_headers );
use C4::Context;

use Koha::Cash::Registers;
use Koha::Database;

my $input = CGI->new();

my ( $template, $loggedinuser, $cookie, $user_flags ) = get_template_and_user(
    {
        template_name   => 'pos/registers.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { cash_management => [ 'cashup', 'anonymous_refund' ] },
    }
);
my $logged_in_user = Koha::Patrons->find($loggedinuser) or die "Not logged in";

my $library = Koha::Libraries->find( C4::Context->userenv->{'branch'} );
$template->param( library => $library );

# Get authorized values for reconciliation notes if configured
my $note_av_category = C4::Context->preference('CashupReconciliationNoteAuthorisedValue');
my $reconciliation_note_avs;
if ($note_av_category) {
    require Koha::AuthorisedValues;
    $reconciliation_note_avs = Koha::AuthorisedValues->search(
        { category => $note_av_category },
        { order_by => { '-asc' => 'lib' } }
    );
}

my $registers = Koha::Cash::Registers->search(
    { branch   => $library->id, archived => 0 },
    { order_by => { '-asc' => 'name' } }
);

if ( !$registers->count ) {
    $template->param( error_registers => 1 );
} else {
    $template->param(
        registers                    => $registers,
        reconciliation_note_avs      => $reconciliation_note_avs,
        reconciliation_note_required => C4::Context->preference('CashupReconciliationNoteRequired'),
    );
}

# Handle success/error messages from redirects
my $cashup_start_success         = $input->param('cashup_start_success');
my $cashup_start_errors          = $input->param('cashup_start_errors');
my $cashup_start_error_detail    = $input->param('cashup_start_error_detail');
my $cashup_complete_success      = $input->param('cashup_complete_success');
my $cashup_complete_errors       = $input->param('cashup_complete_errors');
my $cashup_complete_error_detail = $input->param('cashup_complete_error_detail');

if ($cashup_start_success) {
    $template->param( cashup_start_success => $cashup_start_success );
}
if ($cashup_start_errors) {
    $template->param( cashup_start_errors => $cashup_start_errors );
}
if ($cashup_start_error_detail) {
    $template->param(
        cashup_start_error_details => [ map { uri_unescape($_) } split( /,/, $cashup_start_error_detail ) ] );
}
if ($cashup_complete_success) {
    $template->param( cashup_complete_success => $cashup_complete_success );
}
if ($cashup_complete_errors) {
    $template->param( cashup_complete_errors => $cashup_complete_errors );
}
if ($cashup_complete_error_detail) {
    $template->param(
        cashup_complete_error_details => [ map { uri_unescape($_) } split( /,/, $cashup_complete_error_detail ) ] );
}

my $op = $input->param('op') // '';
if ( $op eq 'cud-cashup_start' ) {
    if ( $logged_in_user->has_permission( { cash_management => 'cashup' } ) ) {
        my $registerid_param = $input->param('registerid');
        my @register_ids     = split( ',', $registerid_param );
        my @errors           = ();
        my $success_count    = 0;

        foreach my $register_id (@register_ids) {
            $register_id =~ s/^\s+|\s+$//g;    # Trim whitespace
            next unless $register_id;

            my $register = Koha::Cash::Registers->find( { id => $register_id } );
            next unless $register;

            eval {
                $register->start_cashup(
                    {
                        manager_id => $logged_in_user->id,
                    }
                );
                $success_count++;
            };
            if ($@) {
                if ( $@->isa('Koha::Exceptions::Object::DuplicateID') ) {
                    push @errors, "Register " . $register->name . ": Cashup already in progress";
                } elsif ( $@->isa('Koha::Exceptions::Object::BadValue') ) {
                    push @errors, "Register " . $register->name . ": No cash transactions to cashup";
                } else {
                    push @errors, "Register " . $register->name . ": Failed to start cashup";
                }
            }
        }

        if ( @errors && $success_count == 0 ) {

            # All failed - stay on page to show errors
            $template->param(
                error_cashup_start => 1,
                cashup_errors      => \@errors
            );
        } else {

            # Some or all succeeded - redirect with coded parameters
            my $redirect_url = "/cgi-bin/koha/pos/registers.pl";
            my @params;

            if ( $success_count > 0 ) {
                push @params, "cashup_start_success=" . $success_count;
            }
            if (@errors) {
                push @params, "cashup_start_errors=" . scalar(@errors);
                push @params, "cashup_start_error_detail=" . join( ',', map { uri_escape($_) } @errors );
            }

            if (@params) {
                $redirect_url .= "?" . join( "&", @params );
            }

            print $input->redirect($redirect_url);
            exit;
        }
    } else {
        $template->param( error_cashup_permission => 1 );
    }
} elsif ( $op eq 'cud-cashup' ) {
    if ( $logged_in_user->has_permission( { cash_management => 'cashup' } ) ) {
        my $registerid_param = $input->param('registerid');
        my @register_ids     = split( ',', $registerid_param );
        my @errors           = ();
        my $success_count    = 0;

        foreach my $register_id (@register_ids) {
            $register_id =~ s/^\s+|\s+$//g;    # Trim whitespace
            next unless $register_id;

            my $register = Koha::Cash::Registers->find( { id => $register_id } );
            next unless $register;

            eval {
                # Get the amount from the request parameter
                # For quick cashup, this will be the expected amount set by JavaScript
                # For two-stage cashup completion, this will be the user-entered actual amount
                my $amount = $input->param('amount');

                # If no amount provided, calculate expected amount (backwards compatibility)
                unless ( defined $amount && $amount ne '' ) {
                    $amount =
                        $register->outstanding_accountlines->total( { payment_type => [ 'CASH', 'SIP00' ] } ) * -1;
                }

                # Get optional reconciliation note
                my $reconciliation_note = $input->param('reconciliation_note');

                # Complete the cashup
                my %cashup_params = (
                    manager_id => $logged_in_user->id,
                    amount     => $amount,
                );

                # Add reconciliation note if provided
                if ( defined $reconciliation_note && $reconciliation_note ne '' ) {
                    $cashup_params{reconciliation_note} = $reconciliation_note;
                }

                $register->add_cashup( \%cashup_params );
                $success_count++;
            };
            if ($@) {
                if ( $@->isa('Koha::Exceptions::Object::BadValue') ) {
                    push @errors, "Register " . $register->name . ": No cashup session to complete";
                } elsif ( $@->isa('Koha::Exceptions::Object::DuplicateID') ) {
                    push @errors, "Register " . $register->name . ": Cashup already completed";
                } else {
                    push @errors, "Register " . $register->name . ": Failed to complete cashup";
                }
            }
        }

        if ( @errors && $success_count == 0 ) {

            # All failed - stay on page to show errors
            $template->param(
                error_cashup_complete => 1,
                cashup_errors         => \@errors
            );
        } else {

            # Some or all succeeded - redirect with coded parameters
            my $redirect_url = "/cgi-bin/koha/pos/registers.pl";
            my @params;

            if ( $success_count > 0 ) {
                push @params, "cashup_complete_success=" . $success_count;
            }
            if (@errors) {
                push @params, "cashup_complete_errors=" . scalar(@errors);
                push @params, "cashup_complete_error_detail=" . join( ',', map { uri_escape($_) } @errors );
            }

            if (@params) {
                $redirect_url .= "?" . join( "&", @params );
            }

            print $input->redirect($redirect_url);
            exit;
        }
    } else {
        $template->param( error_cashup_permission => 1 );
    }
}

output_html_with_http_headers( $input, $cookie, $template->output );
