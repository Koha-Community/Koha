#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
# Copyright 2010,2011 PTFS-Europe Ltd
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

=head1 pay.pl

 written 11/1/2000 by chris@katipo.oc.nz
 part of the koha library system, script to facilitate paying off fines

=cut

use Modern::Perl;

use URI::Escape qw( uri_escape_utf8 uri_unescape );
use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use CGI        qw ( -utf8 );
use C4::Members;
use C4::Accounts;
use C4::Stats;
use C4::Koha;
use C4::Overdues;
use Koha::Patrons;
use Koha::Items;

use Koha::Patron::Categories;
use URI::Escape qw( uri_escape_utf8 uri_unescape );

our $input = CGI->new;

my $updatecharges_permissions = $input->param('woall') ? 'writeoff' : 'remaining_permissions';
our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => 'members/pay.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { borrowers => 'edit_borrowers', updatecharges => $updatecharges_permissions },
    }
);

my @names = $input->param;

our $borrowernumber = $input->param('borrowernumber');
if ( !$borrowernumber ) {
    $borrowernumber = $input->param('borrowernumber0');
}

my $payment_id = $input->param('payment_id');
our $change_given  = $input->param('change_given');
our @renew_results = $input->multi_param('renew_result');

# get borrower details
my $logged_in_user = Koha::Patrons->find($loggedinuser);
our $patron = Koha::Patrons->find($borrowernumber);
output_and_exit_if_error(
    $input, $cookie, $template,
    { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron }
);

our $user = $input->remote_user;
$user ||= q{};

our $branch = C4::Context->userenv->{'branch'};

my $op = $input->param('op') // q{};

# FIXME: paycollect, payselected, writeoff_selected, pay_individual and writeoff_individual
# are all stateless actions, but it does no harm to check the csrf here anyway and prevents
# the need for a complete re-write.

if ( $op eq 'cud-paycollect' ) {
    print $input->redirect(
        "/cgi-bin/koha/members/paycollect.pl?borrowernumber=$borrowernumber&change_given=$change_given");
} elsif ( $op eq 'cud-payselected' ) {
    payselected( { params => \@names } );
} elsif ( $op eq 'cud-writeoff_selected' ) {
    payselected( { params => \@names, type => 'WRITEOFF' } );
} elsif ( $op eq 'cud-woall' ) {
    writeoff_all(@names);
} elsif ( $op eq 'cud-apply_credits' ) {
    apply_credits( { patron => $patron, cgi => $input } );
}

for (@names) {
    if ( $op =~ /^cud-pay_indiv_(\d+)$/ ) {
        my $line_no = $1;
        redirect_to_paycollect( 'pay_individual', $line_no );
    } elsif ( $op =~ /^cud-wo_indiv_(\d+)$/ ) {
        my $line_no = $1;
        redirect_to_paycollect( 'writeoff_individual', $line_no );
    }
}

# Populate an arrayref with everything we need to display any
# renew results that occurred based on what we were passed
my $renew_results_display = [];
foreach my $renew_result (@renew_results) {
    my ( $itemnumber, $success, $info ) = split( /,/, $renew_result );
    my $item = Koha::Items->find($itemnumber);
    if ($success) {
        $info = uri_unescape($info);
    }
    push @{$renew_results_display}, {
        item    => $item,
        success => $success,
        info    => $info
    };
}

$template->param(
    finesview     => 1,
    payment_id    => $payment_id,
    change_given  => $change_given,
    renew_results => $renew_results_display
);

add_accounts_to_template();

output_html_with_http_headers $input, $cookie, $template->output;

sub add_accounts_to_template {

    my $patron              = Koha::Patrons->find($borrowernumber);
    my $account             = $patron->account;
    my $outstanding_credits = $account->outstanding_credits;
    my $account_lines       = $account->outstanding_debits;
    my $total               = $account_lines->total_outstanding;
    my @accounts;
    while ( my $account_line = $account_lines->next ) {
        push @accounts, $account_line;
    }

    $template->param(
        patron              => $patron,
        accounts            => \@accounts,
        total               => $total,
        outstanding_credits => $outstanding_credits
    );

    return;

}

sub get_for_redirect {
    my ( $name, $name_in, $money ) = @_;
    my $s = q{&} . $name . q{=};
    my $value;
    if ( defined $input->param($name_in) ) {
        $value = uri_escape_utf8( scalar $input->param($name_in) );
    }
    if ( !defined $value ) {
        $value = ( $money == 1 ) ? 0 : q{};
    }
    if ($money) {
        $s .= sprintf '%.2f', $value;
    } else {
        $s .= $value;
    }
    return $s;
}

sub redirect_to_paycollect {
    my ( $action, $line_no ) = @_;
    my $redirect = "/cgi-bin/koha/members/paycollect.pl?borrowernumber=$borrowernumber";
    $redirect .= q{&};
    $redirect .= "$action=1";
    $redirect .= get_for_redirect( 'debit_type_code',   "debit_type_code$line_no",   0 );
    $redirect .= get_for_redirect( 'amount',            "amount$line_no",            1 );
    $redirect .= get_for_redirect( 'amountoutstanding', "amountoutstanding$line_no", 1 );
    $redirect .= get_for_redirect( 'description',       "description$line_no",       0 );
    $redirect .= get_for_redirect( 'title',             "title$line_no",             0 );
    $redirect .= get_for_redirect( 'itemnumber',        "itemnumber$line_no",        0 );
    $redirect .= get_for_redirect( 'accountlines_id',   "accountlines_id$line_no",   0 );
    $redirect .= q{&} . 'payment_note' . q{=} . uri_escape_utf8( scalar $input->param("payment_note_$line_no") );
    $redirect .= '&remote_user=';
    $redirect .= "change_given=$change_given";
    $redirect .= $user;
    return print $input->redirect($redirect);
}

sub writeoff_all {
    my @params   = @_;
    my @wo_lines = grep { /^accountlines_id\d+$/ } @params;

    my $borrowernumber = $input->param('borrowernumber');

    for (@wo_lines) {
        if (/(\d+)/) {
            my $value           = $1;
            my $amount          = $input->param("amountoutstanding$value");
            my $accountlines_id = $input->param("accountlines_id$value");
            my $payment_note    = $input->param("payment_note_$value");
            Koha::Account->new( { patron_id => $borrowernumber } )->pay(
                {
                    amount     => $amount,
                    lines      => [ Koha::Account::Lines->find($accountlines_id) ],
                    type       => 'WRITEOFF',
                    note       => $payment_note,
                    interface  => C4::Context->interface,
                    library_id => $branch,
                }
            );
        }
    }

    print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber");
    return;
}

sub payselected {
    my $parameters = shift;

    my @params = @{ $parameters->{params} };
    my $type   = $parameters->{type} || 'PAYMENT';

    my $amt = 0;
    my @lines_to_pay;
    foreach (@params) {
        if (/^incl_par_(\d+)$/) {
            my $index = $1;
            push @lines_to_pay, scalar $input->param("accountlines_id$index");
            $amt += $input->param("amountoutstanding$index");
        }
    }
    $amt = '&amt=' . $amt;
    my $sel = '&selected=' . join ',', @lines_to_pay;
    my $notes =
        '&notes=' . uri_escape_utf8( join( "\n", map { scalar $input->param("payment_note_$_") } @lines_to_pay ) );
    my $redirect =
        "/cgi-bin/koha/members/paycollect.pl?borrowernumber=$borrowernumber" . "&type=$type" . $amt . $sel . $notes;

    print $input->redirect($redirect);
    return;
}

sub apply_credits {
    my ($args) = @_;

    my $patron = $args->{patron};
    my $cgi    = $args->{cgi};

    $patron->account->reconcile_balance();

    print $cgi->redirect( "/cgi-bin/koha/members/pay.pl?borrowernumber=" . $patron->borrowernumber );
    return;
}
