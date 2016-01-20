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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

invoices.pl

=head1 DESCRIPTION

Search for invoices

=cut

use strict;
use warnings;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;

use C4::Acquisition qw/GetInvoices/;
use C4::Branch qw/GetBranches/;
use C4::Budgets;
use Koha::DateUtils;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => 'acqui/invoices.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { 'acquisition' => '*' },
        debug           => 1,
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

$shipmentdatefrom and $shipmentdatefrom = eval { dt_from_string( $shipmentdatefrom ) };
$shipmentdateto   and $shipmentdateto   = eval { dt_from_string( $shipmentdateto ) };
$billingdatefrom  and $billingdatefrom  = eval { dt_from_string( $billingdatefrom ) };
$billingdateto    and $billingdateto    = eval { dt_from_string( $billingdateto ) };

my $invoices = [];
if ( $op and $op eq 'do_search' ) {
    @{$invoices} = GetInvoices(
        invoicenumber    => $invoicenumber,
        supplierid       => $supplierid,
        shipmentdatefrom => $shipmentdatefrom ? output_pref( { str => $shipmentdatefrom, dateformat => 'iso' } ) : undef,
        shipmentdateto   => $shipmentdateto   ? output_pref( { str => $shipmentdateto,   dateformat => 'iso' } ) : undef,
        billingdatefrom  => $billingdatefrom  ? output_pref( { str => $billingdatefrom,  dateformat => 'iso' } ) : undef,
        billingdateto    => $billingdateto    ? output_pref( { str => $billingdateto,    dateformat => 'iso' } ) : undef,
        isbneanissn      => $isbneanissn,
        title            => $title,
        author           => $author,
        publisher        => $publisher,
        publicationyear  => $publicationyear,
        branchcode       => $branch,
        message_id       => $message_id,
    );
}

# Build suppliers list
my @suppliers      = Koha::Acquisition::Bookseller->search;
my $suppliers_loop = [];
my $suppliername;
foreach (@suppliers) {
    my $selected = 0;
    if ($supplierid && $supplierid == $_->{id} ) {
        $selected = 1;
        $suppliername = $_->{name};
    }
    push @{$suppliers_loop},
      {
        suppliername => $_->{name},
        booksellerid   => $_->{id},
        selected     => $selected,
      };
}

# Build branches list
my $branches      = GetBranches();
my $branches_loop = [];
my $branchname;
foreach ( sort keys %$branches ) {
    my $selected = 0;
    if ( $branch && $branch eq $_ ) {
        $selected   = 1;
        $branchname = $branches->{$_}->{'branchname'};
    }
    push @{$branches_loop},
      {
        branchcode => $_,
        branchname => $branches->{$_}->{branchname},
        selected   => $selected,
      };
}

my $budgets = GetBudgets();
my @budgets_loop;
foreach my $budget (@$budgets) {
    push @budgets_loop, $budget if CanUserUseBudget( $loggedinuser, $budget, $flags );
}

$template->{'VARS'}->{'budgets_loop'} = \@budgets_loop;

$template->param(
    do_search => ( $op and $op eq 'do_search' ) ? 1 : 0,
    invoices => $invoices,
    invoicenumber   => $invoicenumber,
    booksellerid    => $supplierid,
    suppliername    => $suppliername,
    shipmentdatefrom => $shipmentdatefrom,
    shipmentdateto   => $shipmentdateto,
    billingdatefrom => $billingdatefrom,
    billingdateto   => $billingdateto,
    isbneanissn     => $isbneanissn,
    title           => $title,
    author          => $author,
    publisher       => $publisher,
    publicationyear => $publicationyear,
    branch          => $branch,
    branchname      => $branchname,
    suppliers_loop  => $suppliers_loop,
    branches_loop   => $branches_loop,
);

output_html_with_http_headers $input, $cookie, $template->output;
