#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
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

=head1 NAME

invoices.pl

=head1 DESCRIPTION

Search for invoices

=cut

use Modern::Perl;

use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use C4::Acquisition qw( GetInvoices GetInvoice );
use C4::Budgets     qw( GetBudget GetBudgets CanUserUseBudget );
use Koha::DateUtils qw( dt_from_string );
use Koha::Acquisition::Booksellers;
use Koha::AdditionalFields;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => 'acqui/invoices.tt',
        query         => $input,
        type          => 'intranet',
        flagsrequired => { 'acquisition' => '*' },
    }
);

my $invoicenumber    = $input->param('invoicenumber');
my $supplierid       = $input->param('supplierid');
my $shipmentdatefrom = $input->param('shipmentdatefrom');
my $shipmentdateto   = $input->param('shipmentdateto');
my $billingdatefrom  = $input->param('billingdatefrom');
my $billingdateto    = $input->param('billingdateto');
my $isbneanissn      = $input->param('isbneanissn');
my $title            = $input->param('title');
my $author           = $input->param('author');
my $publisher        = $input->param('publisher');
my $publicationyear  = $input->param('publicationyear');
my $branch           = $input->param('branch');
my $message_id       = $input->param('message_id');
my $op               = $input->param('op');

my @additional_fields = Koha::AdditionalFields->search(
    {
        tablename  => 'aqinvoices',
        searchable => 1
    }
)->as_list;
my @additional_field_filters;
for my $field (@additional_fields) {
    my $value = $input->param( 'additional_field_' . $field->id );
    if ( defined $value and $value ne '' ) {
        push @additional_field_filters,
            {
            id    => $field->id,
            value => $value,
            };
    }
}

my $invoices = [];
if ( $op and $op eq 'do_search' ) {
    @{$invoices} = GetInvoices(
        invoicenumber     => $invoicenumber,
        supplierid        => $supplierid,
        shipmentdatefrom  => $shipmentdatefrom,
        shipmentdateto    => $shipmentdateto,
        billingdatefrom   => $billingdatefrom,
        billingdateto     => $billingdateto,
        isbneanissn       => $isbneanissn,
        title             => $title,
        author            => $author,
        publisher         => $publisher,
        publicationyear   => $publicationyear,
        branchcode        => $branch,
        message_id        => $message_id,
        additional_fields => \@additional_field_filters,
    );
}

$template->param(
    additional_field_filters      => { map { $_->{id} => $_->{value} } @additional_field_filters },
    additional_fields_for_invoice => \@additional_fields,
);

# Build suppliers list
my $supplier;
$supplier = Koha::Acquisition::Booksellers->find($supplierid) if $supplierid;

my $budgets = GetBudgets();
my @budgets_loop;
foreach my $budget (@$budgets) {
    push @budgets_loop, $budget if CanUserUseBudget( $loggedinuser, $budget, $flags );
}

my ( @openedinvoices, @closedinvoices );
for my $sub ( @{$invoices} ) {
    unless ( $sub->{closedate} ) {
        push @openedinvoices, $sub;
    } else {
        push @closedinvoices, $sub;
    }
}

$template->{'VARS'}->{'budgets_loop'} = \@budgets_loop;

$template->param(
    openedinvoices   => \@openedinvoices,
    closedinvoices   => \@closedinvoices,
    do_search        => ( $op and $op eq 'do_search' ) ? 1 : 0,
    invoices         => $invoices,
    invoicenumber    => $invoicenumber,
    booksellerid     => $supplierid,
    supplier         => $supplier,
    shipmentdatefrom => $shipmentdatefrom,
    shipmentdateto   => $shipmentdateto,
    billingdatefrom  => $billingdatefrom,
    billingdateto    => $billingdateto,
    isbneanissn      => $isbneanissn,
    title            => $title,
    author           => $author,
    publisher        => $publisher,
    publicationyear  => $publicationyear,
    branch           => $branch,
);

output_html_with_http_headers $input, $cookie, $template->output;
