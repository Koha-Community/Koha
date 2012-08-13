#!/usr/bin/perl

# Copyright 2011 BibLibre SARL
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

invoices.pl

=head1 DESCRIPTION

Search for invoices

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;

use C4::Acquisition;
use C4::Bookseller qw/GetBookSeller/;
use C4::Branch;

my $input = new CGI;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => 'acqui/invoices.tmpl',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { 'acquisition' => '*' },
        debug           => 1,
    }
);

my $invoicenumber    = $input->param('invoicenumber');
my $supplier         = $input->param('supplier');
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
my $op               = $input->param('op');

my @results_loop = ();
if ( $op and $op eq "do_search" ) {
    my $shipmentdatefrom_iso = C4::Dates->new($shipmentdatefrom)->output("iso");
    my $shipmentdateto_iso   = C4::Dates->new($shipmentdateto)->output("iso");
    my $billingdatefrom_iso  = C4::Dates->new($billingdatefrom)->output("iso");
    my $billingdateto_iso    = C4::Dates->new($billingdateto)->output("iso");
    my @invoices             = GetInvoices(
        invoicenumber    => $invoicenumber,
        suppliername     => $supplier,
        shipmentdatefrom => $shipmentdatefrom_iso,
        shipmentdateto   => $shipmentdateto_iso,
        billingdatefrom  => $billingdatefrom_iso,
        billingdateto    => $billingdateto_iso,
        isbneanissn      => $isbneanissn,
        title            => $title,
        author           => $author,
        publisher        => $publisher,
        publicationyear  => $publicationyear,
        branchcode       => $branch
    );
    foreach (@invoices) {
        my %row = (
            invoiceid       => $_->{invoiceid},
            billingdate     => $_->{billingdate},
            invoicenumber   => $_->{invoicenumber},
            suppliername    => $_->{suppliername},
            receivedbiblios => $_->{receivedbiblios},
            receiveditems   => $_->{receiveditems},
            subscriptionid  => $_->{subscriptionid},
            closedate       => $_->{closedate},
        );
        push @results_loop, \%row;
    }
}

# Build suppliers list
my @suppliers      = GetBookSeller(undef);
my @suppliers_loop = ();
my $suppliername;
foreach (@suppliers) {
    my $selected = 0;
    if ( $supplier && $supplier == $_->{'id'} ) {
        $selected     = 1;
        $suppliername = $_->{'name'};
    }
    my %row = (
        suppliername => $_->{'name'},
        supplierid   => $_->{'id'},
        selected     => $selected,
    );
    push @suppliers_loop, \%row;
}

# Build branches list
my $branches      = GetBranches();
my @branches_loop = ();
my $branchname;
foreach ( sort keys %$branches ) {
    my $selected = 0;
    if ( $branch && $branch eq $_ ) {
        $selected   = 1;
        $branchname = $branches->{$_}->{'branchname'};
    }
    my %row = (
        branchcode => $_,
        branchname => $branches->{$_}->{'branchname'},
        selected   => $selected,
    );
    push @branches_loop, \%row;
}

$template->param(
    do_search => ( $op and $op eq "do_search" ) ? 1 : 0,
    results_loop             => \@results_loop,
    invoicenumber            => $invoicenumber,
    supplier                 => $supplier,
    suppliername             => $suppliername,
    billingdatefrom          => $billingdatefrom,
    billingdateto            => $billingdateto,
    isbneanissn              => $isbneanissn,
    title                    => $title,
    author                   => $author,
    publisher                => $publisher,
    publicationyear          => $publicationyear,
    branch                   => $branch,
    branchname               => $branchname,
    suppliers_loop           => \@suppliers_loop,
    branches_loop            => \@branches_loop,
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);

output_html_with_http_headers $input, $cookie, $template->output;
