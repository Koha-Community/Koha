#!/usr/bin/perl


#script to receive orders
#written by chris@katipo.co.nz 24/2/2000

# Copyright 2000-2002 Katipo Communications
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

orderreceive.pl

=head1 DESCRIPTION

This script shows all order already receive and all pendings orders.
It permit to write a new order as 'received'.

=head1 CGI PARAMETERS

=over 4

=item booksellerid

to know on what supplier this script has to display receive order.

=item invoiceid

the id of this invoice.

=item freight

=item biblio

The biblionumber of this order.

=item datereceived

=item catview

=item gst

=back

=cut

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Acquisition;
use C4::Auth;
use C4::Output;
use C4::Budgets qw/ GetBudget GetBudgetHierarchy CanUserUseBudget GetBudgetPeriods /;
use C4::Members;
use C4::Items;
use C4::Biblio;
use C4::Suggestions;
use C4::Koha;

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;
use Koha::DateUtils qw( dt_from_string );
use Koha::ItemTypes;
use Koha::Patrons;

my $input      = new CGI;

my $dbh          = C4::Context->dbh;
my $invoiceid    = $input->param('invoiceid');
my $invoice      = GetInvoice($invoiceid);
my $booksellerid   = $invoice->{booksellerid};
my $freight      = $invoice->{shipmentcost};
my $ordernumber  = $input->param('ordernumber');

my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
my $results;
$results = SearchOrders({
    ordernumber => $ordernumber
}) if $ordernumber;

my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name   => "acqui/orderreceive.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => {acquisition => 'order_receive'},
        debug           => 1,
    }
);

unless ( $results and @$results) {
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

# prepare the form for receiving
my $order = $results->[0];
my $basket = Koha::Acquisition::Orders->find( $ordernumber )->basket;

# Check if ACQ framework exists
my $acq_fw = GetMarcStructure( 1, 'ACQ', { unsafe => 1 } );
unless($acq_fw) {
    $template->param('NoACQframework' => 1);
}

my $AcqCreateItem = $basket->effective_create_items;
if ($AcqCreateItem eq 'receiving') {
    $template->param(
        AcqCreateItemReceiving => 1,
        UniqueItemFields => C4::Context->preference('UniqueItemFields'),
    );
} elsif ($AcqCreateItem eq 'ordering') {
    my $fw = ($acq_fw) ? 'ACQ' : '';
    my @itemnumbers = GetItemnumbersFromOrder($order->{ordernumber});
    my @items;
    foreach (@itemnumbers) {
        my $item = GetItem($_);
        my $descriptions;
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $fw, kohafield => 'items.notforloan', authorised_value => $item->{notforloan} });
        $item->{notforloan} = $descriptions->{lib} // '';

        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $fw, kohafield => 'items.restricted', authorised_value => $item->{restricted} });
        $item->{restricted} = $descriptions->{lib} // '';

        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $fw, kohafield => 'items.location', authorised_value => $item->{location} });
        $item->{location} = $descriptions->{lib} // '';

        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $fw, kohafield => 'items.collection', authorised_value => $item->{collection} });
        $item->{collection} = $descriptions->{lib} // '';

        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $fw, kohafield => 'items.materials', authorised_value => $item->{materials} });
        $item->{materials} = $descriptions->{lib} // '';

        my $itemtype = Koha::ItemTypes->find( $item->{itype} );
        if (defined $itemtype) {
            $item->{itemtype} = $itemtype->description; # FIXME Should not it be translated_description?
        }
        push @items, $item;
    }
    $template->param(items => \@items);
}

$order->{quantityreceived} = '' if $order->{quantityreceived} == 0;

my $unitprice = $order->{unitprice};
my ( $rrp, $ecost );
if ( $bookseller->invoiceincgst ) {
    $rrp = $order->{rrp_tax_included};
    $ecost = $order->{ecost_tax_included};
    unless ( $unitprice != 0 and defined $unitprice) {
        $unitprice = $order->{ecost_tax_included};
    }
} else {
    $rrp = $order->{rrp_tax_excluded};
    $ecost = $order->{ecost_tax_excluded};
    unless ( $unitprice != 0 and defined $unitprice) {
        $unitprice = $order->{ecost_tax_excluded};
    }
}

my $tax_rate;
if( defined $order->{tax_rate_on_receiving} ) {
    $tax_rate = $order->{tax_rate_on_receiving} + 0.0;
} else {
    $tax_rate = $order->{tax_rate_on_ordering} + 0.0;
}

my $suggestion = GetSuggestionInfoFromBiblionumber($order->{biblionumber});

my $creator = Koha::Patrons->find( $order->{created_by} );

my $budget = GetBudget( $order->{budget_id} );

my $datereceived = $order->{datereceived} ? dt_from_string( $order->{datereceived} ) : dt_from_string;

# get option values for gist syspref
my @gst_values = map {
    option => $_ + 0.0
}, split( '\|', C4::Context->preference("gist") );

$template->param(
    AcqCreateItem         => $AcqCreateItem,
    count                 => 1,
    biblionumber          => $order->{'biblionumber'},
    ordernumber           => $order->{'ordernumber'},
    subscriptionid        => $order->{subscriptionid},
    booksellerid          => $order->{'booksellerid'},
    freight               => $freight,
    name                  => $bookseller->name,
    title                 => $order->{'title'},
    author                => $order->{'author'},
    copyrightdate         => $order->{'copyrightdate'},
    isbn                  => $order->{'isbn'},
    seriestitle           => $order->{'seriestitle'},
    bookfund              => $budget->{budget_name},
    quantity              => $order->{'quantity'},
    quantityreceivedplus1 => $order->{'quantityreceived'} + 1,
    quantityreceived      => $order->{'quantityreceived'},
    rrp                   => $rrp,
    ecost                 => $ecost,
    unitprice             => $unitprice,
    tax_rate              => $tax_rate,
    creator               => $creator,
    invoiceid             => $invoice->{invoiceid},
    invoice               => $invoice->{invoicenumber},
    datereceived          => $datereceived,
    order_internalnote    => $order->{order_internalnote},
    order_vendornote      => $order->{order_vendornote},
    suggestionid          => $suggestion->{suggestionid},
    surnamesuggestedby    => $suggestion->{surnamesuggestedby},
    firstnamesuggestedby  => $suggestion->{firstnamesuggestedby},
    gst_values            => \@gst_values,
);

my $patron = Koha::Patrons->find( $loggedinuser )->unblessed;
my @budget_loop;
my $periods = GetBudgetPeriods( );
foreach my $period (@$periods) {
    if ($period->{'budget_period_id'} == $budget->{'budget_period_id'}) {
        $template->{'VARS'}->{'budget_period_description'} = $period->{'budget_period_description'};
    }
    next if $period->{'budget_period_locked'} || !$period->{'budget_period_description'};
    my $budget_hierarchy = GetBudgetHierarchy( $period->{'budget_period_id'} );
    my @funds;
    foreach my $r ( @{$budget_hierarchy} ) {
        next unless ( CanUserUseBudget( $patron, $r, $userflags ) );
        if ( !defined $r->{budget_amount} || $r->{budget_amount} == 0 ) {
            next;
        }
        push @funds,
          {
            b_id  => $r->{budget_id},
            b_txt => $r->{budget_name},
            b_sel => ( $r->{budget_id} == $order->{budget_id} ) ? 1 : 0,
          };
    }

    @funds = sort { uc( $a->{b_txt} ) cmp uc( $b->{b_txt} ) } @funds;

    push @budget_loop,
      {
        'id'          => $period->{'budget_period_id'},
        'description' => $period->{'budget_period_description'},
        'funds'       => \@funds
      };
}

$template->{'VARS'}->{'budget_loop'} = \@budget_loop;

my $op = $input->param('op');
if ($op and $op eq 'edit'){
    $template->param(edit   =>   1);
}
output_html_with_http_headers $input, $cookie, $template->output;
