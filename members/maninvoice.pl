#!/usr/bin/perl

#written 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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

use Modern::Perl;
use Try::Tiny   qw( catch try );
use URI::Escape qw( uri_escape_utf8 );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use CGI        qw ( -utf8 );
use C4::Members;
use C4::Accounts;

use Koha::Patrons;
use Koha::Items;
use Koha::Old::Items;
use Koha::Checkouts;
use Koha::Old::Checkouts;

use Koha::Patron::Categories;
use Koha::Account::DebitTypes;
use Koha::AdditionalFields;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/maninvoice.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => {
            borrowers     => 'edit_borrowers',
            updatecharges => 'manual_invoice'
        }
    }
);

my $borrowernumber = $input->param('borrowernumber');
my $patron         = Koha::Patrons->find($borrowernumber);
unless ($patron) {
    print $input->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrowernumber");
    exit;
}

my $logged_in_user = Koha::Patrons->find($loggedinuser);
output_and_exit_if_error(
    $input, $cookie,
    $template,
    {
        module         => 'members',
        logged_in_user => $logged_in_user,
        current_patron => $patron
    }
);

my $library_id = C4::Context->userenv->{'branch'};

my $op = $input->param('op') // q{};

my $add        = $input->param('add');
my $desc       = $input->param('desc');
my $amount     = $input->param('amount');
my $note       = $input->param('note');
my $debit_type = $input->param('type');
my $barcode    = $input->param('barcode');

$template->param(
    desc    => $desc,
    amount  => $amount,
    note    => $note,
    type    => $debit_type,
    barcode => $barcode
);

if ( $op eq 'cud-add' ) {

    # Note: If the logged in user is not allowed to see this patron an invoice can be forced
    # Here we are trusting librarians not to hack the system
    my $desc       = $input->param('desc');
    my $amount     = $input->param('amount');
    my $note       = $input->param('note');
    my $debit_type = $input->param('type');

    # If barcode is passed, attempt to find the associated item
    my $failed;
    my $item_id;
    my $olditem;    # FIXME: When items and deleted_items are merged, we can remove this
    my $issue_id;
    if ($barcode) {
        my $item = Koha::Items->find( { barcode => $barcode } );
        if ($item) {
            $item_id = $item->itemnumber;
        } else {
            $item = Koha::Old::Items->search(
                { barcode  => $barcode },
                { order_by => { -desc => 'timestamp' }, rows => 1 }
            );
            if ( $item->count ) {
                $item_id = $item->next->itemnumber;
                $olditem = 1;
            } else {
                $template->param( error => 'itemnumber' );
                $failed = 1;
            }
        }

        if ( ( $debit_type eq 'LOST' ) && $item_id ) {
            my $checkouts = Koha::Checkouts->search(
                {
                    itemnumber     => $item_id,
                    borrowernumber => $borrowernumber
                }
            );
            my $checkout =
                  $checkouts->count
                ? $checkouts->next
                : Koha::Old::Checkouts->search(
                {
                    itemnumber     => $item_id,
                    borrowernumber => $borrowernumber
                },
                { order_by => { -desc => 'returndate' }, rows => 1 }
                )->next;
            $issue_id = $checkout ? $checkout->issue_id : undef;
        }
    }

    unless ($failed) {
        try {
            my $line = $patron->account->add_debit(
                {
                    amount      => $amount,
                    description => $desc,
                    note        => $note,
                    user_id     => $logged_in_user->borrowernumber,
                    interface   => 'intranet',
                    library_id  => $library_id,
                    type        => $debit_type,
                    ( $olditem ? () : ( item_id => $item_id ) ),
                    issue_id => $issue_id
                }
            );

            my @additional_fields = $line->prepare_cgi_additional_field_values( $input, 'accountlines:debit' );
            if (@additional_fields) {
                $line->set_additional_fields( \@additional_fields );
            }

            if ( C4::Context->preference('AccountAutoReconcile') ) {
                $patron->account->reconcile_balance;
            }

            if ( $add eq 'save and pay' ) {
                my $url = sprintf(
                    '/cgi-bin/koha/members/paycollect.pl?borrowernumber=%s&pay_individual=1&debit_type_code=%s&amount=%s&amountoutstanding=%s&description=%s&itemnumber=%s&accountlines_id=%s',
                    map { uri_escape_utf8($_) } (
                        $borrowernumber,
                        $line->debit_type_code,
                        $line->amount,
                        $line->amountoutstanding,
                        $line->description,
                        $line->itemnumber,
                        $line->id
                    )
                );

                print $input->redirect($url);
            } else {
                print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber");
            }

            exit;
        } catch {
            my $error = $_;
            if ( ref($error) eq 'Koha::Exceptions::Object::FKConstraint' ) {
                $template->param( error => $error->broken_fk );
            } else {
                $template->param( error => $error );
            }
        }
    }
}

my $debit_types = Koha::Account::DebitTypes->search_with_library_limits(
    { can_be_invoiced => 1, archived => 0 },
    { order_by => { -asc => 'description' } }, $library_id
);

$template->param(
    debit_types                 => $debit_types,
    patron                      => $patron,
    finesview                   => 1,
    available_additional_fields => [ Koha::AdditionalFields->search( { tablename => 'accountlines:debit' } )->as_list ],
);
output_html_with_http_headers $input, $cookie, $template->output;
