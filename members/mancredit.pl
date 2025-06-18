#!/usr/bin/perl

#written 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
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

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use CGI        qw ( -utf8 );

use C4::Members;
use C4::Accounts;

use Koha::Items;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Account::CreditTypes;
use Koha::AdditionalFields;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "members/mancredit.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => {
            borrowers     => 'edit_borrowers',
            updatecharges => 'manual_credit'
        }
    }
);

my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $borrowernumber = $input->param('borrowernumber');
my $patron         = Koha::Patrons->find($borrowernumber);

output_and_exit_if_error(
    $input, $cookie,
    $template,
    {
        module         => 'members',
        logged_in_user => $logged_in_user,
        current_patron => $patron
    }
);

my $library_id = C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;

my $op = $input->param('op') // q{};
if ( $op eq 'cud-add' ) {

    # Note: If the logged in user is not allowed to see this patron an invoice can be forced
    # Here we are trusting librarians not to hack the system
    my $barcode = $input->param('barcode');
    my $item_id;
    if ($barcode) {
        my $item = Koha::Items->find( { barcode => $barcode } );
        $item_id = $item->itemnumber if $item;
    }
    my $description      = $input->param('desc');
    my $note             = $input->param('note');
    my $amount           = $input->param('amount') || 0;
    my $type             = $input->param('type');
    my $credit_type      = $input->param('credit_type');
    my $cash_register_id = $input->param('cash_register');

    my $line = $patron->account->add_credit(
        {
            amount        => $amount,
            description   => $description,
            item_id       => $item_id,
            library_id    => $library_id,
            note          => $note,
            type          => $type,
            user_id       => $logged_in_user->id,
            interface     => C4::Context->interface,
            payment_type  => $credit_type,
            cash_register => $cash_register_id
        }
    );

    my @additional_fields = $line->prepare_cgi_additional_field_values( $input, 'accountlines:credit' );
    if (@additional_fields) {
        $line->set_additional_fields( \@additional_fields );
    }

    if ( C4::Context->preference('AccountAutoReconcile') ) {
        $patron->account->reconcile_balance;
    }

    print $input->redirect("/cgi-bin/koha/members/boraccount.pl?borrowernumber=$borrowernumber");
    exit;
} else {

    my @credit_types = Koha::Account::CreditTypes->search_with_library_limits(
        { can_be_added_manually => 1, archived => 0 },
        {}, $library_id
    )->as_list;

    $template->param(
        patron                      => $patron,
        credit_types                => \@credit_types,
        finesview                   => 1,
        available_additional_fields =>
            [ Koha::AdditionalFields->search( { tablename => 'accountlines:credit' } )->as_list ],
    );
    output_html_with_http_headers $input, $cookie, $template->output;
}
