#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
# Copyright 2010 PTFS Europe Ltd
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

supplier.pl

=head1 DESCRIPTION

this script shows the details for a bookseller given on input arg.
It allows to edit & save information about this bookseller.

=head1 CGI PARAMETERS

=over 4

=item booksellerid

To know the bookseller this script has to display details.

=back

=cut

use Modern::Perl;
use C4::Auth qw( get_template_and_user );
use C4::Contract qw( GetContracts GetContract );
use C4::Output qw( output_html_with_http_headers );
use CGI qw ( -utf8 );

use C4::Budgets;

use Koha::Acquisition::Bookseller::Contacts;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Currencies;

my $query    = CGI->new;
my $op = $query->param('op') || 'display';
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'acqui/supplier.tt',
        query           => $query,
        type            => 'intranet',
        flagsrequired   => { acquisition => '*' },
    }
);
my $booksellerid       = $query->param('booksellerid');
my $supplier;
if ($booksellerid) {
    $supplier = Koha::Acquisition::Booksellers->find( $booksellerid );
    my $supplier_hashref = $supplier->unblessed;
    foreach ( keys %{$supplier_hashref} ) {
        $template->{'VARS'}->{$_} = $supplier->$_;
    }
    $template->{VARS}->{contacts} = $supplier->contacts if $supplier->contacts->count;
    $template->{'VARS'}->{'booksellerid'} = $booksellerid;
}

$template->{VARS}->{contacts} ||= Koha::Acquisition::Bookseller::Contact->new;

if ( $op eq 'display' ) {
    my $contracts = GetContracts( { booksellerid => $booksellerid } );

    $template->param(
        active        => $supplier->active,
        tax_rate      => $supplier->tax_rate + 0.0,
        invoiceprice  => $supplier->invoiceprice,
        listprice     => $supplier->listprice,
        basketcount   => $supplier->baskets->count,
        subscriptioncount => $supplier->subscriptions->count,
        vendor        => $supplier,
        contracts     => $contracts,
    );
} elsif ( $op eq 'delete' ) {
    # no further message needed for the user
    # the DELETE button only appears in the template if basketcount == 0 AND subscriptioncount == 0
    if ( $supplier->baskets->count == 0 && $supplier->subscriptions->count == 0) {
        Koha::Acquisition::Booksellers->find($booksellerid)->delete;
    }
    print $query->redirect('/cgi-bin/koha/acqui/acqui-home.pl');
    exit;
} else {

    # get option values from TaxRates syspref
    my @gst_values = map {
        option => $_ + 0.0
    }, split( '\|', C4::Context->preference("TaxRates") );

    $template->param(
        # set active ON by default for supplier add (id empty for add)
        active     => $supplier ? $supplier->active         : 1,
        tax_rate   => $supplier ? $supplier->tax_rate + 0.0 : 0,
        vendor        => $supplier,
        gst_values    => \@gst_values,
        currencies    => Koha::Acquisition::Currencies->search,
        enter         => 1,
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
